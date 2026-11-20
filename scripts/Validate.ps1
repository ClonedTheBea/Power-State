param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    New-Item -ItemType Directory -Force -Path '.build' | Out-Null
    foreach ($project in @('default', 'test')) {
        $config = Get-Content -Raw -LiteralPath "$project.project.json" | ConvertFrom-Json
        if ($config.tree.'$className' -ne 'DataModel') { throw 'Expected a DataModel project root.' }
        $output = if ($project -eq 'default') { '.build/PowerState.rbxlx' } else { '.build/PowerStateTests.rbxlx' }
        & rojo build "$project.project.json" -o $output
        if ($LASTEXITCODE -ne 0) { throw "Rojo build failed: $project" }
    }
    [xml]$place = Get-Content -Raw -LiteralPath '.build/PowerState.rbxlx'
    $scripts = @($place.SelectNodes('//Item[@class="Script" or @class="LocalScript" or @class="ModuleScript"]'))
    if ($scripts.Count -lt 15) { throw 'Missing expected source modules in the built place.' }
    $clientEntry = @($place.SelectNodes('//Item[@class="LocalScript"]/Properties/string[@name="Name"]') | Where-Object InnerText -eq 'Bootstrap')
    if ($clientEntry.Count -ne 1) { throw 'Expected exactly one client Bootstrap LocalScript.' }
    $remotes = @($place.SelectNodes('//Item[@class="RemoteEvent" or @class="RemoteFunction"]'))
    if ($remotes.Count -ne 0) { throw 'Proof remotes must be created only by the guarded Test server.' }
    foreach ($file in Get-ChildItem -Recurse -File src, tests -Filter '*.luau') {
        $source = Get-Content -Raw -LiteralPath $file.FullName
        if (-not $source.StartsWith('--!strict')) { throw "Missing strict mode: $($file.FullName)" }
        if ($source -match 'GetOrderedDataStore\(|InvokeServer\(' -or ($source -match 'GetDataStore\(' -and $file.FullName -notin @((Join-Path $projectRoot 'src/server/Adapters/PostBuildProofAdapter.luau'), (Join-Path $projectRoot 'src/server/Adapters/DataStoreAdapter.luau'), (Join-Path $projectRoot 'src/server/Adapters/Schema2MigrationAdapter.luau'), (Join-Path $projectRoot 'src/server/Adapters/Schema3MigrationAdapter.luau'), (Join-Path $projectRoot 'src/server/Adapters/Schema3ConstructionAdapter.luau'), (Join-Path $projectRoot 'src/server/Adapters/Schema2GameplayAdapter.luau')))) {
            throw "Unexpected future-phase service use: $($file.FullName)"
        }
        if ($source -match 'FireServer\(' -and $file.FullName -notin @((Join-Path $projectRoot 'tests/integration/OwnedFleet.spec.luau'), (Join-Path $projectRoot 'tests/integration/OperationsMultiplayer.client.luau'), (Join-Path $projectRoot 'tests/integration/OperationsRemote.spec.luau'), (Join-Path $projectRoot 'src/client/Simulation/OperationsClient.luau'), (Join-Path $projectRoot 'src/client/Simulation/SimulationClient.luau'), (Join-Path $projectRoot 'src/client/Simulation/ConstructionClient.luau'), (Join-Path $projectRoot 'tests/integration/P2aRemote.spec.luau'), (Join-Path $projectRoot 'tests/integration/FirstPlayableRemote.spec.luau'), (Join-Path $projectRoot 'tests/integration/P2b1.spec.luau'))) {
            throw "Unapproved remote sender: $($file.FullName)"
        }
    }
    $adapter = Get-Content -Raw -LiteralPath 'src/server/Adapters/DataStoreAdapter.luau'
    if ($adapter -notmatch 'local LIVE_ACCESS_APPROVED=false' -or $adapter -notmatch '10776833313' -or $adapter -notmatch 'player.UserId==149564436' -or $adapter -notmatch 'run:IsStudio\(\)') { throw 'P3a real access must remain disabled and exact-account Studio/Test guarded.' }
    $economyAdapter = Get-Content -Raw -LiteralPath 'src/server/Adapters/Schema2GameplayAdapter.luau'
    if (-not $economyAdapter.Contains('local REAL_ECONOMY_EXECUTION_APPROVED=false') -or -not $economyAdapter.Contains('assert(REAL_ECONOMY_EXECUTION_APPROVED') -or $economyAdapter.IndexOf('assert(REAL_ECONOMY_EXECUTION_APPROVED') -gt $economyAdapter.IndexOf('GetService("DataStoreService")')) { throw 'P3b.4 real economy execution must remain disabled before service access.' }
    & git diff --check
    if ($LASTEXITCODE -ne 0) { throw 'Git whitespace check failed.' }
    Write-Output "PASS: two Rojo builds, source mapping, client entrypoint, P2a persistence/remote boundary checks and Git whitespace."
    Write-Output 'This does not replace Luau Script Analysis or Studio runtime/device tests.'
} finally {
    Pop-Location
}
