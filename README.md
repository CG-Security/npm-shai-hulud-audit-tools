# npm Shai-Hulud Audit Tools

This repository contains PowerShell scripts and documentation to help detect
potential impact from the Shai-Hulud / Sha1-Hulud npm supply-chain campaign.

The goal is to answer two questions:

1. Does this endpoint have **Node.js / npm** installed?
2. If yes, did any **Node.js project** on this endpoint install a **known malicious package**?

## Contents

- `scripts/Detect-NodeNpm.ps1`  
  Local detection script that checks whether Node.js and npm are present.

- `scripts/Scan-NpmPackagesFromCsv.ps1`  
  Scans all Node projects under a given root path (e.g. `C:\Projects`) and
  compares `package.json` / `package-lock.json` against a CSV of known
  malicious packages (e.g. from Wiz, GitHub, or other threat intel).

- `docs/incident-summary.md`  
  High-level explanation of the campaign and how these scripts fit into a
  response workflow.

## Usage Overview

### 1. Detect Node.js / npm locally

From an elevated or normal PowerShell session (as appropriate):

```powershell
.\scripts\Detect-NodeNpm.ps1
