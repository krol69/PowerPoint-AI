# Table Name Mapping Guide

## Overview

When you create Dataverse tables manually in your environment, the system assigns **schema names** (also called **logical names**) based on your publisher prefix. These names may differ from the examples in the documentation.

This guide shows you exactly how to find your actual table names and update the app's data connections.

---

## Understanding Table Names in Dataverse

Dataverse tables have **three** different names:

| Name Type | Example | Description | Where Used |
|-----------|---------|-------------|------------|
| **Display Name** | `Projects` | Friendly name shown in UI | Dataverse interface, documentation |
| **Schema Name** | `cr_Projects` | Physical table name | Database, Power Automate |
| **Logical Name** | `cr_projects` | Lowercase version | Power Apps formulas, APIs |

**Important:** The app uses the **Logical Name** (lowercase) for data connections.

---

## Finding Your Table Names

### Method 1: Via Power Apps Maker Portal (Recommended)

1. Go to **https://make.powerapps.com**
2. Select your **environment** (top-right)
3. In the left navigation, click **Tables** (under Dataverse)
4. You'll see a list of all tables

For each table you created:

1. **Find the table** by its Display Name (e.g., "Projects")
2. **Click on the table** to open it
3. Look at the **Properties** panel on the right
4. Note these values:
   - **Display name:** `Projects`
   - **Logical name:** `cr_projects` ← **This is what you need!**
   - **Schema name:** `cr_Projects`

> **Tip:** The **Logical name** is always lowercase. Use this value when connecting the app.

### Method 2: Via Table Settings

1. Open the table from the **Tables** list
2. Click the **⚙ Settings** button (top-right)
3. Go to **Edit table properties**
4. Scroll down to see:
   - **Name** (Schema name)
   - **Logical name**

### Method 3: Via Solution Explorer

1. Go to **Solutions** in the left navigation
2. Open your solution containing the tables
3. Click **Tables**
4. For each table, click the **⋯** (more actions) menu
5. Select **Advanced** → **Properties**
6. View the **Logical name** field

### Method 4: Using XrmToolBox (Advanced)

If you have many tables to check:

1. Download **XrmToolBox** (free tool)
2. Install the **Metadata Browser** plugin
3. Connect to your Dataverse environment
4. Browse entities and copy logical names

---

## Expected Table Names

Based on the DATAVERSE_SCHEMA.md, you should create these **8 tables**:

| Display Name | Expected Logical Name | Purpose |
|--------------|----------------------|---------|
| Submissions | `cr_submissions` | Parent submission records |
| Projects | `cr_projects` | Project details (1-5 per submission) |
| Project Security Details | `cr_projectsecuritydetails` | Security features per project |
| Project Documents | `cr_projectdocuments` | Document links per project |
| Security Features | `cr_securityfeatures` | Master list of available features |
| Support Tickets | `cr_supporttickets` | User-submitted tickets |
| Ticket Messages | `cr_ticketmessages` | Chat messages in tickets |
| App Configuration | `cr_appconfiguration` | Global app settings |

> **Note:** The `cr_` prefix may vary based on your publisher. It could be `new_`, `org_`, or any custom prefix your organization uses.

---

## Connecting Tables to the App

### Option 1: Using Display Names (Recommended)

Power Apps lets you connect tables using their **Display Names**. After importing the app:

1. Open the app in **Power Apps Studio**
2. In the left panel, click **Data** (database icon)
3. Click **+ Add data**
4. Search for each table by its **Display Name**:
   - `Submissions`
   - `Projects`
   - `Project Security Details`
   - `Project Documents`
   - `Security Features`
   - `Support Tickets`
   - `Ticket Messages`
   - `App Configuration`
5. Click each table to add it as a data source

Power Apps will automatically map to the correct logical names.

### Option 2: If Tables Don't Appear

If tables don't show up in the Add Data panel:

1. **Check table ownership:**
   - Go to each table's **Settings** → **Edit table properties**
   - Under **Ownership**, ensure it's set to **User or team owned** (not Organization owned)

2. **Check permissions:**
   - Ensure your user has **Read** and **Write** permissions on the tables
   - Go to **Settings** → **Security** → **Security Roles**
   - Verify your role has table privileges

3. **Refresh the connection:**
   - In Power Apps Studio, click **Data** panel
   - Click the **⋮** menu (top-right)
   - Select **Refresh all**

---

## Updating Table References in Formulas

If you need to manually update table references in the app:

### Step 1: Find Current References

1. Open the app in **Power Apps Studio**
2. Press **Ctrl+Shift+F** (or **Cmd+Shift+F** on Mac) to open **Find and Replace**
3. Search for `Filter(Projects` to find all references to the Projects table
4. Repeat for other tables

### Step 2: Replace with Your Table Names

The app formulas use these patterns:

