<#
.SYNOPSIS
Scans Node.js projects for known-bad npm packages using a CSV list.

.DESCRIPTION
- Loads a CSV containing malicious npm package names.
- Recursively discovers Node projects under a given root path by locating
  `package.json`.
- For each project, scans `package.json` and `package-lock.json` for any
  package names listed in the CSV.
- Prints a per-project result: Clean vs SUSPICIOUS.

.PARAMETER CsvPath
Path to the CSV file containing known-bad npm packages.
Expected to have a "Package" column with npm package names.

.PARAMETER RootPath
Root directory where developer projects live (e.g. `C:\Projects`).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [Parameter(Mandatory = $true)]
    [string]$RootPath
)

Write-Host "=== npm Shai-Hulud Package Scan ===" -ForegroundColor Cyan

# --- Validate CSV path ---
if (-not (Test-Path $CsvPath)) {
    Write-Host "ERROR: CSV file not found at $CsvPath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading known-bad packages from: $CsvPath" -ForegroundColor Cyan
$badList = Import-Csv -Path $CsvPath

if (-not $badList) {
    Write-Host "ERROR: CSV appears to be empty." -ForegroundColor Red
    exit 1
}

# --- Use the 'Package' column explicitly ---
$packageColumn = 'Package'

if (-not ($badList | Get-Member -Name $packageColumn -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Could not find a '$packageColumn' column in the CSV." -ForegroundColor Red
    exit 1
}

$badPackages = $badList.$packageColumn |
    Where-Object { $_ -and $_.Trim() -ne '' } |
    Sort-Object -Unique

Write-Host "Loaded $($badPackages.Count) known-bad package names from CSV." -ForegroundColor Cyan

if (-not $badPackages) {
    Write-Host "ERROR: No package names loaded from CSV. Aborting." -ForegroundColor Red
    exit 1
}

# --- Validate RootPath ---
if (-not (Test-Path $RootPath)) {
    Write-Host "ERROR: Root path '$RootPath' does not exist." -ForegroundColor Red
    exit 1
}

Write-Host "Searching for Node projects under: $RootPath" -ForegroundColor Cyan

# Discover Node projects by finding package.json
$projects = Get-ChildItem -Path $RootPath -Recurse -Filter package.json -ErrorAction SilentlyContinue

if (-not $projects) {
    Write-Host "No package.json files found under $RootPath. No Node projects detected." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($projects.Count) Node project(s) under $RootPath." -ForegroundColor Cyan

# --- Scan each project ---
foreach ($proj in $projects) {
    $projectPath = $proj.Directory.FullName
    Write-Host "`n==== Scanning project: $projectPath ====" -ForegroundColor Cyan

    # Files to scan: package.json and package-lock.json (if present)
    $filesToScan = @(
        (Join-Path $projectPath "package.json"),
        (Join-Path $projectPath "package-lock.json")
    ) | Where-Object { Test-Path $_ }

    if (-not $filesToScan) {
        Write-Host "No package.json or package-lock.json found. Skipping." -ForegroundColor DarkYellow
        continue
    }

    # Search for any known-bad package names in these files
    $matches = Select-String -Path $filesToScan -Pattern $badPackages -SimpleMatch -ErrorAction SilentlyContinue

    if ($matches) {
        Write-Host ">>> SUSPICIOUS: Known-bad package name(s) detected in this project!" -ForegroundColor Red
        $matches |
            Select-Object Path, LineNumber, Line |
            ForEach-Object {
                Write-Host ("[{0}:{1}] {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim()) -ForegroundColor Red
            }
    } else {
        Write-Host "Clean. No known-bad packages found in this project." -ForegroundColor Green
    }
}

Write-Host "`nScan complete." -ForegroundColor Cyan
