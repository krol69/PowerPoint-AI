# Cross-Divisional Project Database

A **production-ready Microsoft Power Apps Canvas App** for managing cross-divisional project submissions.

**Version:** 2.1
**Platform:** Microsoft Power Apps + Dataverse
**License Required:** Power Apps Premium (Per User/App)

## Features

- **Multi-project intake** (1-5 projects per submission)
- **Security feature tracking** with specification requirements
- **Autosave & resume** functionality
- **Clone projects** (copies fields + security details)
- **Admin dashboard** for review and management
- **Modern dark theme** with neon accents (cyan/purple/pink)
- **Email notifications** on submission
- **Validation system** preventing incomplete submissions
- **SharePoint integration** for document storage
- **Support ticket system** for user assistance

## Quick Start

### Step 1: Install Power Platform CLI

```bash
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

Or download from: https://aka.ms/PowerAppsCLI

### Step 2: Generate the .msapp File

**Windows:**
```cmd
RepackToolkit\repack.cmd
```

**PowerShell / macOS / Linux:**
```bash
./RepackToolkit/repack.ps1
```

This creates `CanvasApp/CrossDivProjectDB.msapp`.

### Step 3: Import into Power Apps

1. Go to https://make.powerapps.com
2. Select your environment
3. Click **Apps** > **Import canvas app**
4. Upload `CanvasApp/CrossDivProjectDB.msapp`
5. Click **Import**

### Step 4: Complete Setup

Follow `docs/POST_IMPORT_CHECKLIST.md` (45-60 minutes) to:
- Create 8 Dataverse tables
- Import seed data
- Connect data sources
- Update placeholders (admin email, SharePoint URL)

## Project Structure

```
├── CanvasSource/           # Power Apps source files (YAML/JSON)
│   ├── Src/                # Screen definitions (12 screens)
│   ├── Header.json         # App metadata
│   ├── Properties.json     # App properties
│   ├── Connections/        # Data connection configs
│   ├── Entropy/            # Internal tracking
│   └── pkgs/               # Package definitions
│
├── CanvasApp/              # Output folder for compiled .msapp
│
├── RepackToolkit/          # Scripts to generate .msapp
│   ├── repack.ps1          # PowerShell version
│   ├── repack.cmd          # Windows batch version
│   └── README_REPACK.md    # Detailed instructions
│
├── SeedData/               # CSV files for initial data
│   ├── Seed_SecurityFeatures.csv   # 22 security features
│   ├── Seed_AppConfig.csv          # 5 app settings
│   └── Seed_ChoiceValues.csv       # Choice field reference
│
├── docs/                   # Documentation
│   ├── POST_IMPORT_CHECKLIST.md    # Setup guide
│   ├── DATAVERSE_SCHEMA.md         # Table schemas (8 tables)
│   ├── TABLE_NAME_MAPPING_GUIDE.md # Table name help
│   ├── REPACK_PIPELINE.md          # Repack workflow
│   └── THEME_DOCUMENTATION.md      # UI customization
│
├── archive/                # Deprecated/legacy files
└── README.md               # This file
```

## Prerequisites

### Required

- **Microsoft Power Apps** license (Premium: Per User or Per App)
- **Dataverse environment** with database
- **Maker permissions** to create apps and tables
- **Power Platform CLI** installed (for repacking)

### Optional

- **Office 365 Outlook** connection (for email notifications)
- **SharePoint** site (for document storage)
- **Power Automate** license (for advanced workflows)

## Configuration

After importing, update these placeholders in `App.OnStart`:

| Placeholder | Purpose |
|-------------|---------|
| `<<CHANGE_ADMIN_EMAIL>>` | Admin notification email |
| `<<CHANGE_ADMIN_CC>>` | CC recipients (optional) |
| `<<CHANGE_SHAREPOINT_FOLDER_URL>>` | Document storage URL |

**Example:**
```javascript
Set(gblConfig, {
    AdminEmail: "your.admin@company.com",
    AdminEmailCC: "team@company.com",
    SharePointFolderURL: "https://yourcompany.sharepoint.com/...",
    AutosaveInterval: 90000,  // 90 seconds
    MaxProjects: 5
});
```

## Dataverse Schema

The app requires **8 tables**:

| Table | Purpose |
|-------|---------|
| Submissions | Parent submission records |
| Projects | Project details (1-5 per submission) |
| Project Security Details | Security features per project |
| Project Documents | Document links per project |
| Security Features | Master list of available features |
| Support Tickets | User-submitted support tickets |
| Ticket Messages | Chat messages in tickets |
| App Configuration | Global app settings |

See `docs/DATAVERSE_SCHEMA.md` for complete column definitions.

## Testing

**No automated tests yet.** Manual testing checklist:

1. Create a new submission with 1-5 projects
2. Complete all 4 wizard steps for a project
3. Test clone feature (should copy fields + security details)
4. Wait 90 seconds to verify autosave toast
5. Close and reopen to test resume feature
6. Test validation blocks submit when incomplete
7. Submit and verify admin email notification

See `docs/POST_IMPORT_CHECKLIST.md` for the complete verification checklist.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `pac is not recognized` | Install Power Platform CLI |
| .msapp file is 0 KB | Check PAC CLI output for errors |
| Tables don't appear in Add Data | Ensure tables are in same environment |
| Dropdowns are empty | Add choice values per DATAVERSE_SCHEMA.md |
| Email not sending | Add Office365Outlook connector |

## Documentation

| Document | When to Use |
|----------|-------------|
| `docs/POST_IMPORT_CHECKLIST.md` | After importing .msapp |
| `docs/DATAVERSE_SCHEMA.md` | Creating Dataverse tables |
| `docs/TABLE_NAME_MAPPING_GUIDE.md` | Table connection issues |
| `docs/REPACK_PIPELINE.md` | After editing source files |
| `docs/THEME_DOCUMENTATION.md` | Customizing appearance |
| `RepackToolkit/README_REPACK.md` | Repack troubleshooting |

## Contributing

1. Clone the repository
2. Make changes to files in `CanvasSource/`
3. Run `RepackToolkit/repack.cmd` to generate .msapp
4. Test the import in a development environment
5. Submit a pull request

## Roadmap

- [ ] Add automated testing framework
- [ ] Create Power Platform Solution package
- [ ] Add environment variable support
- [ ] Implement Power Automate flows for workflow automation

## Version History

### v2.1 (2025-12-21)
- Fixed packaging for import (proper .msapp generation)
- Enhanced repack scripts with validation
- Comprehensive documentation
- All core features implemented and verified

## License

This Power Apps package is provided as-is for use within your organization's Microsoft Power Platform environment.

## Resources

- [Power Apps Documentation](https://learn.microsoft.com/power-apps/)
- [Dataverse Documentation](https://learn.microsoft.com/power-apps/maker/data-platform/)
- [Power Platform CLI](https://learn.microsoft.com/power-platform/developer/cli/introduction)
- [Power Apps Community](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1)
