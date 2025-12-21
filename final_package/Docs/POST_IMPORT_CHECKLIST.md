# Post-Import Checklist

## Overview

This checklist guides you through setting up the Cross-Divisional Project Database app after importing the `.msapp` file into Power Apps.

**Estimated Time:** 45-60 minutes

---

## Prerequisites

Before starting, ensure you have:

- [ ] **Power Apps license** (Premium or Per User/App)
- [ ] **Dataverse environment** with maker permissions
- [ ] **Security role** with ability to create tables and apps
- [ ] **Successfully imported** `CrossDivProjectDB.msapp` into Power Apps

---

## Phase 1: Create Dataverse Tables

### Step 1.1: Create Tables

**Reference:** See `DATAVERSE_SCHEMA.md` for complete table definitions

Create these **8 tables** in your Dataverse environment:

| # | Table Display Name | Required Columns | Estimated Time |
|---|-------------------|------------------|----------------|
| 1 | Submissions | 11 columns | 5 min |
| 2 | Projects | 25 columns | 10 min |
| 3 | Project Security Details | 6 columns | 4 min |
| 4 | Project Documents | 5 columns | 3 min |
| 5 | Security Features | 4 columns | 3 min |
| 6 | Support Tickets | 7 columns | 4 min |
| 7 | Ticket Messages | 5 columns | 3 min |
| 8 | App Configuration | 4 columns | 3 min |

**How to create:**

1. Go to **https://make.powerapps.com**
2. Select your **environment**
3. **Tables** → **+ New table** → **Add columns and data**
4. Follow the schema in `DATAVERSE_SCHEMA.md`

> **Tip:** Use the **"Add columns and data"** option for faster table creation. You can paste values directly from the schema document.

### Step 1.2: Configure Table Relationships

Create these **lookup relationships**:

| Child Table | Column | → | Parent Table |
|-------------|--------|---|--------------|
| Projects | SubmissionId | → | Submissions |
| Project Security Details | ProjectId | → | Projects |
| Project Security Details | FeatureId | → | Security Features |
| Project Documents | ProjectId | → | Projects |
| Ticket Messages | TicketId | → | Support Tickets |

**How to create relationships:**

1. Open the **child table**
2. **+ New** → **Column**
3. Set **Data type** to **Lookup**
4. Set **Related table** to the parent table
5. Name the column as specified above
6. **Save**

### Step 1.3: Add Choice Values

Add choice values to these columns:

**Submissions table → Status column:**
- Draft
- Submitted
- Returned
- Archived

**Projects table:**
- **Customer:** GM, Ford, Tesla, Chrysler, Other
- **Project Status:** Acquisition, In-Development, In-Production, Other
- **Architecture:** VIP/GB, SDV, Stellabrain, Not applicable, Other
- **Microcontroller:** Infineon AURIX, NXP S32, Renesas RH850, STM32, Other
- **Completion Status:** Not Started, In Progress, Complete

**Support Tickets → Status:**
- Open
- In Progress
- Resolved
- Closed

**Support Tickets → Priority:**
- Low
- Medium
- High
- Urgent

**Detailed choice values:** See `DATAVERSE_SCHEMA.md`

---

## Phase 2: Import Seed Data

### Step 2.1: Import Security Features

**File:** `SeedData/Seed_SecurityFeatures.csv`

**Contains:** 22 pre-defined security features (e.g., Secure Boot, Memory Protection, etc.)

**How to import:**

1. Go to **Tables** → **Security Features**
2. **Import** → **Import data**
3. Upload `Seed_SecurityFeatures.csv`
4. Map columns:
   - `FeatureName` → Feature Name
   - `FeatureDescription` → Feature Description
   - `SpecificationRequired` → Specification Required
5. **Import**

**Verify:** You should see 22 records in the Security Features table

### Step 2.2: Import App Configuration

**File:** `SeedData/Seed_AppConfig.csv`

**Contains:** 5 configuration settings

**How to import:**

1. Go to **Tables** → **App Configuration**
2. **Import** → **Import data**
3. Upload `Seed_AppConfig.csv`
4. Map columns:
   - `ConfigKey` → Config Key
   - `ConfigValue` → Config Value
   - `Description` → Description
5. **Import**

**Verify:** You should see 5 records (MaxProjects, AutosaveInterval, etc.)

---

## Phase 3: Connect App to Dataverse

### Step 3.1: Open App in Power Apps Studio

1. Go to **https://make.powerapps.com**
2. **Apps** → Find "Cross-Divisional Project Database"
3. Click **Edit** to open in Power Apps Studio

### Step 3.2: Add Data Sources

