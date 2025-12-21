# Cross-Divisional Project Database

## Package Contents

This package contains the **Canvas Source files** for a Power Apps Canvas app designed for cross-divisional security project intake management.

### 🚨 IMPORTANT: This is NOT a directly importable file!

You cannot import this ZIP or the `CanvasSource/` folder directly into Power Apps. You must first **repack** it into a `.msapp` file using the Power Platform CLI.

---

## Quick Start (5 Steps)

### Step 1: Install Power Platform CLI

```bash
# Via .NET (recommended)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify
pac --version
```

### Step 2: Extract This ZIP

Extract to a folder like `C:\CrossDivProjectDB\`

### Step 3: Repack to .msapp

```powershell
cd C:\CrossDivProjectDB
pac canvas pack --msapp ".\CanvasApp\CrossDivProjectDB.msapp" --sources ".\CanvasSource"
```

**Or use the included scripts:**
```powershell
cd .\RepackToolkit
.\repack.ps1
```

### Step 4: Import into Power Apps

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Click **Apps** → **Import canvas app**
3. Upload `.\CanvasApp\CrossDivProjectDB.msapp`
4. Click **Import**

### Step 5: Configure

1. Create 8 Dataverse tables (see `DATAVERSE_SCHEMA.md`)
2. Add data connections to the app
3. Update admin email & SharePoint URL in App.OnStart
4. Import seed data from `SeedData/` folder
5. Follow `POST_IMPORT_CHECKLIST.md`

---

## Package Structure

```
CrossDivProjectDB_Import_Package/
├── CanvasSource/           # Power Apps source files (YAML/JSON)
│   ├── Header.json         # App version metadata
│   ├── Properties.json     # App properties
│   ├── Src/                # Screen definitions
│   │   ├── App.fx.yaml     # App-level formulas
│   │   ├── scrHome.fx.yaml
│   │   └── ... (11 screens)
│   ├── Connections/        # Connection placeholders
│   ├── Entropy/            # Control ordering
│   └── pkgs/               # Package definitions
├── CanvasApp/              # OUTPUT folder (after repack)
├── RepackToolkit/          # Repack scripts
│   ├── repack.ps1
│   └── repack.cmd
├── SeedData/               # CSV files for Dataverse tables
├── Solution/               # Solution creation guide
├── DATAVERSE_SCHEMA.md     # Complete table definitions
├── POST_IMPORT_CHECKLIST.md# Post-import setup steps
├── REPACK_PIPELINE.md      # Detailed repack instructions
├── THEME_DOCUMENTATION.md  # UI theme reference
└── README.md               # This file
```

---

## Features

### Core Functionality
- ✅ Multi-project submission (1-5 projects per intake)
- ✅ 4-step wizard for each project
- ✅ 22 security features with spec tracking
- ✅ Autosave every 90 seconds
- ✅ Resume from last visited screen
- ✅ Clone project with security details
- ✅ Admin dashboard
- ✅ Support ticket system

### Technical Features
- ✅ Futuristic dark theme with neon accents
- ✅ Multi-select protocols (LIN/CAN/Ethernet/Other)
- ✅ Conditional "Other" field validation
- ✅ Email notifications on submit (admin + user)
- ✅ SharePoint document link integration
- ✅ Max 5 projects enforcement
- ✅ Complete Dataverse schema

---

## Dataverse Tables Required

1. **Submissions** — Parent intake records
2. **Projects** — Individual projects (1-5 per submission)
3. **SecurityFeatures** — Catalog of 22 features
4. **ProjectSecurityDetails** — Junction table with specs
5. **ProjectAttachments** — Document links
6. **Tickets** — Support tickets
7. **TicketMessages** — Ticket chat
8. **AppConfig** — Configuration settings

See `DATAVERSE_SCHEMA.md` for complete column definitions.

---

## Configuration

After import, update these placeholders in `App.OnStart`:

| Placeholder | Description |
|-------------|-------------|
| `<<CHANGE_ADMIN_EMAIL>>` | Admin inbox for notifications |
| `<<CHANGE_SHAREPOINT_FOLDER_URL>>` | Base folder for document uploads |

---

## UI Theme

The app uses a **Futuristic Dark Theme**:

- **Background:** #0D1117 (near-black)
- **Primary:** #00BCD4 (cyan neon)
- **Secondary:** #7C4DFF (purple neon)
- **Success:** #00E676 (green neon)
- **Warning:** #FFC107 (amber)
- **Error:** #FF5252 (red neon)

See `THEME_DOCUMENTATION.md` for complete color tokens.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Error opening file" on import | You're importing source, not .msapp - run repack first |
| `pac not found` | Install Power Platform CLI |
| 0 KB output file | Check CanvasSource path is correct |
| Connection errors after import | Add Dataverse tables as data sources |

---

## Version

**v2.1** — Enhanced with:
- Clone copies security details
- Protocol "Other" validation
- SharePoint document links
- Complete theme documentation

---

*Created for Cross-Divisional Security Intake Management*
