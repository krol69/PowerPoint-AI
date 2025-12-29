# Repack Troubleshooting Guide

This document covers common errors and solutions for the Power Apps Canvas repack pipeline.

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Error: PAS002 - CanvasManifest.json Not Found](#error-pas002---canvasmanifestjson-not-found)
3. [Error: ArgumentNullException / Internal Crash](#error-argumentnullexception--internal-crash)
4. [Error: Template .msapp Required](#error-template-msapp-required)
5. [Error: PAC CLI Not Found](#error-pac-cli-not-found)
6. [Error: .msapp Not Created / 0 Bytes](#error-msapp-not-created--0-bytes)
7. [Error: ExecutionPolicy Blocks Script](#error-executionpolicy-blocks-script)
8. [PAC Log Locations](#pac-log-locations)
9. [How to Create a Template .msapp](#how-to-create-a-template-msapp)
10. [Quick Verify Checklist](#quick-verify-checklist)

---

## Quick Diagnostics

### Check PAC Version

```powershell
pac --version
```

Expected: `Microsoft PowerPlatform CLI Version 1.x.x` (1.51+ requires CanvasManifest.json)

### Check PowerShell Version

```powershell
$PSVersionTable.PSVersion
```

Expected: 5.1 or 7.x

### Run Repack with Debug Mode

```powershell
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp" -KeepTempFolders
```

This keeps temp folders for inspection at `RepackToolkit\.repack_temp\`

---

## Error: PAS002 - CanvasManifest.json Not Found

### Symptoms

```
Error PAS002: Format is not supported. Can't find CanvasManifest.json file - is sources an old version?
```

### Cause

The CanvasSource folder uses an older unpack format that doesn't include `CanvasManifest.json`. PAC CLI 1.51+ requires this file.

### Solution

Use the template baseline method (default in v3.1+):

1. Get a template .msapp (see [How to Create a Template](#how-to-create-a-template-msapp))
2. Run repack with template:

```powershell
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
```

The script unpacks the template to get `CanvasManifest.json`, then merges your source files.

### Verification

During repack, you should see:

```
[OK] CanvasManifest.json found in template
```

---

## Error: ArgumentNullException / Internal Crash

### Symptoms

```
app encountered a non-recoverable error
Exception Type: System.ArgumentNullException
```

PAC may still report "completed successfully" but the .msapp file is NOT created.

### Cause

**Most common:** Empty metadata files in CanvasSource, especially:

- `Connections/Connections.json` containing just `{}`
- `pkgs/TableDefinitions/TableDefinitions.json` with empty arrays
- Other JSON files with null/empty content

When merged, these empty files overwrite the template's valid metadata, causing PAC to crash.

### Solution (v3.1+ - Automatic)

The repack script now automatically:

1. Checks if source JSON files have meaningful content
2. Skips empty files and keeps template versions
3. Warns you in the output:

```
[WARN] Connections.json is empty - will use template version
[WARN] Source folder has no valid content, keeping template: Connections/
```

### Manual Verification

Check your source files:

```powershell
Get-Content "CanvasSource\Connections\Connections.json"
```

If it shows just `{}` or `{ }`, that's the problem. The script handles this automatically now.

### If Still Failing

1. Run with `-KeepTempFolders` to inspect the merged folder
2. Check `RepackToolkit\.repack_temp\merged\Connections\` for content
3. The Connections.json in merged folder should have actual connection definitions (from template)

---

## Error: Template .msapp Required

### Symptoms

```
[FAIL] Template .msapp path is required!
```

### Cause

No template was provided and no bundled template exists.

### Solution

Provide a template using one of these methods:

**Option 1: Command-line parameter**
```powershell
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
```

**Option 2: Environment variable**
```powershell
$env:REPACK_TEMPLATE_MSAPP = "C:\Templates\BlankApp.msapp"
.\RepackToolkit\repack.ps1
```

**Option 3: Bundled template**

Place a template at: `RepackToolkit\template\BlankApp.msapp`

The script will use it automatically.

---

## Error: PAC CLI Not Found

### Symptoms

```
[FAIL] Power Platform CLI (pac) not found!
```

Or:

```
'pac' is not recognized as an internal or external command
```

### Solution

Install PAC CLI:

```powershell
# Option 1: .NET global tool (recommended)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Option 2: winget
winget install Microsoft.PowerAppsCLI

# Option 3: Direct download
# https://aka.ms/PowerAppsCLI
```

After installation, **restart your terminal** and verify:

```powershell
pac --version
```

---

## Error: .msapp Not Created / 0 Bytes

### Symptoms

```
[FAIL] .msapp file was not created!
```

Or:

```
[FAIL] .msapp file is 0 bytes (invalid)!
```

### Cause

PAC pack crashed or failed silently. Common causes:

1. Empty metadata files (see [ArgumentNullException](#error-argumentnullexception--internal-crash))
2. Invalid YAML syntax in Src/*.fx.yaml files
3. Incompatible template
4. File permission issues

### Diagnosis

1. Check the PAC output shown during repack
2. Look at the PAC log (script shows last 50 lines on failure)
3. Run with `-KeepTempFolders` and inspect `RepackToolkit\.repack_temp\merged\`

### PAC Log Locations

The script automatically checks these locations:

- `%LOCALAPPDATA%\Microsoft\PowerAppsCli\logs\`
- `%APPDATA%\Microsoft\PowerAppsCli\logs\`
- `%USERPROFILE%\.pac\logs\`

To manually view logs:

```powershell
# Find log folder
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\PowerAppsCli\logs" -ErrorAction SilentlyContinue

# View latest log
Get-Content "$env:LOCALAPPDATA\Microsoft\PowerAppsCli\logs\pac*.log" -Tail 100
```

---

## Error: ExecutionPolicy Blocks Script

### Symptoms

```
File C:\...\repack.ps1 cannot be loaded because running scripts is disabled on this system.
```

### Solution

**Option 1: Run with bypass (recommended)**

```powershell
powershell -ExecutionPolicy Bypass -File .\RepackToolkit\repack.ps1 -TemplateMsappPath "..."
```

**Option 2: Use CMD wrapper**

```cmd
RepackToolkit\repack.cmd "C:\Templates\BlankApp.msapp"
```

**Option 3: Unblock file**

```powershell
Unblock-File -Path .\RepackToolkit\repack.ps1
```

**Option 4: Change policy (requires admin)**

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## PAC Log Locations

### Windows Paths

| Location | Path |
|----------|------|
| Primary | `%LOCALAPPDATA%\Microsoft\PowerAppsCli\logs\` |
| Alternative | `%APPDATA%\Microsoft\PowerAppsCli\logs\` |
| .NET Tool | `%USERPROFILE%\.pac\logs\` |

### Finding the Latest Log

```powershell
# Automatic (script does this on failure)
$logPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\PowerAppsCli\logs" -Filter "*.log" |
           Sort-Object LastWriteTime -Descending |
           Select-Object -First 1

Get-Content $logPath.FullName -Tail 100
```

### Common Log Patterns

| Pattern in Log | Meaning |
|----------------|---------|
| `ArgumentNullException` | Empty/null metadata file |
| `PAS002` | Missing CanvasManifest.json |
| `FileNotFoundException` | Source file missing |
| `JsonReaderException` | Invalid JSON syntax |

---

## How to Create a Template .msapp

The template provides the correct folder structure including `CanvasManifest.json`.

### Step 1: Create Blank Canvas App

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Click **+ Create** > **Blank app** > **Blank canvas app**
3. Choose any layout (Tablet or Phone - doesn't matter)
4. Name it anything (e.g., "Template App")
5. Click **Create**

### Step 2: Export as .msapp

1. Wait for the editor to fully load
2. Click **File** > **Save as** > **This computer**
3. Save as `BlankApp.msapp`
4. Store it somewhere accessible (e.g., `C:\Templates\BlankApp.msapp`)

### Step 3: Use the Template

```powershell
.\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
```

### Optional: Bundle in Repo

Place the template at:

```
RepackToolkit\template\BlankApp.msapp
```

The script will use it automatically if no other template is specified.

---

## Quick Verify Checklist

After running repack, verify success:

### 1. Check Exit Code

```powershell
$LASTEXITCODE
# Should be 0
```

### 2. Check File Exists

```powershell
Test-Path "CanvasApp\CrossDivProjectDB.msapp"
# Should be True
```

### 3. Check File Size

```powershell
(Get-Item "CanvasApp\CrossDivProjectDB.msapp").Length
# Should be > 50000 (50KB+)
```

### 4. Check ZIP Structure

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead("CanvasApp\CrossDivProjectDB.msapp")
$zip.Entries.Count
$zip.Dispose()
# Should be 40+ entries
```

### 5. Check for CanvasManifest

```powershell
$zip = [System.IO.Compression.ZipFile]::OpenRead("CanvasApp\CrossDivProjectDB.msapp")
$zip.Entries | Where-Object { $_.Name -eq "CanvasManifest.json" }
$zip.Dispose()
# Should show the entry
```

### Expected Repack Output

A successful run shows:

```
[OK] Template .msapp found
[OK] Power Platform CLI found
[OK] Found 11 screen files
[OK] Template unpacked successfully
[OK] CanvasManifest.json found in template
[OK] Baseline structure copied
[OK] Copied Src/ (screens and App.fx.yaml)
[OK] Copied Header.json
[OK] Copied Properties.json
[OK] Copied Entropy/
[WARN] Source folder has no valid content, keeping template: Connections/
[OK] Canvas pack completed successfully
[OK] .msapp file created successfully
  Size: 150+ KB
[OK] Internal structure validated (40+ files)
+------------------------------------------------------------------+
|   [OK] REPACK COMPLETED SUCCESSFULLY                             |
+------------------------------------------------------------------+
```

---

## Error Reference Table

| Error Code/Pattern | Cause | Solution |
|--------------------|-------|----------|
| PAS002 | Missing CanvasManifest.json | Use template baseline method |
| ArgumentNullException | Empty metadata (Connections.json = `{}`) | Script v3.1+ handles automatically |
| NullReferenceException | Invalid/missing required file | Check source structure |
| pac not recognized | PAC CLI not installed | Install PAC CLI |
| ExecutionPolicy | PowerShell blocks scripts | Use -ExecutionPolicy Bypass |
| 0 byte output | Pack crashed | Check PAC log, use -KeepTempFolders |

---

## Related Documentation

- [REPACK_RUNBOOK.md](REPACK_RUNBOOK.md) - How the pipeline works
- [REPACK_QA.md](REPACK_QA.md) - Validation checklist
- [RepackToolkit/README_REPACK.md](RepackToolkit/README_REPACK.md) - Quick start guide