1. In the left panel, click **Data** (database icon)
2. Click **+ Add data**
3. Search and add each table:
   - Submissions
   - Projects
   - Project Security Details
   - Project Documents
   - Security Features
   - Support Tickets
   - Ticket Messages
   - App Configuration

**Reference:** See `TABLE_NAME_MAPPING_GUIDE.md` for detailed instructions on finding table names

**Verification:**
- All 8 tables appear in the Data panel
- No warning icons next to table names

### Step 3.3: Verify Connections

1. Click **View** → **Data sources**
2. Check that all tables show **Connected**
3. If any show **Not connected**, remove and re-add them

---

## Phase 4: Configure Placeholders

The app has **3 placeholders** you must update:

### Placeholder 1: Admin Email

**Location:** `App.fx.yaml` → OnStart → gblConfig

**Find the line:**
```javascript
AdminEmail: "<<CHANGE_ADMIN_EMAIL>>",
```

**Update to:**
```javascript
AdminEmail: "your.admin@company.com",
```

**How to edit:**

1. In Power Apps Studio, go to **App** object (top of Tree view)
2. In the formula bar, find **OnStart** property
3. Scroll to the `Set(gblConfig, {` section
4. Update the `AdminEmail` value
5. **Save**

> **What this does:** Sets the admin email for submission notifications

### Placeholder 2: Admin CC (Optional)

**Location:** Same as above

**Find the line:**
```javascript
AdminEmailCC: "",
```

**Update to (optional):**
```javascript
AdminEmailCC: "team@company.com,manager@company.com",
```

> **Note:** Leave empty ("") if no CC recipients needed. Use comma-separated emails for multiple recipients.

### Placeholder 3: SharePoint Folder URL

**Location:** Same as above

**Find the line:**
```javascript
SharePointFolderURL: "<<CHANGE_SHAREPOINT_FOLDER_URL>>",
```

**Update to:**
```javascript
SharePointFolderURL: "https://yourcompany.sharepoint.com/sites/YourSite/Shared Documents/Projects",
```

**How to get the URL:**

1. Go to your SharePoint site
2. Navigate to the folder where project documents will be stored
3. Click the **⚙** (Settings) → **Library settings**
4. Copy the **Web Address** from the browser
5. Paste into the app (remove any trailing `/Forms/AllItems.aspx`)

> **What this does:** Provides a "Open SharePoint Folder" button in the app for quick access to document storage

### Step 4.4: Verify Placeholders Updated

**Run this check:**

1. Press **F5** to preview the app
2. Open browser developer console (F12)
3. In the console, type: `gblConfig`
4. Verify the output shows your actual values, not `<<CHANGE_...>>`

**If still showing placeholders:**
- You edited the wrong location
- You didn't save after editing
- App didn't run OnStart (refresh the preview)

---

## Phase 5: Configure Email Notifications

### Step 5.1: Add Office 365 Outlook Connection (Option A)

**If using Office 365 email:**

1. In Power Apps Studio, **Data** panel
2. **+ Add data** → **Connectors**
3. Search for **Office 365 Outlook**
4. Click **Add**
5. Sign in with your organizational account

### Step 5.2: Add SMTP Connection (Option B)

**If using custom SMTP server:**

1. In Power Apps Studio, **Data** panel
2. **+ Add data** → **Connectors**
3. Search for **SMTP**
4. Click **Add**
5. Configure with your SMTP server details

### Step 5.3: Update Email Formula (If Needed)

**Location:** `scrSubmissionReview` screen → `btnSubmit` button → OnSelect

**Default code sends via Outlook:**
```javascript
Office365Outlook.SendEmailV2(
    gblConfig.AdminEmail,
    "New Project Submission: " & gblCurrentSubmission.SubmissionId,
    varEmailBody,
    {
        CC: gblConfig.AdminEmailCC,
        Importance: "High"
    }
);
```

**If email fails:**
- Check that Office 365 Outlook connection is added
- Verify admin email is valid
- Check user has permissions to send email
- Review Power Apps environment email settings

---

## Phase 6: Test the App

### Step 6.1: Create Test Submission

1. **Preview the app** (F5)
2. Click **New Submission** on the home screen
3. Click **+ Add New Project**
4. Fill in **Step 1** (Basic Information):
   - Project Name: "Test Project 1"
   - Customer: Select from dropdown
   - Project Status: Select from dropdown
5. Click **Next**
6. Fill in **Step 2** (Additional Details)
7. Click **Next**
8. Fill in **Step 3** (Technology):
   - Microcontroller: Select from dropdown
   - Architecture: Select from dropdown
   - Protocols: Check at least one (e.g., CAN)
