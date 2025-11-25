<#
.SYNOPSIS
Detects whether Node.js and npm are installed on the local machine.

.DESCRIPTION
- Checks for Node.js via PATH and common installation paths.
- Checks for npm via Get-Command.
- Intended for discovery/scoping in npm-related supply-chain incidents
  (e.g., determining which endpoints are in-scope for npm-based attacks).
#>

Write-Host "=== Node.js / npm Presence Check ===" -ForegroundColor Cyan

# --- Check Node.js via PATH ---
$nodeFromPath = Get-Command node -ErrorAction SilentlyContinue

# --- Check common Node.js install locations ---
$possibleNodePaths = @(
    "$env:ProgramFiles\nodejs\node.exe",
    "$env:ProgramFiles(x86)\nodejs\node.exe"
)

$nodeFromDisk = $possibleNodePaths | Where-Object { Test-Path $_ }

if ($nodeFromPath -or $nodeFromDisk) {
    Write-Host "`n[+] Node.js appears to be installed." -ForegroundColor Green

    if ($nodeFromPath) {
        Write-Host "    - Found in PATH as: $($nodeFromPath.Source)"
    }

    if ($nodeFromDisk) {
        Write-Host "    - Found on disk at:"
        $nodeFromDisk | ForEach-Object {
            Write-Host "      $_"
        }
    }
} else {
    Write-Host "`n[-] Node.js does not appear to be installed." -ForegroundColor Yellow
}

# --- Check npm via PATH ---
$npmFromPath = Get-Command npm -ErrorAction SilentlyContinue

if ($npmFromPath) {
    Write-Host "`n[+] npm appears to be installed." -ForegroundColor Green
    Write-Host "    - Found in PATH as: $($npmFromPath.Source)"
} else {
    Write-Host "`n[-] npm does not appear to be installed." -ForegroundColor Yellow
}

Write-Host "`nCheck complete." -ForegroundColor Cyan
