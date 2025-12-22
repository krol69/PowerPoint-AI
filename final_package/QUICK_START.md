# Quick Start Guide - Import in 3 Steps

## ⚡ Goal: Get a working .msapp file and import it into Power Apps

**Time Required:** 10 minutes (setup) + 45 minutes (post-import config)

---

## Step 1: Install Power Platform CLI (PAC CLI)

### Option A: Download Installer (Easiest)
1. Go to: https://aka.ms/PowerAppsCLI
2. Download and run the installer
3. Restart your terminal/PowerShell

### Option B: Via .NET (if you have .NET installed)
```powershell
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

### Option C: Via npm (if you have Node.js)
```bash
npm install -g pac
```

### Verify Installation
```powershell
pac --version
```

**Expected output:** Version 1.33.x or higher

**If pac is not recognized:** Restart your terminal or add to PATH manually.

---

## Step 2: Pack the Canvas Source into .msapp

### On Windows (PowerShell):

```powershell
# Navigate to the package folder
cd C:\path\to\CrossDivProjectDB_Package

# Run the repack script
.\RepackToolkit\repack.ps1
```

### On Windows (Command Prompt):

```cmd
cd C:\path\to\CrossDivProjectDB_Package
RepackToolkit\repack.cmd
```

### Expected Output:

```
╔════════════════════════════════════════════════════════════════╗
║   Power Apps Canvas Source Repacker                           ║
║   Cross-Divisional Project Database                            ║
╚════════════════════════════════════════════════════════════════╝

✓ Power Platform CLI found
✓ CanvasSource folder exists
✓ Found 10 screen files
✓ Canvas pack completed successfully
✓ .msapp file created successfully

File: C:\...\CanvasApp\CrossDivProjectDB.msapp
Size: 87.4 KB

Next Steps:
  1. Import the .msapp into Power Apps
  2. Follow the POST_IMPORT_CHECKLIST.md
```

### Validation Checks (Automatic in script):

1. **File exists:** `CanvasApp/CrossDivProjectDB.msapp` is created
2. **File size:** Should be 40-150 KB (NOT 0 KB)
3. **ZIP structure:** Script validates internal structure

### If the script fails:

| Error | Solution |
|-------|----------|
| `pac not found` | Install PAC CLI (Step 1) |
| `CanvasSource not found` | Run from package root directory |
| `Execution policy` error | Run: `Set-ExecutionPolicy -Scope CurrentUser Bypass` |
| `0 KB output file` | Check CanvasSource folder is intact |

---

## Step 3: Import into Power Apps

### 3.1 Go to Power Apps Maker Portal

1. Open browser: **https://make.powerapps.com**
2. **Sign in** with your account
3. **Select your environment** (top-right dropdown)

### 3.2 Import the .msapp

1. Click **Apps** (left navigation)
2. Click **Import canvas app** (top menu bar)
3. Click **Upload**
4. Browse to: `CanvasApp/CrossDivProjectDB.msapp`
5. Click **Upload**

**Wait for upload to complete** (progress bar)

### 3.3 Configure Import

1. **App name:** Accept default or rename
2. **Import setup:** Select "Create as new"
3. Click **Import**

**Wait for import to complete** (30-60 seconds)

### 3.4 Verify Success

✅ **Success indicators:**
- "Import successful" message appears
- App appears in the Apps list
- No "Error opening file" message

❌ **If you see "Error opening file":**
- The .msapp was not packed correctly
- Re-run `repack.ps1` and ensure it completes without errors
- Check file size is not 0 KB

---

## Step 4: Post-Import Configuration (REQUIRED)

**⚠️ CRITICAL:** The app will NOT work until you complete these steps.

### Open the app in Edit mode

1. In Power Apps, find your imported app
2. Click the app name → **Edit**
3. Power Apps Studio opens

### Follow the Post-Import Checklist

**Open:** `POST_IMPORT_CHECKLIST.md` (in this package)

**You MUST:**
1. Create 5 Dataverse tables (see `DATAVERSE_SCHEMA.md`)
2. Add data connections in the app
3. Replace placeholders:
   - `<<CHANGE_ADMIN_EMAIL>>`
   - `<<CHANGE_SHAREPOINT_FOLDER_URL>>`
4. Add Office 365 Outlook connector
5. Seed security features data
6. Test the app

**Time:** 45-60 minutes

**Shortcut:** Follow **POST_IMPORT_CHECKLIST.md** step-by-step (12 steps)

---

## Troubleshooting

### Q: "Error opening file" when importing

**A:** Your .msapp was not packed correctly.

**Solution:**
1. Delete the .msapp file
2. Re-run `repack.ps1`
3. Verify output shows "Canvas pack completed successfully"
4. Check file size: `dir .\CanvasApp\CrossDivProjectDB.msapp`
5. Should be 40-150 KB, NOT 0 KB or missing

### Q: PAC CLI not found

**A:** PAC CLI not installed or not in PATH.

**Solution:**
1. Install from: https://aka.ms/PowerAppsCLI
2. Restart terminal
3. Run: `pac --version`
4. If still not found, add to PATH manually

### Q: App opens but shows errors

**A:** Post-import configuration not completed.

**Solution:**
- Follow `POST_IMPORT_CHECKLIST.md` completely
- Ensure all Dataverse tables are created
- Verify data connections are added

### Q: Can I skip the repack step?

**A:** NO. The Canvas Source MUST be packed with PAC CLI.

**Why:** Power Apps requires a compiled .msapp binary. Manual ZIP doesn't work.

### Q: Where do I get PAC CLI?

**A:** https://aka.ms/PowerAppsCLI

---

## Quick Reference Commands

```powershell
# Install PAC CLI (Option 1)
# Download from: https://aka.ms/PowerAppsCLI

# Install PAC CLI (Option 2 - .NET)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac --version

# Pack Canvas Source
cd C:\path\to\package
.\RepackToolkit\repack.ps1

# Check output
dir .\CanvasApp\

# Expected: CrossDivProjectDB.msapp (40-150 KB)
```

---

## Summary: Import Checklist

- [ ] PAC CLI installed (`pac --version` works)
- [ ] Ran `repack.ps1` successfully
- [ ] `.msapp` file created (40-150 KB)
- [ ] Imported into Power Apps (no "Error opening file")
- [ ] App appears in Apps list
- [ ] Opened app in Edit mode
- [ ] Following `POST_IMPORT_CHECKLIST.md`

**Once complete:** Your app is ready to use! 🎉

---

## Need Help?

- **Import Error:** See `DIAGNOSIS_AND_ROOT_CAUSE.md`
- **Table Setup:** See `DATAVERSE_SCHEMA.md`
- **Table Names:** See `TABLE_NAME_MAPPING_GUIDE.md`
- **Theme Customization:** See `THEME_DOCUMENTATION.md`

---

*For detailed technical analysis, see `DIAGNOSIS_AND_ROOT_CAUSE.md`*
