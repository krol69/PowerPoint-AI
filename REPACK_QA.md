# Repack QA Validation Checklist

This document provides a quick self-check checklist to validate that the generated `.msapp` file is correct and ready for import into Power Apps Studio.

---

## Pre-Repack Checks

Before running the repack pipeline:

- [ ] PAC CLI is installed (`pac --version` works)
- [ ] Template `.msapp` file exists and is non-zero size
- [ ] `CanvasSource/` folder exists with required files:
  - [ ] `Src/App.fx.yaml`
  - [ ] `Header.json`
  - [ ] `Properties.json`
  - [ ] `Src/*.fx.yaml` (screen files)

---

## Repack Execution Checks

During/after running `repack.ps1`:

### Step 0: Template Validation
- [ ] `[OK] Template .msapp found` appears
- [ ] Template size shown is reasonable (typically 30-200 KB for blank app)

### Step 1: Prerequisites
- [ ] `[OK] Power Platform CLI found` appears
- [ ] Version displayed (note version for debugging)

### Step 2: Source Validation
- [ ] `[OK] CanvasSource folder exists` appears
- [ ] `[OK] Found X screen files` shows expected count (11 screens for this app)
- [ ] No `[FAIL] Missing required files` errors

### Step 3: Template Unpack
- [ ] `[OK] Template unpacked successfully` appears
- [ ] `[OK] CanvasManifest.json found in template` appears
- [ ] Template baseline files listed

### Step 4: Merge
- [ ] All `[OK] Copied ...` messages appear:
  - [ ] `[OK] Copied Src/ (screens and App.fx.yaml)`
  - [ ] `[OK] Copied Header.json`
  - [ ] `[OK] Copied Properties.json`
  - [ ] `[OK] Copied Entropy/`
  - [ ] `[OK] Copied Connections/`
  - [ ] `[OK] Copied pkgs/`
- [ ] Merged folder root files listed shows `CanvasManifest.json`

### Step 5: Output Preparation
- [ ] `[OK] CanvasApp folder exists` or `[OK] Created CanvasApp folder`
- [ ] Output path displayed correctly

### Step 6: Pack
- [ ] `[OK] Canvas pack completed successfully` appears
- [ ] No `PAS002` or other PAC errors

### Step 7: Verification
- [ ] `[OK] .msapp file created successfully` appears
- [ ] File size is reasonable (typically 100-300 KB for this app)
- [ ] `[OK] Internal structure validated (X files)` appears

### Final Status
- [ ] `[OK] REPACK COMPLETED SUCCESSFULLY` banner appears
- [ ] Exit code is 0 (no errors)

---

## Post-Repack File Checks

After successful repack, manually verify:

### 1. File Existence
```powershell
# Check file exists
Test-Path "CanvasApp\CrossDivProjectDB.msapp"
# Expected: True
```

### 2. File Size
```powershell
# Check file size
(Get-Item "CanvasApp\CrossDivProjectDB.msapp").Length
# Expected: 100,000 - 400,000 bytes (100-400 KB)
```

### 3. ZIP Structure (Optional)
```powershell
# List contents (msapp is a ZIP file)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead("CanvasApp\CrossDivProjectDB.msapp")
$zip.Entries | Select-Object FullName, Length | Format-Table
$zip.Dispose()
```

Expected entries include:
- [ ] `CanvasManifest.json`
- [ ] `Header.json`
- [ ] `Properties.json`
- [ ] `Entropy/Entropy.json`
- [ ] `Controls/*.json` (screen definitions)
- [ ] Various other internal files

---

## Power Apps Studio Validation

After importing the `.msapp` into Power Apps Studio:

### 1. Import Success
- [ ] Import completes without errors
- [ ] App appears in Apps list
- [ ] Can open app in Edit mode

