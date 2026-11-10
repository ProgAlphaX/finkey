using Xunit;
using ArchUnitNET.Domain;
using ArchUnitNET.Loader;
using ArchUnitNET.xUnitV3;
using ArchUnitNET.Fluent.Syntax.Elements.Types;
using static ArchUnitNET.Fluent.ArchRuleDefinition;
using Arch = ArchUnitNET.Domain.Architecture;

namespace FinKey.ArchitectureTests;

public class SolutionDependencyTests
{
    private static readonly Arch Architecture = new ArchLoader()
        .LoadAssemblies(
            typeof(SharedKernel.AssemblyMarker).Assembly,
            typeof(BuildingBlocks.AssemblyMarker).Assembly,
            typeof(Host.AssemblyMarker).Assembly,
            typeof(Migrator.Program).Assembly)
        .Build();

    private static GivenTypesConjunctionWithDescription In(string ns) =>
        Types().That().ResideInNamespaceMatching($@"^FinKey\.{ns}(\..*)?$").As(ns);

    [Fact]
    public void SharedKernel_does_not_depend_on_other_projects() =>
        Types().That().Are(In("SharedKernel")).Should()
            .NotDependOnAnyTypesThat().Are(In("BuildingBlocks"))
            .AndShould().NotDependOnAnyTypesThat().Are(In("Host"))
            .AndShould().NotDependOnAnyTypesThat().Are(In("Migrator"))
            .Check(Architecture);

    [Fact]
    public void BuildingBlocks_does_not_depend_on_Host_or_Migrator() =>
        Types().That().Are(In("BuildingBlocks")).Should()
            .NotDependOnAnyTypesThat().Are(In("Host"))
            .AndShould().NotDependOnAnyTypesThat().Are(In("Migrator"))
            .Check(Architecture);

    [Fact]
    public void Migrator_does_not_depend_on_Host() =>
        Types().That().Are(In("Migrator")).Should()
            .NotDependOnAnyTypesThat().Are(In("Host"))
            .Check(Architecture);
}


