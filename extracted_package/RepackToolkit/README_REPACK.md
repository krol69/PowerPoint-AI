# Repack Toolkit - README

## Purpose

This toolkit repacks the Canvas App source files into a valid `.msapp` file using the official Microsoft Power Platform CLI. This ensures the output file can be imported into any Power Apps environment.

---

## Prerequisites

1. **Windows 10/11** with PowerShell 5.1+
2. **Power Platform CLI (pac)** - Install one of these ways:
   - Download from: https://aka.ms/PowerAppsCLI
   - Or via .NET: `dotnet tool install --global Microsoft.PowerApps.CLI.Tool`

---

## Quick Start (5 Steps)

1. **Extract this ZIP** to a folder (e.g., `C:\CrossDivProjectDB\`)

2. **Install Power Platform CLI** if not already installed:
   ```
   dotnet tool install --global Microsoft.PowerApps.CLI.Tool
   ```

3. **Open Command Prompt** in the extracted folder

4. **Navigate to RepackToolkit** and run the script:
   ```
   cd RepackToolkit
   repack.cmd
   ```
   Or double-click `repack.cmd` in File Explorer.

5. **Find the output** in `/CanvasApp/CrossDivProjectDB_REPACKED.msapp`

---

## What the Script Does

1. Verifies Power Platform CLI is installed
2. Checks all required source files exist in `/CanvasSource/`
3. Runs `pac canvas pack` to create a valid `.msapp`
4. Outputs to `/CanvasApp/CrossDivProjectDB_REPACKED.msapp`

---

## Manual Alternative

If the script fails, run this command manually:

```powershell
pac canvas pack --msapp ".\CanvasApp\CrossDivProjectDB_REPACKED.msapp" --sources ".\CanvasSource"
```

---

## After Repacking

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Navigate to **Apps** → **Import canvas app**
3. Upload the `.msapp` file
4. Follow `POST_IMPORT_CHECKLIST.md` for setup

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `pac not found` | Install Power Platform CLI (see Prerequisites) |
| `Execution policy` error | Run: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass` |
| `Access denied` | Run Command Prompt as Administrator |
| Pack fails with errors | Check YAML syntax in `/CanvasSource/Src/` files |

---

## File Structure

```
/
├── CanvasApp/
│   └── CrossDivProjectDB_REPACKED.msapp  (OUTPUT - created by script)
├── CanvasSource/
│   ├── Header.json
│   ├── Properties.json
│   ├── Src/
│   │   ├── App.fx.yaml
│   │   ├── scrHome.fx.yaml
│   │   └── ... (other screens)
│   ├── Connections/
│   ├── Entropy/
│   └── pkgs/
├── RepackToolkit/
│   ├── repack.ps1        (main script)
│   ├── repack.cmd        (Windows wrapper)
│   └── README_REPACK.md  (this file)
└── POST_IMPORT_CHECKLIST.md
```
