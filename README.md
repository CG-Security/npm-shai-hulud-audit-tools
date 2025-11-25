# npm Shai-Hulud Audit Tools

This repository contains PowerShell scripts and documentation to help detect whether Windows endpoints may be affected by the **Shai-Hulud / Sha1-Hulud** npm supply-chain campaign.

The goal is to answer two questions:

1. Does this machine have **Node.js / npm installed**?  
2. If yes, do any Node.js projects contain **known malicious npm packages**?

---

## Repository Structure

```
scripts/
├─ Detect-NodeNpm.ps1
└─ Scan-NpmPackagesFromCsv.ps1

docs/
└─ incident-summary.md
```

---

## 1. Detect Node.js / npm

Use this script to determine whether the machine is even in-scope for npm-based supply-chain attacks.

Run:

```powershell
.\scripts\Detect-NodeNpm.ps1
```

This script reports:

- Whether Node.js is installed  
- Whether npm is installed  
- Where they are located (PATH and common install directories)

If the machine does **not** have Node.js or npm installed, it cannot be impacted by npm packages and is considered **out-of-scope** for this campaign.

---

## 🛡 2. Scan Projects for Known Malicious Packages (CSV-Based)

Before scanning, save your threat-intel CSV locally, for example:

```
C:\Security\shai-hulud-packages.csv
```

Then run:

```powershell
.\scripts\Scan-NpmPackagesFromCsv.ps1 `
    -CsvPath 'C:\Security\shai-hulud-packages.csv' `
    -RootPath 'C:\Projects'
```

This script will:

- Recursively locate all `package.json` files under the root path  
- Scan each project’s `package.json` and `package-lock.json`  
- Search for any package names that appear in the malicious package CSV  
- Clearly mark each project as **Clean** or **SUSPICIOUS**

The script is **read-only**. It does not modify any files or upload data.

---

### 📄 Where do I get the CSV?

This script does **not** download threat intelligence automatically.  
You must provide a CSV file that contains known malicious npm package names.

Valid sources include:

- Threat-intel exports from vendors (e.g., Wiz, GitHub security advisories)
- Internal SOC/IR–generated malicious package lists
- Community-maintained intel feeds

The only requirement is that the CSV includes a **`Package`** column listing npm package names.  
The script is vendor-agnostic and will use whatever list you provide.

---

## Additional Documentation

A high-level summary of the Shai-Hulud campaign and how these tools support triage:

- [`docs/incident-summary.md`](docs/incident-summary.md)

---

## Disclaimer

These scripts:

- Do **not** alter project files  
- Do **not** transmit data  
- Are intended for **triage and discovery only**  
- Should be used alongside SIEM searches, EDR results, and standard IR processes

Use these tools responsibly and verify CSV contents from trusted threat intelligence sources.