### 2. Screen Verification
- [ ] All expected screens appear in screen list:
  - [ ] scrHome
  - [ ] scrProjectList
  - [ ] scrWizardStep1
  - [ ] scrWizardStep2
  - [ ] scrWizardStep3
  - [ ] scrWizardStep4
  - [ ] scrSubmissionReview
  - [ ] scrAdminDashboard
  - [ ] scrTickets
  - [ ] scrTicketChat
  - [ ] scrMySubmissions

### 3. App Properties
- [ ] App name is "Cross-Divisional Project Database"
- [ ] Layout is correct (1920x1080, landscape)

### 4. Formula/Control Check
- [ ] Navigate to App.fx.yaml (OnStart)
- [ ] Verify OnStart formula exists and references expected variables
- [ ] Check a few controls on different screens render correctly

### 5. No Broken References
- [ ] No red error indicators on controls
- [ ] App Checker shows no critical errors (warnings about missing data sources are expected)

---

## Quick Validation Script

Run this PowerShell script for automated basic checks:

```powershell
# Quick validation script
$msappPath = "CanvasApp\CrossDivProjectDB.msapp"

Write-Host "=== REPACK QA QUICK CHECK ===" -ForegroundColor Cyan

# Check 1: File exists
if (Test-Path $msappPath) {
    Write-Host "[PASS] File exists" -ForegroundColor Green
} else {
    Write-Host "[FAIL] File does not exist!" -ForegroundColor Red
    exit 1
}

# Check 2: File size
$size = (Get-Item $msappPath).Length
$sizeKB = [math]::Round($size / 1KB, 2)
if ($size -gt 50000 -and $size -lt 1000000) {
    Write-Host "[PASS] File size: $sizeKB KB (reasonable)" -ForegroundColor Green
} elseif ($size -eq 0) {
    Write-Host "[FAIL] File is 0 bytes!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "[WARN] File size: $sizeKB KB (unusual)" -ForegroundColor Yellow
}

# Check 3: Valid ZIP
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($msappPath)
    $entryCount = $zip.Entries.Count
    $zip.Dispose()
    Write-Host "[PASS] Valid ZIP with $entryCount entries" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Not a valid ZIP file!" -ForegroundColor Red
    exit 1
}

# Check 4: Contains CanvasManifest.json
$zip = [System.IO.Compression.ZipFile]::OpenRead($msappPath)
$hasManifest = $zip.Entries | Where-Object { $_.Name -eq "CanvasManifest.json" }
$zip.Dispose()
if ($hasManifest) {
    Write-Host "[PASS] Contains CanvasManifest.json" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Missing CanvasManifest.json!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== ALL BASIC CHECKS PASSED ===" -ForegroundColor Green
Write-Host "Next: Import into Power Apps Studio for full validation" -ForegroundColor Cyan
```

---

## Expected Outcomes

| Check | Expected Result |
|-------|-----------------|
| Repack exit code | 0 |
| `.msapp` file size | 100-400 KB |
| ZIP entry count | 40-60 files |
| Contains CanvasManifest.json | Yes |
| Power Apps import | Success |
| Screen count | 11 screens |
| Critical app checker errors | 0 |

---

## Common Issues and Resolutions

| Issue | Resolution |
|-------|------------|
| File size 0 bytes | Check PAC errors; re-run with `-KeepTempFolders` |
| Import fails in Power Apps | Verify template was from compatible version |
| Missing screens | Check Src/*.fx.yaml files exist in CanvasSource |
| Controls show errors | Expected for Dataverse refs before connection setup |
| Formula errors | Configure data sources per POST_IMPORT_CHECKLIST.md |

---

## Related Documentation

- [REPACK_RUNBOOK.md](REPACK_RUNBOOK.md) - Detailed pipeline documentation
- [POST_IMPORT_CHECKLIST.md](docs/POST_IMPORT_CHECKLIST.md) - After import setup steps
- [DATAVERSE_SCHEMA.md](docs/DATAVERSE_SCHEMA.md) - Required database tables
