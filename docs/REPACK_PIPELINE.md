# Repack Pipeline - Complete Instructions

## Why Your Original Import Failed

**Root Cause:** You attempted to import the `CanvasSource/` folder (or the ZIP itself) directly as if it were a `.msapp` file.

**The Reality:**
- Power Apps "Import canvas app" expects a **compiled `.msapp` binary file**
- Your package contains **Canvas Source format** (unpacked YAML/JSON files)
- Canvas Source must be **repacked** using the Power Platform CLI before importing

---

## Solution: Repack Pipeline

### Method 1: Using Power Platform CLI (Recommended)

#### Prerequisites

Install the Power Platform CLI (one of these methods):

```bash
# Option A: Download installer
# Visit: https://aka.ms/PowerAppsCLI

# Option B: Via .NET
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Option C: Via npm
npm install -g pac
```

Verify installation:
```bash
pac --version
# Expected: 1.33.x or higher
```

#### Repack Command

```powershell
# Navigate to extracted package root
cd C:\path\to\CrossDivProjectDB_Import_Package

# Create output directory
mkdir -p CanvasApp

# Pack the canvas source into .msapp
pac canvas pack `
    --msapp ".\CanvasApp\CrossDivProjectDB.msapp" `
    --sources ".\CanvasSource"
```

**Expected output:**
```
Packing Canvas app...
Completed successfully.
```

**Verify the output:**
```powershell
dir .\CanvasApp\
# Should show: CrossDivProjectDB.msapp (typically 40-150 KB)
```

---

### Method 2: Using Included Scripts

The package includes repack scripts in `/RepackToolkit/`:

#### Windows (PowerShell)

```powershell
# Navigate to RepackToolkit folder
cd C:\path\to\CrossDivProjectDB_Import_Package\RepackToolkit

# Run the PowerShell script
.\repack.ps1
```

**If you get an execution policy error:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
.\repack.ps1
```

#### Windows (CMD)

```cmd
cd C:\path\to\CrossDivProjectDB_Import_Package\RepackToolkit
repack.cmd
```

**Output location:** `.\CanvasApp\CrossDivProjectDB_REPACKED.msapp`

---

## Validation Steps

After repacking, verify the `.msapp` is valid:

### 1. Check File Size
```powershell
Get-Item .\CanvasApp\CrossDivProjectDB.msapp | Select-Object Name, Length

# Expected: 40-150 KB (not 0 KB)
```

### 2. Check ZIP Structure
The `.msapp` is actually a ZIP file:
```powershell
# Rename to .zip and inspect
Copy-Item .\CanvasApp\CrossDivProjectDB.msapp .\CanvasApp\test.zip
Expand-Archive .\CanvasApp\test.zip -DestinationPath .\CanvasApp\test_extract

dir .\CanvasApp\test_extract
# Should contain: Header.json, Properties.json, ControlTemplates/, etc.

# Cleanup
Remove-Item .\CanvasApp\test.zip
Remove-Item .\CanvasApp\test_extract -Recurse
```

### 3. Test Import in Power Apps
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Click **Apps** → **Import canvas app**
3. Click **Upload** and select `CrossDivProjectDB.msapp`
4. Click **Import**
5. Should show "Import successful" with app listed

---

## Importing the .msapp

### Step-by-Step Import

1. **Navigate to Power Apps**
   - Go to [make.powerapps.com](https://make.powerapps.com)
   - Select your environment

2. **Import Canvas App**
   - Click **Apps** in left nav
   - Click **Import canvas app** (top menu)
   - Click **Upload** button
   - Select your `CrossDivProjectDB.msapp` file
   - Wait for upload (progress indicator)

3. **Configure Import**
   - Review the app name (can rename)
   - For "IMPORT SETUP" options:
     - **Create as new** — imports as new app
   - Click **Import**

4. **Post-Import**
   - Wait for import completion
   - Click the app name to open in Edit mode
   - Add your Dataverse connections
   - Follow `POST_IMPORT_CHECKLIST.md`

---

## Importing as Solution (Alternative)

If you want to import as a managed solution:

### 1. Create a Solution (Manual)

1. Go to [make.powerapps.com](https://make.powerapps.com) → **Solutions**
2. Click **+ New solution**
3. Enter:
   - Display name: `CrossDiv Project Database`
   - Publisher: Select or create one
4. Click **Create**
5. Open the solution → **Add existing** → **App** → **Canvas app**
6. Select the imported app
7. Click **Export** → **Unmanaged**

### 2. Import Solution

If you have a pre-made solution ZIP:
1. Go to **Solutions** → **Import solution**
2. Upload the `.zip` file
3. Click **Next** → **Import**

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| `pac not found` | Install Power Platform CLI |
| `Execution policy` error | Run: `Set-ExecutionPolicy -Scope CurrentUser Bypass` |
| `Access denied` | Run PowerShell as Administrator |
| `Pack failed with YAML error` | Check for syntax issues in `.fx.yaml` files |
| `0 KB output file` | Verify `CanvasSource/` path is correct |
| "Error opening file" on import | File is corrupted or not a valid .msapp |
| "Missing connection" after import | Add Dataverse tables as data sources |

---

## File Structure Reference

**Before Repack:**
```
CrossDivProjectDB_Import_Package/
├── CanvasSource/           ← Source files
│   ├── Header.json
│   ├── Properties.json
│   ├── Src/
│   │   ├── App.fx.yaml
│   │   └── scr*.fx.yaml
│   ├── Connections/
│   ├── Entropy/
│   └── pkgs/
├── RepackToolkit/
│   ├── repack.ps1
│   └── repack.cmd
├── CanvasApp/              ← Output folder
└── POST_IMPORT_CHECKLIST.md
```

**After Repack:**
```
CrossDivProjectDB_Import_Package/
├── CanvasApp/
│   └── CrossDivProjectDB.msapp  ← THIS IS YOUR IMPORT FILE
└── ...
```

---

## Quick Reference Commands

```powershell
# Full repack (one-liner)
pac canvas pack --msapp ".\CanvasApp\CrossDivProjectDB.msapp" --sources ".\CanvasSource"

# Unpack (for editing)
pac canvas unpack --msapp ".\CanvasApp\CrossDivProjectDB.msapp" --sources ".\CanvasSource_New"

# Check PAC version
pac --version

# Auth to Power Platform (if needed for other commands)
pac auth create
```

---

*Generated for Cross-Divisional Project Database v2.1*
