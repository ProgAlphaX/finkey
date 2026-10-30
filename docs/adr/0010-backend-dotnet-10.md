# ADR-0010: Backend en .NET 10

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Baja ⚠️

## Contexto
Los candidatos son .NET 10 (el stack dominado) y Spring Boot (en aprendizaje). Los drivers son la mantenibilidad y el *scale-to-zero* con costo $0, donde el arranque en frío y el consumo de memoria importan.

## Opciones consideradas
1. **.NET 10 LTS**: puntaje 141/145 en la matriz (`04-tech-stack.md` §1).
2. **Spring Boot + Java 25 LTS**: puntaje 117/145. Tiene más valor de aprendizaje, pero la JVM arranca más lento y consume más memoria; GraalVM native lo mitiga a costa de complejidad.

## Decisión
**.NET 10 LTS** con ASP.NET Core Minimal APIs. Los casos de uso usan handlers propios inyectados directamente, por dependencias explícitas y no por licencia (MediatR Community sería gratis para nosotros). El mapeo usa Mapperly y las aserciones de los tests, FluentAssertions v8 (uso no comercial).

## Consecuencias
- Positivas: productividad inmediata; arranque rápido y poca memoria (encaja con los free tiers); soporte hasta noviembre de 2028.
- Negativas: este proyecto no aporta práctica de Spring Boot.
- Qué haría reconsiderar esta decisión: ninguna razón previsible en el horizonte del proyecto.
