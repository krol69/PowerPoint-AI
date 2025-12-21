# Post-Import Checklist for Cross-Divisional Project Database

## Quick Summary

After importing the `.msapp` file into Power Apps, complete these steps to make the app fully functional.

---

## 📋 Checklist

### ☐ Step 1: Create Dataverse Tables (5-10 min)

Before the app will work, you must create 8 Dataverse tables. Use the `DATAVERSE_SCHEMA.md` file for exact column definitions.

**Tables to create:**
1. `Submissions` — Parent table for intakes
2. `Projects` — Child table (1-5 per submission)
3. `SecurityFeatures` — Catalog table (seed with 22 records)
4. `ProjectSecurityDetails` — Junction table (projects ↔ features)
5. `ProjectAttachments` — Document links
6. `Tickets` — Support tickets
7. `TicketMessages` — Ticket chat messages
8. `AppConfig` — Configuration settings

**Quick path:**
1. Go to [make.powerapps.com](https://make.powerapps.com) → **Tables**
2. Click **+ New table** → **Start from blank**
3. Create each table with columns per `DATAVERSE_SCHEMA.md`
4. Add the seed data from `/SeedData/` CSV files

---

### ☐ Step 2: Add Data Connections (2 min)

1. Open the imported app in **Edit mode**
2. Go to **Data** panel (left sidebar)
3. Click **+ Add data**
4. Add connections to your newly created tables:
   - Submissions
   - Projects
   - SecurityFeatures
   - ProjectSecurityDetails
   - ProjectAttachments
   - Tickets
   - TicketMessages
   - AppConfig

**For email notifications:**
5. Add **Office365Outlook** connector (for admin/user email notifications on submit)

---

### ☐ Step 3: Configure Admin Email & SharePoint (1 min)

Open `App.fx.yaml` (via **Tree view** → **App** → **OnStart**) and update these placeholders:

```powerapps
Set(gblConfig, {
    // <<CHANGE_ADMIN_EMAIL>> - Your admin inbox
    AdminEmail: "admin@yourcompany.com",
    
    // <<CHANGE_ADMIN_CC>> - Optional CC recipients
    AdminEmailCC: "team@yourcompany.com",
    
    // <<CHANGE_SHAREPOINT_FOLDER_URL>> - Base folder for doc uploads
    SharePointFolderURL: "https://yourcompany.sharepoint.com/sites/Projects/Shared%20Documents/CrossDiv",
    
    // Other settings (optional to change)
    AutosaveInterval: 90000,  // 90 seconds
    MaxProjects: 5
});
```

---

### ☐ Step 4: Load Seed Data (5 min)

Import the CSV files from `/SeedData/`:

| File | Target Table | Records |
|------|--------------|---------|
| `Seed_SecurityFeatures.csv` | SecurityFeatures | 22 |
| `Seed_ChoiceValues.csv` | Reference for Choice columns | — |
| `Seed_AppConfig.csv` | AppConfig | 5 |

**To import:**
1. Go to **Tables** → Select table
2. Click **Import** → **Import data from Excel**
3. Upload the CSV and map columns

---

### ☐ Step 5: Test the App (3 min)

1. Click **Play** (▶) button in Power Apps Studio
2. Verify:
   - [x] Home screen loads with dark theme
   - [x] "Start New Submission" creates a draft
   - [x] Wizard steps 1-4 save data correctly
   - [x] Clone button copies project + security details
   - [x] Submit sends email to admin
3. Check for any red error icons on controls

---

### ☐ Step 6: Publish & Share

1. Click **File** → **Save**
2. Click **Publish**
3. Go to **Share** → Add users/groups
4. Set permissions (User / Co-owner)

---

## 🎨 Theme Reference

The app uses a **Futuristic Dark Theme** with these color tokens:

| Token | Hex | Usage |
|-------|-----|-------|
| `Background` | `#0D1117` | Main background |
| `BackgroundSecondary` | `#161B22` | Headers, footers |
| `BackgroundCard` | `#1E252E` | Cards, containers |
| `Primary` | `#00BCD4` | CTAs, links (cyan neon) |
| `Secondary` | `#7C4DFF` | Accents (purple neon) |
| `Accent` | `#FF4081` | Highlights (pink neon) |
| `Success` | `#00E676` | Completed states |
| `Warning` | `#FFC107` | Drafts, cautions |
| `Error` | `#FF5252` | Errors, validation |
| `TextPrimary` | `#FFFFFF` | Main text |
| `TextSecondary` | `#9EA7B3` | Labels, hints |
| `TextMuted` | `#6E7681` | Disabled text |
| `Border` | `#30363D` | Default borders |
| `BorderFocus` | `#00BCD4` | Focus states |

All colors are defined in `gblTheme` variable in `App.OnStart`.

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Table not found" errors | Ensure all 8 Dataverse tables exist with correct names |
| Email not sending | Add Office365Outlook connection and grant permissions |
| Clone doesn't copy security | Verify `ProjectSecurityDetails` table has correct lookups |
| Dark theme not showing | Check `gblTheme` is set in App.OnStart |
| Autosave not working | Verify `tmrAutosave` timer on `scrProjectList` screen |

---

## 📞 Support

If you encounter issues:
1. Use the in-app **Help & Support** ticket system
2. Contact the admin at the configured `AdminEmail`
3. Check Dataverse table permissions

---

*Generated for Cross-Divisional Project Database v2.1*
