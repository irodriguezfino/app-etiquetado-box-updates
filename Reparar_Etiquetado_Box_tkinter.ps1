param(
    [string]$InstallDir = "",
    [switch]$NoStart
)

$ErrorActionPreference = "Stop"

$AppName = "Etiquetado Box Salazon"
$AppExe = "Etiquetado_Box_Salazon.exe"
$ManifestUrl = "https://raw.githubusercontent.com/irodriguezfino/app-etiquetado-box-updates/main/version.json"

if (-not $InstallDir) {
    $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\Etiquetado Box Salazon"
}
$InstallDir = [System.IO.Path]::GetFullPath($InstallDir)

if (-not (Test-Path -LiteralPath $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

function Normalize-RelPath {
    param([string]$Path)
    return (($Path -replace "\\", "/").Trim("/"))
}

$Preserve = @(
    "config_usuario.json",
    "config/plantilla_etiqueta.json",
    "config/backups",
    "config/editor_password.txt",
    "exportaciones",
    "logs",
    "_backups"
)

function Test-Preserved {
    param([string]$RelPath)
    $rel = Normalize-RelPath $RelPath
    foreach ($item in $Preserve) {
        if ($rel -eq $item -or $rel.StartsWith($item + "/")) {
            return $true
        }
    }
    return $false
}

function Copy-Overlay {
    param(
        [string]$Source,
        [string]$Destination
    )

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    $arguments = @(
        $Source,
        $Destination,
        "/E",
        "/NFL",
        "/NDL",
        "/NJH",
        "/NJS",
        "/NP",
        "/XF",
        "config_usuario.json",
        "plantilla_etiqueta.json",
        "editor_password.txt",
        "/XD",
        "backups",
        "exportaciones",
        "logs",
        "_backups"
    )
    & robocopy @arguments | Out-Null
    $code = $LASTEXITCODE
    if ($code -ge 8) {
        throw "Robocopy fallo con codigo $code."
    }
}

Write-Host "Reparando $AppName en: $InstallDir"

Get-Process -Name "Etiquetado_Box_Salazon" -ErrorAction SilentlyContinue | Stop-Process -Force

$workDir = Join-Path $env:TEMP ("etiquetado_box_repair_" + [Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $workDir "update.zip"
$stageDir = Join-Path $workDir "stage"

try {
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    $manifest = Invoke-RestMethod -Uri ($ManifestUrl + "?repair=" + [DateTimeOffset]::Now.ToUnixTimeSeconds()) -UseBasicParsing
    $package = $manifest.packages | Where-Object { $_.kind -eq "full" } | Select-Object -First 1
    if (-not $package) {
        throw "El manifiesto remoto no contiene paquete full."
    }

    Write-Host "Descargando $($package.file)..."
    Invoke-WebRequest -Uri ($package.url + "?repair=" + [DateTimeOffset]::Now.ToUnixTimeSeconds()) -OutFile $zipPath -UseBasicParsing

    Write-Host "Extrayendo actualizacion..."
    Expand-Archive -LiteralPath $zipPath -DestinationPath $stageDir -Force

    Write-Host "Copiando archivos sin sobrescribir configuracion editable..."
    Copy-Overlay -Source $stageDir -Destination $InstallDir

    $tkinterPath = Join-Path $InstallDir "_internal\tkinter\__init__.py"
    if (-not (Test-Path -LiteralPath $tkinterPath)) {
        throw "La reparacion no encontro _internal\tkinter despues de copiar."
    }

    Write-Host "Reparacion completada correctamente."
    if (-not $NoStart) {
        Start-Process -FilePath (Join-Path $InstallDir $AppExe) -WorkingDirectory $InstallDir
    }
} finally {
    Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
}
