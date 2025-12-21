# Solution Creation Guide

## Why Create a Solution?

A Power Platform Solution allows you to:
- Package the Canvas App + Dataverse tables + environment variables together
- Deploy to multiple environments (dev → test → prod)
- Version control your components
- Share with other tenants more easily

---

## Prerequisites

1. Power Apps environment with Dataverse enabled
2. Environment Maker or System Administrator role
3. The Canvas App imported successfully

---

## Step-by-Step: Create Solution in Maker Portal

### Step 1: Create Solution

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your environment (top right)
3. Click **Solutions** in left navigation
4. Click **+ New solution**
5. Fill in:
   - **Display name:** `Cross-Divisional Project DB`
   - **Name:** `CrossDivProjectDB`
   - **Publisher:** Select or create a publisher (e.g., `YourCompany`)
   - **Version:** `1.0.0.0`
6. Click **Create**

### Step 2: Add Canvas App to Solution

1. Open your new solution
2. Click **Add existing** → **App** → **Canvas app**
3. Find and select `Cross-Divisional Project Database`
4. Click **Add**

### Step 3: Add Dataverse Tables to Solution

1. Click **Add existing** → **Table**
2. Select all 8 tables:
   - [ ] Submissions (`cr_submissions`)
   - [ ] Projects (`cr_projects`)
   - [ ] Security Features (`cr_securityfeatures`)
   - [ ] Project Security Details (`cr_projectsecuritydetails`)
   - [ ] Project Attachments (`cr_projectattachments`)
   - [ ] Tickets (`cr_tickets`)
   - [ ] Ticket Messages (`cr_ticketmessages`)
   - [ ] App Config (`cr_appconfig`)
3. For each table, select **Include table metadata** and **Include all components**
4. Click **Add**

### Step 4: Add Environment Variables (Recommended)

1. Click **+ New** → **More** → **Environment variable**
2. Create these variables:

| Display Name | Schema Name | Type | Default Value |
|--------------|-------------|------|---------------|
| Admin Email | `cr_AdminEmail` | Text | `<<CHANGE_ADMIN_EMAIL>>` |
| SharePoint Folder URL | `cr_SharePointFolderURL` | Text | `<<CHANGE_SHAREPOINT_FOLDER_URL>>` |
| Autosave Interval | `cr_AutosaveInterval` | Number | `90000` |
| Max Projects | `cr_MaxProjects` | Number | `5` |

3. Update the Canvas App to use environment variables instead of hardcoded values (optional but recommended)

### Step 5: Add Connection References (Optional)

1. Click **+ New** → **More** → **Connection reference**
2. Create references for:
   - Microsoft Dataverse
   - Office 365 Outlook

### Step 6: Export Solution

1. Click **Export** in the solution toolbar
2. Choose:
   - **Unmanaged** (for development/editing)
   - **Managed** (for production deployment - cannot be edited)
3. Click **Export**
4. Download the `.zip` file

---

## Step-by-Step: Create Solution via Power Platform CLI

If you prefer command line:

```powershell
# 1. Authenticate
pac auth create --environment "https://yourorg.crm.dynamics.com"

# 2. Initialize solution
pac solution init --publisher-name "YourCompany" --publisher-prefix "cr"

# 3. Add components (after importing app)
pac solution add-reference --path ".\CrossDivProjectDB.msapp"

# 4. Export
pac solution export --path ".\CrossDivProjectDB_Solution.zip" --managed false
```

---

## Importing the Solution to Another Environment

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select target environment
3. Click **Solutions** → **Import solution**
4. Upload the `.zip` file
5. Follow the wizard:
   - Review components
   - Configure connection references (sign in)
   - Set environment variable values
6. Click **Import**

---

## Environment Variable Usage in Canvas App

To use environment variables in your app formulas:

```powerfx
// Instead of hardcoded:
Set(gblConfig, {
    AdminEmail: "admin@company.com"
});

// Use environment variables:
Set(gblConfig, {
    AdminEmail: Environment.cr_AdminEmail
});
```

This allows different values per environment without editing the app.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tables not showing in "Add existing" | Ensure tables have the same publisher prefix |
| Connection reference fails | Create the connection first, then add reference |
| Export fails | Check all dependencies are included |
| Import fails in target | Check target has Dataverse enabled |

---

## Solution Contents Checklist

When your solution is complete, it should contain:

- [ ] 1 Canvas App
- [ ] 8 Dataverse Tables (with all columns, relationships, choices)
- [ ] 4 Environment Variables (optional)
- [ ] 2 Connection References (optional)

Export and save the solution `.zip` file for deployment to other environments.
