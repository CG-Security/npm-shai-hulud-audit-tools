# Shai-Hulud / Sha1-Hulud npm Supply-Chain Campaign – Summary

This document provides a high-level overview of the Shai-Hulud / Sha1-Hulud npm supply-chain campaign and explains how the scripts in this repository support investigation and triage efforts.

---

## What Is This Campaign?

The Shai-Hulud attack is a large-scale **npm supply-chain compromise** where malicious actors published or modified npm packages to include harmful code. These packages could exfiltrate credentials, attack developer environments, or spread by abusing stolen authentication tokens.

In other words: attackers managed to slip malicious packages into the npm ecosystem, and any machine installing them could be compromised.

---

## Objectives of This Repository

These tools help answer:

1. **Does this endpoint have Node.js/npm installed?**  
   If not, it cannot be affected by npm packages.

2. **If yes, did any project install a known malicious package?**  
   This is determined by scanning `package.json` and `package-lock.json` files against a CSV of known bad packages.

The scripts help with **detection, discovery, and scoping**—they do *not* replace full incident response or EDR capabilities.

---

## Typical Workflow

### 1. **Discovery (Scope Identification)**  
Run:

```powershell
.\scripts\Detect-NodeNpm.ps1
```

If Node.js/npm are not installed, the device is out-of-scope for this npm-specific campaign.

### 2. **Triage (Endpoints Where npm *Is* Installed)**  
- Download a threat-intel CSV of known malicious npm packages (e.g., Wiz or GitHub advisories).
- Save it locally, e.g.:

```
C:\Security\shai-hulud-packages.csv
```

- Scan the developer project directory, e.g.:

```powershell
.\scripts\Scan-NpmPackagesFromCsv.ps1 `
    -CsvPath 'C:\Security\shai-hulud-packages.csv' `
    -RootPath 'C:\Projects'
```

### 3. **Interpretation**
- **Clean** → No known malicious packages detected  
- **SUSPICIOUS** → Known malicious package name detected in the project  
  - Clear npm cache  
  - Delete `node_modules`  
  - Reinstall clean  
  - Rotate exposed credentials  
  - Check CI/CD systems and logs  
  - Follow internal IR procedures

---

## Important Notes

- These scripts **only scan for package names** known to be malicious (from your CSV).  
- They do **not** detect modified or zero-day malicious packages.  
- They do **not** upload, delete, or modify anything on the machine.  
- They are meant for **triage**, to support the broader IR process.

---

## Why This Matters

Supply-chain attacks rely on compromised dependencies—meaning a malicious package can bypass traditional defenses by appearing trusted.

These scripts give teams a fast way to determine:

- Which machines need deeper attention  
- Which projects may have pulled malicious dependencies  
- Which endpoints are not affected at all  

This dramatically reduces noise and helps you focus IR efforts where they’re truly needed.

---

If you need help expanding this document or creating executive-level reporting summaries, let me know.