9. Click **Next**
10. **Step 4** (Security Features):
    - Toggle on 2-3 security features
    - For each selected feature, enter:
      - Spec Version: "v1.0"
      - Spec Details: "Test specification"
11. Click **Save & Exit**
12. Verify you return to the project list

### Step 6.2: Test Clone Feature

1. From the project list, find your test project
2. Click **📋 Clone** button
3. Verify a new project appears with "Copy of Test Project 1"
4. Click **Edit** on the cloned project
5. Verify all fields were copied
6. Go to **Step 4** and verify security features were cloned

### Step 6.3: Test Autosave

1. Edit a project
2. Make a change (e.g., edit Project Name)
3. Wait 90 seconds (default autosave interval)
4. Look for the **"Auto-saved"** toast notification at the bottom
5. Exit the app (close browser)
6. Reopen the app
7. Verify your draft is still there with the last changes

### Step 6.4: Test 5-Project Limit

1. From the project list, click **+ Add New Project** 5 times
2. Verify the button becomes **disabled** when you reach 5 projects
3. Verify the message changes to **"⚠ Max projects reached"**
4. Try clicking **Clone** on an existing project
5. Verify it shows: **"Maximum 5 projects reached"** notification

### Step 6.5: Test Validation

1. Edit a project, go to **Step 3**
2. Select **Microcontroller** → **Other**
3. **Leave the "Specify microcontroller" field empty**
4. Try clicking **Next**
5. Verify the button is **dimmed/disabled**
6. Verify the text field has a **red border**
7. Enter text in the field
8. Verify the **Next** button becomes enabled and blue

Repeat for:
- **Architecture** → Other
- **Protocols** → Other (leave "Specify other protocols" empty)

### Step 6.6: Test Submission

1. Complete all projects (ensure all show "Complete" status)
2. Click **Review & Submit →**
3. Review the summary screen
4. Click **Submit Submission**
5. Verify:
   - Success notification appears
   - Email is sent to admin (check inbox)
   - Submission status changes to "Submitted"

---

## Phase 7: Configure Permissions

### Step 7.1: Create Security Roles (Optional)

If you want role-based access:

1. **Maker Role:**
   - Read/Write on all tables
   - Can create and edit submissions

2. **Admin Role:**
   - All Maker permissions
   - Access to Admin Dashboard screen
   - Can review and return submissions

**How to create:**

1. Go to **Settings** → **Security** → **Security Roles**
2. Create new roles or modify existing
3. Grant table-level permissions

### Step 7.2: Share the App

1. Go to **Apps** → Find your app
2. Click **⋮** → **Share**
3. Add users or groups
4. Set permissions:
   - **Can use** (for regular users)
   - **Can use and share** (for admins)
5. **Share**

**Important:** Users also need permissions on Dataverse tables:

1. Go to **Tables** → Select a table
2. **Manage permissions** → **Add members**
3. Add the users/groups
4. Grant **Read** and **Write** permissions

---

## Phase 8: Verify All Features

### Feature Checklist

- [ ] **5-project limit enforced:** Cannot add more than 5 projects per submission
- [ ] **Clone project works:** Fields and security details copied (docs not copied)
- [ ] **Autosave timer works:** Saves every 90 seconds, shows toast notification
- [ ] **Resume works:** Exiting and reopening returns to last screen/project
- [ ] **Admin notification works:** Email sent on submission
- [ ] **Protocols multi-select works:** Can select multiple protocols (CAN, LIN, Ethernet, etc.)
- [ ] **Protocols "Other" required:** Cannot proceed if "Other" selected but not specified
- [ ] **Microcontroller "Other" required:** Cannot proceed if "Other" selected but not specified
- [ ] **Security features selection works:** Can toggle features on/off
- [ ] **Spec required for features:** SpecVersion and SpecDetails required for each selected feature
- [ ] **Validation blocks submit:** Cannot submit if any project has missing required fields
- [ ] **SharePoint button works:** "Open SharePoint Folder" button opens correct URL
- [ ] **Theme applied:** Dark background with cyan/purple/pink neon accents

---

## Phase 9: Optional Enhancements

### 9.1: Add Power Automate Flows

Create flows for:

1. **Submission notification flow:**
   - Trigger: When a Submission status changes to "Submitted"
   - Action: Send rich HTML email with project details
   - Action: Create Planner task for admin review

2. **Autosave cleanup flow:**
   - Trigger: Scheduled (daily)
   - Action: Delete draft submissions older than 30 days

**How to create:**

