# RepackToolkit - Generate .msapp from Canvas Source

## Overview

This toolkit converts the **CanvasSource** folder (YAML/JSON source files) into a compiled **.msapp** binary file that can be imported into Microsoft Power Apps.

## Why Is This Needed?

Power Apps import requires a **compiled .msapp file**, not raw YAML source files. The `.msapp` format is essentially a ZIP archive containing:
- Compiled app metadata
- Screen definitions
- Resources and assets
- Connection configurations

The Power Platform CLI (`pac`) tool performs this compilation.

---

## Prerequisites

### 1. Install Power Platform CLI

Choose one of these methods:

#### Option A: Install via .NET Tool (Recommended)

```powershell
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

#### Option B: Download Windows Installer

Visit: **https://aka.ms/PowerAppsCLI**

#### Option C: Install via winget (Windows 11+)

```cmd
winget install Microsoft.PowerAppsCLI
```

### 2. Verify Installation

After installation, open a new PowerShell or Command Prompt window and run:

```cmd
pac --version
```

You should see output like:
```
Microsoft PowerPlatform CLI
Version: 1.x.x
```

> **Note:** If `pac` is not recognized, restart your terminal or add it to your PATH.

---

## Usage

### Method 1: PowerShell Script (Recommended)

Open **PowerShell** in the package root directory and run:

```powershell
.\RepackToolkit\repack.ps1
```

For verbose output:

```powershell
.\RepackToolkit\repack.ps1 -Verbose
```

### Method 2: Batch File (Windows CMD)

Open **Command Prompt** in the package root directory and run:

```cmd
RepackToolkit\repack.cmd
```

Or simply double-click `repack.cmd` in Windows Explorer.

### Method 3: Manual PAC Command

If you prefer to run the command manually:

```cmd
pac canvas pack --msapp ".\CanvasApp\CrossDivProjectDB.msapp" --sources ".\CanvasSource"
```

---

## What the Script Does

1. **Verifies PAC CLI** is installed and working
2. **Validates CanvasSource** structure (checks for required files)
3. **Creates CanvasApp** output folder if it doesn't exist
4. **Removes old .msapp** file if present
5. **Runs pac canvas pack** to compile the source
6. **Verifies output** - checks file size and internal structure
7. **Displays next steps** for importing into Power Apps

---

## Expected Output

### Successful Run

```
╔════════════════════════════════════════════════════════════════╗
║   Power Apps Canvas Source Repacker                           ║
║   Cross-Divisional Project Database                            ║
╚════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════
 Step 1: Verifying Prerequisites
═══════════════════════════════════════════════════════════════

✓ Power Platform CLI found
  Version: Microsoft PowerPlatform CLI Version 1.x.x

═══════════════════════════════════════════════════════════════
 Step 2: Validating CanvasSource Structure
═══════════════════════════════════════════════════════════════

✓ CanvasSource folder exists
  Path: C:\Package\CanvasSource
✓ Found 11 screen files

═══════════════════════════════════════════════════════════════
 Step 3: Preparing Output Directory
═══════════════════════════════════════════════════════════════

✓ CanvasApp folder exists
  Output: C:\Package\CanvasApp\CrossDivProjectDB.msapp

═══════════════════════════════════════════════════════════════
 Step 4: Packing Canvas Source to .msapp
═══════════════════════════════════════════════════════════════

  Running PAC CLI canvas pack...
  This may take 30-60 seconds...

✓ Canvas pack completed successfully

═══════════════════════════════════════════════════════════════
 Step 5: Verifying Output
═══════════════════════════════════════════════════════════════

✓ .msapp file created successfully
  File: C:\Package\CanvasApp\CrossDivProjectDB.msapp
  Size: 156.42 KB (0.15 MB)
  Modified: 2025-12-21 10:30:45
✓ Internal structure validated (42 files)

