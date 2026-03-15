# Barkeep Installer — Claude Code Status Bar
# Usage: powershell -c "irm https://raw.githubusercontent.com/sky-salsa/barkeep/main/install.ps1 | iex"

$ErrorActionPreference = "Stop"

$repo = "https://raw.githubusercontent.com/sky-salsa/barkeep/main"
$installDir = Join-Path $HOME ".claude" "extensions" "barkeep"
$settingsPath = Join-Path $HOME ".claude" "settings.json"

$files = @("statusline.py", "objective-hook.py", "set-objective.py")

Write-Host ""
Write-Host "=== Barkeep — Claude Code Status Bar ===" -ForegroundColor Cyan
Write-Host ""

# Check for Python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "ERROR: Python 3 is required but not found in PATH." -ForegroundColor Red
    Write-Host "Install Python from https://python.org and try again."
    exit 1
}

# Create install directory
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "Created $installDir" -ForegroundColor Green
}

# Download files
foreach ($file in $files) {
    $url = "$repo/$file"
    $dest = Join-Path $installDir $file
    Write-Host "Downloading $file..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    } catch {
        Write-Host "ERROR: Failed to download $file from $url" -ForegroundColor Red
        Write-Host $_.Exception.Message
        exit 1
    }
}

# Build the commands with proper paths
$statuslineCmd = "python `"$($installDir -replace '\\','/')/statusline.py`""
$hookCmd = "python `"$($installDir -replace '\\','/')/objective-hook.py`" 2>/dev/null || true"

# Read or create settings.json
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    Write-Host "Updating existing settings.json..." -ForegroundColor Gray
} else {
    # Ensure .claude directory exists
    $claudeDir = Join-Path $HOME ".claude"
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }
    $settings = [PSCustomObject]@{}
    Write-Host "Creating new settings.json..." -ForegroundColor Gray
}

# Set statusLine
$settings | Add-Member -NotePropertyName "statusLine" -NotePropertyValue ([PSCustomObject]@{
    type = "command"
    command = $statuslineCmd
}) -Force

# Set hooks — preserve existing hooks, add/update UserPromptSubmit
if (-not ($settings.PSObject.Properties.Name -contains "hooks")) {
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{}) -Force
}

$barkeepHook = [PSCustomObject]@{
    hooks = @(
        [PSCustomObject]@{
            type = "command"
            command = $hookCmd
        }
    )
}

$settings.hooks | Add-Member -NotePropertyName "UserPromptSubmit" -NotePropertyValue @($barkeepHook) -Force

# Write settings back
$json = $settings | ConvertTo-Json -Depth 10
Set-Content -Path $settingsPath -Value $json -Encoding UTF8

Write-Host ""
Write-Host "Barkeep installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Restart Claude Code to see your new status bar." -ForegroundColor Cyan
Write-Host ""
