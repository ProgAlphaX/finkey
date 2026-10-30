#!/usr/bin/env bash
# Bootstrap idempotente de un proyecto GCP de FinKey (stg o prod).
#
# Uso:
#   ENV=stg  PROJECT_ID=finkey-stg-xxxx  BILLING_ACCOUNT=XXXXXX-XXXXXX-XXXXXX ./bootstrap.sh
#   ENV=prod PROJECT_ID=finkey-prod-xxxx BILLING_ACCOUNT=XXXXXX-XXXXXX-XXXXXX ./bootstrap.sh
#
# Requiere: gcloud autenticado con permisos de creación de proyectos y de facturación.
# No guarda ni imprime secretos: solo crea recursos y muestra identificadores públicos.
set -euo pipefail

: "${ENV:?ENV debe ser stg o prod}"
: "${PROJECT_ID:?PROJECT_ID requerido}"
: "${BILLING_ACCOUNT:?BILLING_ACCOUNT requerido}"
REPO="${GITHUB_REPO:-ProgAlphaX/finkey}"
REGION="${REGION:-us-east4}"
BUDGET_USD="${BUDGET_USD:-1}"

case "$ENV" in
  stg)  GH_ENV="stg" ;;
  prod) GH_ENV="production" ;;
  *) echo "ENV debe ser stg o prod" >&2; exit 1 ;;
esac

log() { printf '==> %s\n' "$*"; }

# 1. Proyecto y facturación
if ! gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
  log "Creando proyecto $PROJECT_ID"
  gcloud projects create "$PROJECT_ID" --name="FinKey $ENV"
fi
log "Vinculando facturación"
gcloud billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT" >/dev/null
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"

# 2. APIs
APIS=(run.googleapis.com artifactregistry.googleapis.com iam.googleapis.com
      iamcredentials.googleapis.com sts.googleapis.com cloudresourcemanager.googleapis.com)
if [ "$ENV" = "prod" ]; then
  APIS+=(cloudscheduler.googleapis.com secretmanager.googleapis.com)
fi
APIS+=(billingbudgets.googleapis.com)
log "Habilitando APIs"
gcloud services enable "${APIS[@]}" --project="$PROJECT_ID"

# 3. Artifact Registry con limpieza (se conservan las últimas 3 imágenes)
if ! gcloud artifacts repositories describe finkey --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
  log "Creando repositorio de imágenes"
  gcloud artifacts repositories create finkey --repository-format=docker \
    --location="$REGION" --project="$PROJECT_ID" --description="Imágenes de FinKey"
fi
POLICY="$(mktemp)"
cat > "$POLICY" <<'EOF'
[
  {"name": "keep-last-3", "action": {"type": "Keep"}, "mostRecentVersions": {"keepCount": 3}},
  {"name": "delete-rest", "action": {"type": "Delete"}, "condition": {"tagState": "any"}}
]
EOF
gcloud artifacts repositories set-cleanup-policies finkey --location="$REGION" \
  --project="$PROJECT_ID" --policy="$POLICY" --no-dry-run >/dev/null
rm -f "$POLICY"

# 4. Cuentas de servicio
ensure_sa() {
  local name="$1" display="$2"
  gcloud iam service-accounts describe "$name@$PROJECT_ID.iam.gserviceaccount.com" \
    --project="$PROJECT_ID" >/dev/null 2>&1 ||
    gcloud iam service-accounts create "$name" --display-name="$display" --project="$PROJECT_ID"
}
ensure_sa finkey-deployer "FinKey CI deployer"
ensure_sa finkey-runtime "FinKey Cloud Run runtime"
DEPLOYER="finkey-deployer@$PROJECT_ID.iam.gserviceaccount.com"
RUNTIME="finkey-runtime@$PROJECT_ID.iam.gserviceaccount.com"

bind() { gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="$1" --role="$2" --condition=None >/dev/null; }
log "Permisos del deployer (mínimo privilegio)"
bind "serviceAccount:$DEPLOYER" roles/run.admin
bind "serviceAccount:$DEPLOYER" roles/artifactregistry.writer
gcloud iam service-accounts add-iam-policy-binding "$RUNTIME" --project="$PROJECT_ID" \
  --member="serviceAccount:$DEPLOYER" --role=roles/iam.serviceAccountUser >/dev/null

if [ "$ENV" = "prod" ]; then
  ensure_sa finkey-scheduler "FinKey Cloud Scheduler invoker"
  bind "serviceAccount:$RUNTIME" roles/secretmanager.secretAccessor
fi

# 5. Workload Identity Federation (GitHub Actions sin llaves JSON)
if ! gcloud iam workload-identity-pools describe github --location=global --project="$PROJECT_ID" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools create github --location=global \
    --project="$PROJECT_ID" --display-name="GitHub Actions"
fi
CONDITION="assertion.repository=='$REPO' && assertion.environment=='$GH_ENV'"
if [ "$ENV" = "prod" ]; then
  CONDITION="$CONDITION && assertion.ref.startsWith('refs/tags/v')"
fi
PROVIDER_ARGS=(--location=global --project="$PROJECT_ID" --workload-identity-pool=github
  --issuer-uri="https://token.actions.githubusercontent.com"
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.environment=assertion.environment"
  --attribute-condition="$CONDITION")
if gcloud iam workload-identity-pools providers describe github --location=global \
     --project="$PROJECT_ID" --workload-identity-pool=github >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers update-oidc github "${PROVIDER_ARGS[@]}" >/dev/null
else
  gcloud iam workload-identity-pools providers create-oidc github "${PROVIDER_ARGS[@]}" \
    --display-name="GitHub"
fi
gcloud iam service-accounts add-iam-policy-binding "$DEPLOYER" --project="$PROJECT_ID" \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github/attribute.repository/$REPO" >/dev/null

# 6. Presupuesto de la billing account (una sola vez; alerta al 50, 90 y 100 %)
BUDGET_NAME="finkey-budget-${BUDGET_USD}usd"
if ! gcloud billing budgets list --billing-account="$BILLING_ACCOUNT" --project="$PROJECT_ID" \
     --format='value(displayName)' 2>/dev/null | grep -qx "$BUDGET_NAME"; then
  log "Creando presupuesto de $BUDGET_USD USD"
  gcloud billing budgets create --billing-account="$BILLING_ACCOUNT" --display-name="$BUDGET_NAME" \
    --budget-amount="${BUDGET_USD}USD" \
    --threshold-rule=percent=0.5 --threshold-rule=percent=0.9 --threshold-rule=percent=1.0 \
    --project="$PROJECT_ID" >/dev/null
fi

log "Listo. Valores públicos para GitHub (Environment $GH_ENV):"
echo "GCP_PROJECT_ID=$PROJECT_ID"
echo "GCP_REGION=$REGION"
echo "GCP_DEPLOYER_SA=$DEPLOYER"
echo "GCP_RUNTIME_SA=$RUNTIME"
echo "GCP_WIF_PROVIDER=projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github"