1. Go to **https://make.powerautomate.com**
2. **+ Create** → **Automated cloud flow**
3. Choose Dataverse trigger: **When a row is added, modified or deleted**
4. Configure trigger for Submissions table

### 9.2: Add Admin Approval Workflow

Modify the `scrAdminDashboard` screen to add approval buttons:

1. **Approve** → Sets status to "Approved"
2. **Return for Revision** → Sets status to "Returned", sends email to user

### 9.3: Add Analytics Dashboard

Use Power BI to create dashboards showing:
- Submissions over time
- Projects by customer
- Most used security features
- Average project completion time

**Connection:** Power BI can connect directly to Dataverse tables

---

## Troubleshooting

### Issue: Tables don't appear in Add Data panel

**Solution:** See `TABLE_NAME_MAPPING_GUIDE.md` → "If Tables Don't Appear" section

### Issue: Dropdowns are empty

**Cause:** Choice values not added to table columns

**Solution:** Go to table → Edit column → Add choice values from `DATAVERSE_SCHEMA.md`

### Issue: "You do not have permission to perform this action"

**Cause:** Missing table permissions

**Solution:**
1. Go to **Tables** → Select table → **Manage permissions**
2. Add your user with Read/Write permissions

### Issue: Email not sending

**Cause:** Email connector not configured

**Solution:**
1. Add Office 365 Outlook connector (Phase 5.1)
2. Check admin email is valid (Phase 4)
3. Test email manually: Create a test button with `Office365Outlook.SendEmailV2(...)`

### Issue: "Error opening file" when importing .msapp

**Cause:** The .msapp file is corrupted or not generated correctly

**Solution:**
1. Run the repack script again: `.\RepackToolkit\repack.ps1`
2. Verify the .msapp file size is > 0 KB
3. Try renaming .msapp to .zip and inspect contents (should have Header.json, Properties.json, etc.)

### Issue: Placeholders still showing `<<CHANGE_...>>`

**Cause:** OnStart not running or edits not saved

**Solution:**
1. **Save** the app after editing
2. **Close and reopen** the app in Power Apps Studio
3. **Preview** (F5) to run OnStart
4. Check browser console: `gblConfig` should show your values

---

## Success Criteria

Your app is ready for production when:

✅ All 8 Dataverse tables created with correct schemas
✅ All seed data imported (Security Features, App Configuration)
✅ All 8 data sources connected in Power Apps
✅ All 3 placeholders updated (admin email, CC, SharePoint URL)
✅ Email notifications working
✅ Test submission created successfully
✅ Clone feature tested and working
✅ Autosave tested and working
✅ 5-project limit enforced
✅ Validation preventing invalid submissions
✅ All required features from spec confirmed working
✅ App shared with intended users
✅ Permissions configured correctly

---

## Next Steps

After completing this checklist:

1. **Train users:**
   - Create user documentation
   - Hold training session
   - Provide support contact

2. **Monitor usage:**
   - Check App Insights for errors
   - Review submissions weekly
   - Gather user feedback

3. **Plan enhancements:**
   - Add Power Automate workflows
   - Create Power BI dashboards
   - Integrate with other systems

---

## Support Resources

| Document | Purpose |
|----------|---------|
| `DATAVERSE_SCHEMA.md` | Complete table and column definitions |
| `TABLE_NAME_MAPPING_GUIDE.md` | How to find and map table names |
| `REPACK_PIPELINE.md` | Regenerate .msapp after changes |
| `THEME_DOCUMENTATION.md` | Customize colors and styling |
| `README_REPACK.md` | Repack toolkit usage |

**Microsoft Resources:**
- **Power Apps Docs:** https://learn.microsoft.com/power-apps/
- **Dataverse Docs:** https://learn.microsoft.com/power-apps/maker/data-platform/
- **Power Apps Community:** https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1

---

**Checklist Version:** 2.1
**Last Updated:** 2025-12-21
**Estimated Total Time:** 45-60 minutes
**Difficulty:** Intermediate

---

## Completion Sign-Off

| Checkpoint | Completed | Date | Notes |
|------------|-----------|------|-------|
| Phase 1: Tables Created | ☐ | | |
| Phase 2: Seed Data Imported | ☐ | | |
| Phase 3: Data Sources Connected | ☐ | | |
| Phase 4: Placeholders Configured | ☐ | | |
| Phase 5: Email Configured | ☐ | | |
| Phase 6: App Tested | ☐ | | |
| Phase 7: Permissions Set | ☐ | | |
| Phase 8: Features Verified | ☐ | | |

**Configured By:** _______________________
**Date:** _______________________
**Environment:** _______________________
**App Version:** 2.1
