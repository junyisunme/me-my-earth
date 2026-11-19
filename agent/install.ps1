# ME Agent · install (Windows)
# Installs a versioned copy and never deletes an existing me-agent directory.

$ErrorActionPreference = "Stop"
$version = "0.5.0"
$expectedSha256 = "d45d0988aa09f557c46cd65ab895cd0a77ca84d3a083268f68496678a6ba6ba1"
$dest = Join-Path $env:USERPROFILE "me-agent-$version"
$zip = Join-Path $env:TEMP "me-agent-$version.zip"
$url = "https://github.com/junyisunme/me-my-earth/releases/download/v$version/me-agent-$version.zip"

Write-Host "Downloading me-agent $version..."
Invoke-WebRequest -Uri $url -OutFile $zip

$actualSha256 = (Get-FileHash -Path $zip -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $expectedSha256) {
  Remove-Item $zip -Force
  throw "SHA-256 mismatch for me-agent-$version.zip. Expected $expectedSha256, got $actualSha256."
}
Write-Host "SHA-256 verified."

$tmp = Join-Path $env:TEMP ("me-agent-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
  $source = Join-Path $tmp "me-agent-$version"
  if (-not (Test-Path (Join-Path $source "me-agent.mjs"))) {
    throw "Unexpected ZIP layout: me-agent-$version/me-agent.mjs was not found."
  }

  # Copy over the versioned program directory without deleting user outputs.
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Path (Join-Path $source "*") -Destination $dest -Recurse -Force
  Push-Location $dest
  if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install
  } elseif (Get-Command pnpm -ErrorAction SilentlyContinue) {
    pnpm install
  } else {
    throw "Neither npm nor pnpm was found. Install Node.js 24+ and try again."
  }
  Pop-Location
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item $zip -Force -ErrorAction SilentlyContinue
}

Write-Host "Installed to $dest"
Write-Host "Existing files in $dest (including .mezip, PNG and media) were not deleted."
Write-Host "Try: node `"$dest\me-agent.mjs`" help"
