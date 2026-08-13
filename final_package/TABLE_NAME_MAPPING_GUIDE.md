# Table Name Mapping Guide

## TL;DR

**You do NOT need to guess logical names.**

Just:
1. Create tables in Dataverse using the **Display Names** shown below
2. Add the tables to your app via the **Data** panel in Power Apps Studio
3. Power Apps will handle the name mapping automatically

---

## Understanding Table Names in Dataverse

### Display Name vs. Logical Name

When you create a table in Dataverse:

| Display Name | Logical Name | What You Use in PowerFx |
|--------------|--------------|-------------------------|
| **Submissions** | `cr_submission` | `Submissions` (Display Name works!) |
| **Projects** | `cr_project` | `Projects` |
| **Security Features** | `cr_securityfeature` | `SecurityFeatures` (or `Security Features`) |

**Good news:** Power Apps lets you use **Display Names** in formulas once the table is connected!

---

## How to Handle Table Names

### Step 1: Create Tables with These Display Names

Go to [make.powerapps.com](https://make.powerapps.com) → **Tables** → **+ New table**

Create these 5 tables:

1. **Submissions**
2. **Projects**
3. **Security Features**
4. **Project Security Details**
5. **Project Attachments**

**Note:** Use these EXACT display names (or similar). Dataverse will auto-generate logical names like `cr_submission`, `new_submission`, etc. depending on your publisher prefix.

### Step 2: Add Tables to Your App

1. Open the app in Power Apps Studio (Edit mode)
2. Click **Data** (left sidebar, database icon)
3. Click **+ Add data**
4. Search for each table by **Display Name**:
   - Type "Submissions"
   - Click the table when it appears
   - Repeat for all 5 tables

### Step 3: Verify Connections

In the **Data** panel, you should see:
- ✅ Submissions (green checkmark)
- ✅ Projects (green checkmark)
- ✅ Security Features (green checkmark)
- ✅ Project Security Details (green checkmark)
- ✅ Project Attachments (green checkmark)

**If green checkmarks appear:** ✅ **You're done!** The app will work.

**If you see errors:** The table name in the Canvas Source doesn't match your environment.

---

## If You See "Table Not Found" Errors

### Option 1: Use Display Names (Easiest)

Power Apps usually accepts display names in formulas. If you created a table with display name "Submissions", you can write:

```powerfx
Filter(Submissions, Status.Value = "Draft")
```

And it should work!

### Option 2: Find and Replace Logical Names (If Needed)

If your environment uses a custom prefix (e.g., `abc_` instead of `cr_`):

1. In Power Apps Studio, click **Data** panel
2. Hover over each table to see the **logical name**
3. Note your prefix (e.g., `abc_submission`)

**Only if formulas break:**
- Open Tree View → App → OnStart
- Find-Replace:
  - `Submissions` → `abc_submissions` (if needed)
  - `Projects` → `abc_projects`
  - etc.

**But this is RARE.** Usually, Power Apps handles it automatically.

---

## Publisher Prefix Explained

Every Dataverse environment has a **publisher prefix** that gets added to table names:

| Environment Type | Common Prefix | Example Logical Name |
|------------------|---------------|----------------------|
| Default | `cr_` | `cr_submission` |
| Custom Publisher | `abc_`, `new_`, `contoso_` | `abc_submission` |
| System Tables | (none) | `Account`, `Contact` |

**Where to find your prefix:**
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. **Settings** → **Advanced Settings** → **Solutions** → **Publishers**
3. Look at the **Prefix** column

**Example:**
- Prefix: `cr`
- Display Name: `Submissions`
- Logical Name: `cr_submission`

---

## Table and Column Reference

### Submissions Table

| Display Name | Logical Name Example | Type |
|--------------|----------------------|------|
| **Submissions** | `cr_submission` | Table |
| Submission ID | `cr_submissionid` | Autonumber |
| Status | `cr_status` | Choice |
| Created By Email | `cr_createdbyemail` | Text |
| Submitted On | `cr_submittedon` | Date/Time |

**In PowerFx:** Just use the display names:
```powerfx
Patch(Submissions, ..., { Status: {Value: "Submitted"} })
```

### Projects Table

| Display Name | Logical Name Example | Type |
|--------------|----------------------|------|
| **Projects** | `cr_project` | Table |
| Project ID | `cr_projectid` | Autonumber |
| Submission ID | `cr_submissionid` | Lookup |
| Project Name | `cr_projectname` | Text |
| Customer | `cr_customer` | Choice |

**In PowerFx:**
```powerfx
Filter(Projects, SubmissionId.SubmissionId = mySubmissionId)
```

### Security Features Table

| Display Name | Logical Name Example | Type |
|--------------|----------------------|------|
| **Security Features** | `cr_securityfeature` | Table |
| Feature Name | `cr_featurename` | Text |
| Category | `cr_category` | Choice |
| Display Order | `cr_displayorder` | Number |

### Project Security Details Table

| Display Name | Logical Name Example | Type |
|--------------|----------------------|------|
| **Project Security Details** | `cr_projectsecuritydetail` | Table |
| Project ID | `cr_projectid` | Lookup |
| Feature ID | `cr_featureid` | Lookup |
| Spec Version | `cr_specversion` | Text |
| Spec Details | `cr_specdetails` | Multiple Lines |

### Project Attachments Table

| Display Name | Logical Name Example | Type |
|--------------|----------------------|------|
| **Project Attachments** | `cr_projectattachment` | Table |
| Project ID | `cr_projectid` | Lookup |
| File Name | `cr_filename` | Text |
| File URL | `cr_fileurl` | Text (URL) |

---

## FAQ

### Q: Do I need to know the logical names?

**A:** No, not usually. Power Apps uses display names in formulas after you add the table to the Data panel.

### Q: What if my logical names are different?

**A:** If you created tables with the display names above, Power Apps will map them correctly. Just add them via the Data panel.

### Q: How do I know if I need to change formulas?

**A:** If you see "table not found" errors after adding data sources, then you may need to update formulas. But try adding via Data panel first—it usually works!

### Q: Can I rename tables after import?

**A:** Yes, but it's easier to create them with the correct display names from the start.

### Q: What about column names?

**A:** Same rule: Power Apps uses display names. If you create a column "Project Name", you reference it as `ProjectName` or `"Project Name"` in formulas.

---

## Step-by-Step: Avoiding Name Issues

1. **Create tables in Dataverse** using these EXACT display names:
   - Submissions
   - Projects
   - Security Features
   - Project Security Details
   - Project Attachments

2. **Add columns** as described in `DATAVERSE_SCHEMA.md`

3. **Import the app** into Power Apps

4. **Open in Edit mode**

5. **Add data connections:**
   - Data panel → + Add data
   - Search for each table by display name
   - Click to add

6. **Test:** Click Play (▶️) and verify app loads

**If errors appear:**
- Check Data panel for red X marks
- Click the table → "Refresh" or "Remove and re-add"
- If still broken, check formula bar for specific error messages

---

## Real Example: Creating Submissions Table

1. Go to [make.powerapps.com](https://make.powerapps.com) → **Tables**
2. Click **+ New table** → **Add columns and data**
3. Enter **Display name:** `Submissions`
4. System generates **Logical name:** `cr_submission` (or similar)
5. Click **Create**
6. Add columns (Submission ID, Status, etc.)
7. Save and publish

**In Power Apps:**
8. Open your app → **Data** → **+ Add data**
9. Search: `Submissions`
10. Click the table in results
11. ✅ Table added! Use as: `Filter(Submissions, ...)`

---

## Summary

✅ **DO:**
- Create tables with display names: Submissions, Projects, etc.
- Add tables via Data panel using display names
- Use display names in formulas: `Submissions`, `Projects`

❌ **DON'T:**
- Worry about logical names or prefixes
- Manually edit PowerFx code for table names (unless errors occur)
- Try to import without Dataverse tables created first

**Key Takeaway:** Display names work in Power Apps formulas once you add the tables via the Data panel.

---

*For complete table schemas with all columns, see `DATAVERSE_SCHEMA.md`*