```javascript
// Example: Filtering projects
Filter(Projects, SubmissionId.SubmissionId = gblCurrentSubmission.SubmissionId)

// Example: Patching a record
Patch(Submissions, gblCurrentSubmission, { Status: {Value: "Submitted"} })

// Example: Creating a new record
Patch(Projects, Defaults(Projects), { ProjectName: "New Project" })
```

If your logical name is different (e.g., `new_projects` instead of `cr_projects`), Power Apps will handle this automatically when you connect the data source.

### Step 3: No Code Changes Needed!

**Good news:** You typically don't need to change any formulas. Power Apps uses the **Display Name** in formulas, not the logical name. As long as you:

1. Created tables with the correct **Display Names** (from DATAVERSE_SCHEMA.md)
2. Added them as data sources in the Data panel

The app will work correctly regardless of your schema/logical names.

---

## Verifying Table Connections

After importing and connecting tables:

1. **Check the Data panel** (left sidebar in Power Apps Studio)
   - All 8 tables should be listed
   - No warning icons should appear

2. **Test a screen:**
   - Go to **scrHome** screen
   - Click **Preview** (F5)
   - The screen should load without errors

3. **Check for errors:**
   - Look at the **App checker** panel (left sidebar, exclamation mark icon)
   - If you see errors like "Name isn't valid", it means a table connection is missing

---

## Common Issues and Solutions

### Issue: "This app includes connections to the following that are not available"

**Cause:** Tables referenced in the app don't exist in your environment yet

**Solution:**
1. Create all 8 tables first (see DATAVERSE_SCHEMA.md)
2. Then import the app
3. Connect the tables in the Data panel

### Issue: "Projects" table shows as "cr_projects" in formulas

**Cause:** This is normal - Power Apps shows the logical name in some contexts

**Solution:** No action needed. The app will work correctly.

### Issue: Choice fields (dropdowns) are empty

**Cause:** Choice values not created on the table columns

**Solution:**
1. Go to each table in Power Apps Maker
2. Open the column (e.g., `Customer` on Projects table)
3. Add the choice values from DATAVERSE_SCHEMA.md
4. Save and refresh the app

### Issue: Lookup relationships broken

**Cause:** Relationships not created between tables

**Solution:**
1. Open the child table (e.g., Projects)
2. Open the lookup column (e.g., `SubmissionId`)
3. Verify it's set to **Lookup** type
4. Ensure **Related table** is set to the parent (e.g., Submissions)

---

## Table Relationships Quick Reference

The app requires these **lookup relationships**:

| Child Table | Column | → | Parent Table |
|-------------|--------|---|--------------|
| Projects | SubmissionId | → | Submissions |
| Project Security Details | ProjectId | → | Projects |
| Project Security Details | FeatureId | → | Security Features |
| Project Documents | ProjectId | → | Projects |
| Ticket Messages | TicketId | → | Support Tickets |

**To verify relationships:**
1. Open the child table
2. Go to **Relationships** tab
3. Check that each lookup column has a relationship configured

---

## Placeholder Table Names (If Needed)

If you're creating tables programmatically or using the Dataverse API, you might need to use placeholders in configuration files.

The app doesn't require this for normal use, but if you need it:

```javascript
// In App.fx.yaml (OnStart section):
Set(gblTableNames, {
    Submissions: "<<TABLE_SUBMISSIONS_LOGICAL_NAME>>",
    Projects: "<<TABLE_PROJECTS_LOGICAL_NAME>>",
    // ... etc
});
```

**However, this is NOT recommended.** Power Apps handles table name mapping automatically through data connections.

---

## Summary Checklist

Before connecting the app:

- [ ] All 8 tables created in Dataverse
- [ ] Tables use the **exact Display Names** from DATAVERSE_SCHEMA.md
- [ ] All columns created with correct data types
- [ ] Choice columns have values added
- [ ] Lookup relationships configured
- [ ] Your user has permissions to read/write tables

After importing the app:

- [ ] Open app in Power Apps Studio
- [ ] Go to Data panel → Add data
- [ ] Search and add all 8 tables by Display Name
- [ ] No errors in App Checker
- [ ] Test app in Preview mode

---

## Need Help?

| If you see... | Check... |
|---------------|----------|
| "Name isn't valid" error | Data panel - add missing table |
| Empty dropdowns | Choice values on columns |
| "Cannot find related record" | Lookup relationships |
| "You do not have permission" | Security roles and table privileges |
| Tables don't appear in Add Data | Table ownership and refresh |

---

## Additional Resources

- **Microsoft Docs - Dataverse tables:** https://learn.microsoft.com/power-apps/maker/data-platform/entity-overview
- **Microsoft Docs - Table relationships:** https://learn.microsoft.com/power-apps/maker/data-platform/create-edit-entity-relationships
- **Power Apps community forums:** https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1

---

**Last Updated:** 2025-12-21
**Version:** 2.1