╔════════════════════════════════════════════════════════════════╗
║   ✓ REPACK COMPLETED SUCCESSFULLY                              ║
╚════════════════════════════════════════════════════════════════╝
```

The `.msapp` file will be created in the **CanvasApp** folder.

---

## Troubleshooting

### Error: "pac is not recognized"

**Cause:** PAC CLI not installed or not in PATH

**Solution:**
1. Install PAC CLI (see Prerequisites above)
2. Restart your terminal
3. Run `pac --version` to verify

### Error: "CanvasSource folder not found"

**Cause:** Script not run from package root directory

**Solution:**
1. Open terminal in the package root (where `CanvasSource` folder is)
2. Run the script again

### Error: ".msapp file is 0 bytes"

**Cause:** Packing failed silently

**Solution:**
1. Check the PAC CLI output for errors
2. Ensure CanvasSource contains valid YAML files
3. Verify Header.json and Properties.json are not corrupted
4. Try running with `-Verbose` flag (PowerShell) to see detailed output

### Error: "Missing: Src\App.fx.yaml"

**Cause:** CanvasSource structure is incomplete

**Solution:**
1. Ensure you extracted the full package
2. Verify `CanvasSource\Src\App.fx.yaml` exists
3. Re-download the package if files are missing

---

## File Structure

After running the script successfully, your package should look like this:

```
CrossDivProjectDB_Package/
├── CanvasSource/              ← Source files (input)
│   ├── Src/
│   │   ├── App.fx.yaml
│   │   ├── scrHome.fx.yaml
│   │   ├── scrProjectList.fx.yaml
│   │   └── ... (other screens)
│   ├── Header.json
│   ├── Properties.json
│   ├── Entropy/
│   ├── Connections/
│   └── pkgs/
├── CanvasApp/                 ← Output folder
│   └── CrossDivProjectDB.msapp   ← Generated file (ready to import!)
├── RepackToolkit/             ← This folder
│   ├── repack.ps1
│   ├── repack.cmd
│   └── README_REPACK.md
└── Docs/                      ← Documentation
```

---

## Next Steps After Repacking

Once you have the `.msapp` file:

1. **Import into Power Apps**
   - Go to https://make.powerapps.com
   - Select your environment
   - **Apps** → **Import canvas app**
   - Upload `CanvasApp\CrossDivProjectDB.msapp`

2. **Follow the POST_IMPORT_CHECKLIST.md**
   - Create Dataverse tables
   - Configure connections
   - Update placeholders (admin email, SharePoint URL)

3. **Import Seed Data**
   - Use the CSV files in `SeedData/` folder
   - Import into Dataverse tables

---

## Advanced Usage

### Custom Output Name

PowerShell:
```powershell
.\RepackToolkit\repack.ps1 -OutputName "MyCustomApp.msapp"
```

### Skip Version Check

PowerShell:
```powershell
.\RepackToolkit\repack.ps1 -SkipVersionCheck
```

### Repack After Modifications

If you modify the CanvasSource files (e.g., change placeholders, update screens):

1. Make your changes in `CanvasSource/Src/` folder
2. Run the repack script again
3. A new `.msapp` will be generated
4. Import the new `.msapp` into Power Apps

---

## Technical Details

### What is `pac canvas pack`?

The command syntax:
```
pac canvas pack --msapp <OUTPUT_PATH> --sources <SOURCE_PATH>
```

- `--msapp`: Output path for the compiled .msapp file
- `--sources`: Input path to the CanvasSource folder

### .msapp File Format

The `.msapp` file is a ZIP archive (you can rename to `.zip` to inspect) containing:
- **Header.json** - App metadata
- **Properties.json** - App properties and settings
- **Resources/** - Images, icons, assets
- **Controls/** - Compiled control definitions
- **Connections/** - Data connection configurations
- **AppCheckerResult.sarif** - App checker validation results

### CanvasSource Format

The unpacked source format uses:
- **YAML** (`.fx.yaml`) for formulas and control properties
- **JSON** for metadata and configuration
- Readable and version-control friendly

---

## Support

For issues with:
- **PAC CLI installation**: https://learn.microsoft.com/power-platform/developer/cli/introduction
- **App import errors**: Check POST_IMPORT_CHECKLIST.md
- **Dataverse setup**: See DATAVERSE_SCHEMA.md

---

## Version History

- **v2.1** (2025-12-21)
  - Enhanced validation and error messages
  - Added file size verification
  - Improved step-by-step output
  - Added both PowerShell and Batch versions

- **v2.0** (2025-12-20)
  - Initial toolkit release
