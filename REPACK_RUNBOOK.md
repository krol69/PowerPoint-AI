# Repack Pipeline Runbook

This document explains the Power Apps Canvas repack pipeline, why it's needed, and how to use it.

## Table of Contents

1. [Overview](#overview)
2. [Why Template Baseline?](#why-template-baseline)
3. [Understanding PAS002 Error](#understanding-pas002-error)
4. [Prerequisites](#prerequisites)
5. [Getting a Template .msapp](#getting-a-template-msapp)
6. [Running the Repack Pipeline](#running-the-repack-pipeline)
7. [How It Works](#how-it-works)
8. [Troubleshooting](#troubleshooting)

---

## Overview

The repack pipeline converts the `CanvasSource/` folder (human-readable YAML and JSON files) into a `.msapp` binary file that Power Apps can import.

**The Challenge:** PAC CLI version 1.51+ requires a `CanvasManifest.json` file in the unpacked sources. Our repository uses an older unpack format that doesn't include this file.

**The Solution:** Template Baseline method - we use a template `.msapp` to provide the correct structure, then overlay our source files.

---

## Why Template Baseline?

### The Problem

When you run `pac canvas pack` on our `CanvasSource/` folder, you get:

```
Error PAS002: Format is not supported. Can't find CanvasManifest.json file - is sources an old version?
```

This happens because:

1. Our sources were created/exported with an older PAC CLI version
2. Newer PAC CLI (1.51+) introduced `CanvasManifest.json` as a required file
3. Our `CanvasSource/` folder doesn't have this file

### The Solution

Instead of trying to manually create `CanvasManifest.json` (which has complex internal references), we:

1. Take a template `.msapp` file (any canvas app exported from Power Apps)
2. Unpack it to get the correct structure including `CanvasManifest.json`
3. Overlay our source files (`Src/`, `Header.json`, `Properties.json`, etc.) onto the template
4. Pack the merged folder to create a valid `.msapp`

This approach is reliable because:
- The template provides all required manifest files in the correct format
- Our actual app logic (screens, controls, formulas) comes from our sources
- No manual file creation or guessing required

---

## Understanding PAS002 Error

### What It Means

```
Error PAS002: Format is not supported. Can't find CanvasManifest.json file - is sources an old version?
```

| Part | Meaning |
|------|---------|
| `PAS002` | Power Apps Source error code 002 |
| `Format is not supported` | The source folder structure doesn't match expected format |
| `Can't find CanvasManifest.json` | The specific required file is missing |
| `is sources an old version?` | PAC CLI suspects sources were unpacked with older version |

### Root Cause

The `CanvasSource/` folder structure:

```
CanvasSource/
  Src/           (screen YAML files)
  Header.json
  Properties.json
  Entropy/
  Connections/
  pkgs/
  [MISSING: CanvasManifest.json]
```

PAC CLI 1.51+ expects:

```
UnpackedSources/
  Src/
  Header.json
  Properties.json
  Entropy/
  Connections/
  pkgs/
  CanvasManifest.json    <-- REQUIRED
  [possibly other files]
```

---

## Prerequisites

### Required Software

1. **Power Platform CLI (PAC)**

   Install via one of these methods:

   ```powershell
   # Option 1: .NET global tool (recommended)
   dotnet tool install --global Microsoft.PowerApps.CLI.Tool

   # Option 2: winget
   winget install Microsoft.PowerAppsCLI

   # Option 3: Direct download
   # https://aka.ms/PowerAppsCLI
   ```

2. **PowerShell 5.1+** (included with Windows 10/11)

   Check version:
   ```powershell
   $PSVersionTable.PSVersion
   ```

3. **Template .msapp file** (see next section)

### Verify PAC Installation

```powershell
pac --version
# Should output something like: 1.34.3+g6e90a15
```

---

## Getting a Template .msapp

You need a template `.msapp` file from Power Apps. Here's how to get one:

### Option 1: Create a Blank App (Recommended)

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Click **+ Create** > **Blank app** > **Blank canvas app**
3. Choose **Tablet** or **Phone** layout (doesn't matter for template)
4. Name it anything (e.g., "Template App")
5. Once the editor loads, click **File** > **Save as** > **This computer**
6. Save the `.msapp` file (e.g., `C:\Templates\BlankApp.msapp`)

### Option 2: Export Existing App

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Find any existing canvas app
3. Click the three dots (...) > **Edit**
4. In the editor: **File** > **Save as** > **This computer**
5. Save the `.msapp` file

### Option 3: Use PAC to Download

If you have an app ID:

```powershell
pac canvas download --name "YourAppName" --output "C:\Templates\template.msapp"
```

### Store the Template

Store your template `.msapp` in a location you'll remember:

```
C:\Templates\BlankApp.msapp
```

Or set an environment variable for convenience:

```powershell
# PowerShell (session)
$env:REPACK_TEMPLATE_MSAPP = "C:\Templates\BlankApp.msapp"

# PowerShell (permanent, user-level)
[Environment]::SetEnvironmentVariable("REPACK_TEMPLATE_MSAPP", "C:\Templates\BlankApp.msapp", "User")

# CMD (session)
set REPACK_TEMPLATE_MSAPP=C:\Templates\BlankApp.msapp
```

---

## Running the Repack Pipeline

### PowerShell (Recommended)

```powershell
# Navigate to repository root
cd C:\path\to\PowerPoint-AI

# Run with template path
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"

# Or with custom output name
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp" -OutputName "MyApp.msapp"

# Or if env var is set
.\RepackToolkit\repack.ps1
```

### CMD (Batch Wrapper)

```cmd
REM Navigate to repository root
cd C:\path\to\PowerPoint-AI

REM Run with template path
RepackToolkit\repack.cmd "C:\Templates\BlankApp.msapp"

REM Or with custom output name
RepackToolkit\repack.cmd "C:\Templates\BlankApp.msapp" "MyApp.msapp"
```

### Expected Output

```
+------------------------------------------------------------------+
|   Power Apps Canvas Source Repacker (Template Baseline)          |
|   Cross-Divisional Project Database                              |
+------------------------------------------------------------------+

===================================================================
 Step 0: Checking Template .msapp
===================================================================

[OK] Template .msapp found
  Path:  C:\Templates\BlankApp.msapp
  Size:  45.23 KB

===================================================================
 Step 1: Verifying Prerequisites
===================================================================

[OK] Power Platform CLI found
  Version:  1.34.3+g6e90a15

...

===================================================================
 Step 7: Verifying Output
===================================================================

[OK] .msapp file created successfully
  File:  C:\path\to\PowerPoint-AI\CanvasApp\CrossDivProjectDB.msapp
  Size:  156.78 KB (0.15 MB)
  Modified:  2024-12-29 10:30:45
[OK] Internal structure validated (47 files)

+------------------------------------------------------------------+
|   [OK] REPACK COMPLETED SUCCESSFULLY                             |
+------------------------------------------------------------------+
```

### Output Location

The generated `.msapp` file is placed at:

```
PowerPoint-AI/
  CanvasApp/
    CrossDivProjectDB.msapp   <-- OUTPUT FILE
```

---

## How It Works

### Pipeline Steps

```
Step 0: Check Template
   - Validate -TemplateMsappPath parameter or $env:REPACK_TEMPLATE_MSAPP
   - Verify template file exists and is non-zero bytes

Step 1: Verify Prerequisites
   - Check PAC CLI is installed and working
   - Display version for debugging

Step 2: Validate CanvasSource
   - Verify CanvasSource/ folder exists
   - Check required files: Src/App.fx.yaml, Header.json, Properties.json
   - Count screen files

Step 3: Unpack Template
   - Create temp folders (.repack_temp/)
   - Run: pac canvas unpack --msapp <template> --sources <temp>
   - Verify CanvasManifest.json exists in unpacked output

Step 4: Merge Sources
   - Copy entire template structure to merged folder
   - Overlay CanvasSource content:
     - Src/ (screens and App.fx.yaml) - REPLACES template Src/
     - Header.json - REPLACES template
     - Properties.json - REPLACES template
     - Entropy/ - REPLACES template
     - Connections/ - REPLACES template
     - pkgs/ - REPLACES template
   - PRESERVE: CanvasManifest.json (from template)
   - Verify CanvasManifest.json still exists after merge

Step 5: Prepare Output
   - Create CanvasApp/ folder if needed
   - Remove old .msapp if exists

Step 6: Pack Merged Sources
   - Run: pac canvas pack --msapp <output> --sources <merged>
   - Check exit code

Step 7: Verify Output
   - Verify .msapp file exists
   - Verify file size > 0 bytes
   - Validate ZIP structure (optional)

Cleanup:
   - Remove temp folders (unless -KeepTempFolders)
```

### What Gets Merged

| Source | From | Notes |
|--------|------|-------|
| `CanvasManifest.json` | Template | Required by PAC CLI 1.51+ |
| `Src/*.fx.yaml` | CanvasSource | Your screens and controls |
| `Header.json` | CanvasSource | Your app metadata |
| `Properties.json` | CanvasSource | Your app properties |
| `Entropy/` | CanvasSource | Internal tracking |
| `Connections/` | CanvasSource | Data connections config |
| `pkgs/` | CanvasSource | Package definitions |

---

## Troubleshooting

### Error: Template .msapp path is required

**Cause:** No template path was provided.

**Solution:**
```powershell
# Provide path directly
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"

# Or set environment variable
$env:REPACK_TEMPLATE_MSAPP = "C:\Templates\BlankApp.msapp"
.\RepackToolkit\repack.ps1
```

### Error: Template .msapp not found

**Cause:** The specified template file doesn't exist.

**Solution:**
- Verify the path is correct
- Check for typos
- Ensure the file wasn't moved or deleted
- Create a new template (see [Getting a Template .msapp](#getting-a-template-msapp))

### Error: Power Platform CLI (pac) not found

**Cause:** PAC CLI is not installed or not in PATH.

**Solution:**
```powershell
# Install via .NET
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac --version
```

If installed but not found, restart your terminal or check PATH.

### Error: Template unpack did not produce CanvasManifest.json

**Cause:** The template .msapp is too old or corrupted.

**Solution:**
- Create a fresh template from Power Apps Studio
- Export a different app as template
- Ensure you're using a recent Power Apps version

### Error: ExecutionPolicy prevents script

**Cause:** PowerShell execution policy blocks scripts.

**Solution:**
```powershell
# Option 1: Bypass for this session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Option 2: Use the CMD wrapper
RepackToolkit\repack.cmd "C:\Templates\BlankApp.msapp"

# Option 3: Run with bypass flag
powershell.exe -ExecutionPolicy Bypass -File .\RepackToolkit\repack.ps1 -TemplateMsappPath "..."
```

### Error: PAS002 still appears after using template

**Cause:** Something went wrong during merge.

**Solution:**
1. Run with `-KeepTempFolders` to inspect temp files:
   ```powershell
   .\RepackToolkit\repack.ps1 -TemplateMsappPath "..." -KeepTempFolders
   ```

2. Check `RepackToolkit\.repack_temp\merged\` for:
   - Does `CanvasManifest.json` exist?
   - Are the files correct?

3. Try a different template .msapp

### Error: .msapp created but 0 bytes

**Cause:** PAC pack failed silently.

**Solution:**
1. Check PAC output for errors
2. Verify all source files are valid JSON/YAML
3. Run with `-KeepTempFolders` and manually run:
   ```powershell
   pac canvas pack --msapp "test.msapp" --sources "RepackToolkit\.repack_temp\merged"
   ```

### Warning: Paths with spaces

**Issue:** Paths containing spaces may cause issues.

**Solution:**
- The script handles this automatically with proper quoting
- If issues persist, move files to paths without spaces
- Example: `C:\Temp\template.msapp` instead of `C:\My Files\template.msapp`

---

## Additional Resources

- [POST_IMPORT_CHECKLIST.md](docs/POST_IMPORT_CHECKLIST.md) - After importing to Power Apps
- [REPACK_QA.md](REPACK_QA.md) - Validation checklist
- [DATAVERSE_SCHEMA.md](docs/DATAVERSE_SCHEMA.md) - Database schema
- [PAC CLI Documentation](https://learn.microsoft.com/power-platform/developer/cli/introduction)
