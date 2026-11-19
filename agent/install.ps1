# ME Agent · install (Windows)

$ErrorActionPreference = "Stop"
$version = "0.3.0"
$zip = Join-Path $env:TEMP "me-agent-$version.zip"
$root = Join-Path $env:USERPROFILE "me-agent"
$url = "https://github.com/junyisunme/me-my-earth/releases/download/v$version/me-agent-$version.zip"

Invoke-WebRequest -Uri $url -OutFile $zip
if (Test-Path $root) { Remove-Item $root -Recurse -Force }
$parent = Split-Path $root
$extracted = Join-Path $parent "me-agent-$version"
if (Test-Path $extracted) { Remove-Item $extracted -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $parent -Force
Move-Item $extracted $root
Push-Location $root
npm install
Pop-Location
Write-Host "Installed to $root"
Write-Host "Try: node `"$root\me-agent.mjs`" help"
