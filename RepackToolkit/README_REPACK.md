# RepackToolkit - Generate .msapp from Canvas Source

## Overview

This toolkit converts the **CanvasSource** folder (YAML/JSON source files) into a compiled **.msapp** binary file that can be imported into Microsoft Power Apps.

**Important:** This toolkit uses the **Template Baseline Method** to handle PAC CLI 1.51+ compatibility. See [REPACK_RUNBOOK.md](../REPACK_RUNBOOK.md) for detailed documentation.

## Why Template Baseline?

Power Apps CLI (PAC) version 1.51+ requires `CanvasManifest.json` in the source folder. Our CanvasSource was created with an older PAC version and doesn't include this file.

The Template Baseline method:
1. Unpacks a template `.msapp` to get the correct structure (including `CanvasManifest.json`)
2. Overlays our CanvasSource files onto the template structure
3. Packs the merged folder to create a valid `.msapp`

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

```cmd
pac --version
```

### 3. Get a Template .msapp File

You need a template `.msapp` file from Power Apps:

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Create a **Blank canvas app** (or use any existing app)
3. In the editor: **File** > **Save as** > **This computer**
4. Save the `.msapp` file (e.g., `C:\Templates\BlankApp.msapp`)

---

## Quick Start

### PowerShell (Recommended)

```powershell
# Navigate to package root
cd C:\path\to\PowerPoint-AI

# Run with template path
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
```

### CMD Wrapper

```cmd
RepackToolkit\repack.cmd "C:\Templates\BlankApp.msapp"
```

### Using Environment Variable

```powershell
# Set once
$env:REPACK_TEMPLATE_MSAPP = "C:\Templates\BlankApp.msapp"

# Then just run
.\RepackToolkit\repack.ps1
```

---

## What the Script Does

1. **Validates template .msapp** file exists and is valid
2. **Verifies PAC CLI** is installed and working
3. **Validates CanvasSource** structure (checks for required files)
4. **Unpacks template** to get baseline structure with `CanvasManifest.json`
5. **Merges CanvasSource** onto the baseline (preserving manifest)
6. **Packs merged folder** using `pac canvas pack`
7. **Verifies output** - checks file exists and has content
8. **Cleans up** temporary folders

---

## Expected Output

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

[OK] Template unpacked successfully
[OK] CanvasManifest.json found in template

...

[OK] Copied Src/ (screens and App.fx.yaml)
[OK] Copied Header.json
[OK] Copied Properties.json

...

[OK] Canvas pack completed successfully

...

[OK] .msapp file created successfully
  File:  C:\path\to\CanvasApp\CrossDivProjectDB.msapp
  Size:  156.42 KB

+------------------------------------------------------------------+
|   [OK] REPACK COMPLETED SUCCESSFULLY                             |
+------------------------------------------------------------------+
```

---

## Command-Line Options

### PowerShell Script

```powershell
.\RepackToolkit\repack.ps1 -TemplateMsappPath "path\to\template.msapp"
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-TemplateMsappPath` | Yes* | Path to template .msapp file |
| `-OutputName` | No | Custom output filename (default: CrossDivProjectDB.msapp) |
| `-KeepTempFolders` | No | Keep temp folders for debugging |

\* Can use `$env:REPACK_TEMPLATE_MSAPP` instead

### Examples

```powershell
# Basic usage
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"

# Custom output name
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp" -OutputName "MyApp.msapp"

# Debug mode (keep temp folders)
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp" -KeepTempFolders
```

---

## Troubleshooting

### Error: Template .msapp path is required

**Cause:** No template file provided

**Solution:** Provide the path or set environment variable:
```powershell
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
# OR
$env:REPACK_TEMPLATE_MSAPP = "C:\Templates\BlankApp.msapp"
```

### Error: PAS002 - Can't find CanvasManifest.json

**Cause:** The template .msapp is too old or corrupted

**Solution:**
1. Create a fresh template from Power Apps Studio
2. Export a different app as template
3. Ensure Power Apps is up to date

### Error: pac is not recognized

**Cause:** PAC CLI not installed or not in PATH

**Solution:**
1. Install PAC CLI (see Prerequisites)
2. Restart your terminal
3. Verify with `pac --version`

### Error: ExecutionPolicy prevents script

**Solution:**
```powershell
powershell -ExecutionPolicy Bypass -File .\RepackToolkit\repack.ps1 -TemplateMsappPath "..."
```

### Error: .msapp file is 0 bytes

**Cause:** Packing failed

**Solution:**
1. Run with `-KeepTempFolders` to inspect merged folder
2. Check PAC output for specific errors
3. Verify source YAML files are valid

---

## File Structure

```
PowerPoint-AI/
+-- CanvasSource/              <-- Source files (input)
|   +-- Src/
|   |   +-- App.fx.yaml
|   |   +-- scr*.fx.yaml       (11 screens)
|   +-- Header.json
|   +-- Properties.json
|   +-- Entropy/
|   +-- Connections/
|   +-- pkgs/
+-- CanvasApp/                 <-- Output folder
|   +-- CrossDivProjectDB.msapp   <-- Generated file
+-- RepackToolkit/             <-- This toolkit
|   +-- repack.ps1             <-- Main script
|   +-- repack.cmd             <-- CMD wrapper
|   +-- README_REPACK.md       <-- This file
|   +-- .repack_temp/          <-- Temp folder (auto-cleaned)
+-- REPACK_RUNBOOK.md          <-- Detailed documentation
+-- REPACK_QA.md               <-- Validation checklist
```

---

## Documentation

- **[REPACK_RUNBOOK.md](../REPACK_RUNBOOK.md)** - Detailed pipeline documentation, why template baseline, troubleshooting
- **[REPACK_QA.md](../REPACK_QA.md)** - Validation checklist for output
- **[POST_IMPORT_CHECKLIST.md](../docs/POST_IMPORT_CHECKLIST.md)** - After importing to Power Apps
- **[DATAVERSE_SCHEMA.md](../docs/DATAVERSE_SCHEMA.md)** - Required database tables

---

## Version History

- **v3.0** (2025-12-29)
  - Implemented Template Baseline method for PAC CLI 1.51+ compatibility
  - Added `-TemplateMsappPath` required parameter
  - Added environment variable support (`REPACK_TEMPLATE_MSAPP`)
  - Added temp folder merge process
  - Converted CMD to thin wrapper calling PowerShell
  - Added comprehensive diagnostics and step logging
  - Created REPACK_RUNBOOK.md and REPACK_QA.md

- **v2.1** (2025-12-21)
  - Enhanced validation and error messages
  - Added file size verification
  - Fixed PowerShell encoding issues for Windows 11

- **v2.0** (2025-12-20)
  - Initial toolkit release
