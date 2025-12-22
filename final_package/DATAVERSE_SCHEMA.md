# Dataverse Schema Documentation

## Table Overview

This Power Apps Canvas App requires **4 Dataverse tables** with specific relationships and columns. Understanding Dataverse table naming conventions is critical for successful implementation.

---

## Table Naming Conventions

### Display Name vs. Logical Name

**Display Name:**
- What you see in the Power Apps UI
- User-friendly, can contain spaces
- Example: `Security Features`

**Logical Name:**
- Internal database name used in PowerFx formulas
- No spaces, lowercase, includes publisher prefix
- Example: `cr_securityfeature` (with publisher prefix `cr_`)

### Publisher Prefix

Every Dataverse table has a **publisher prefix** that prevents naming conflicts:

- **System tables** (built-in): No prefix (e.g., `Account`, `Contact`)
- **Custom tables**: Prefix depends on your environment's publisher
  - Common prefixes: `cr_`, `new_`, `abc_`, `company_`
  - Your environment's prefix can be found in **Settings** → **Solutions** → **Publishers**

**CRITICAL:** The table names in this app's PowerFx code use **placeholder logical names**. You **MUST** update them to match your environment's actual logical names after creating the tables.

---

## How to Find Your Table's Logical Name

### Method 1: In Power Apps Maker Portal

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select **Tables** (left nav, under "Dataverse")
3. Find your table in the list
4. Click the table name
5. Look at the **Properties** pane on the right:
   - **Display Name:** `Security Features`
   - **Logical Name:** `cr_securityfeature` ← **This is what you need**

### Method 2: In the Table Definition

1. Open the table you created
2. Click **Settings** → **Advanced options**
3. Look for **Logical name**: `cr_securityfeature`

### Method 3: In the Column Properties

1. Open a table
2. Click on a column (e.g., `Feature Name`)
3. Look at **Logical name**: `cr_featurename`

---

## Required Tables and Columns

### 1. Submissions Table

**Purpose:** Tracks intake submissions (Draft or Submitted status)

| Display Name | Logical Name (Example) | Type | Required | Notes |
|--------------|------------------------|------|----------|-------|
| **Submission ID** | `cr_submissionid` | Autonumber | Yes | Primary Key, format: `SUB-{SEQNUM:6}` |
| Created By Email | `cr_createdbyemail` | Single Line of Text | Yes | Auto-populated with `User().Email` |
| Created By Name | `cr_createdbyname` | Single Line of Text | Yes | Auto-populated with `User().FullName` |
| **Status** | `cr_status` | Choice | Yes | Choices: `Draft`, `Submitted`, `Under Review`, `Approved`, `Rejected` |
| Submitted On | `cr_submittedon` | Date and Time | No | Populated when status → Submitted |
| Last Saved On | `cr_lastsavedon` | Date and Time | No | Updated by autosave timer |
| Last Visited Screen | `cr_lastvisitedscreen` | Single Line of Text | No | For draft resume (screen name) |
| Total Project Count | `cr_totalprojectcount` | Whole Number | No | Calculated on submit |
| Complete Project Count | `cr_completeprojectcount` | Whole Number | No | Calculated on submit |
| Total Security Features | `cr_totalsecurityfeatures` | Whole Number | No | Sum of all project features |

**Relationships:**
- One-to-Many with `Projects` (via `SubmissionId` lookup)

---

### 2. Projects Table

**Purpose:** Individual projects within a submission (max 5 per submission)

| Display Name | Logical Name (Example) | Type | Required | Notes |
|--------------|------------------------|------|----------|-------|
| **Project ID** | `cr_projectid` | Autonumber | Yes | Primary Key, format: `PROJ-{SEQNUM:6}` |
| **Submission ID** | `cr_submissionid` | Lookup (to Submissions) | Yes | Parent submission |
| Project Index | `cr_projectindex` | Whole Number | Yes | 1-5 (order in submission) |
| **Project Name** | `cr_projectname` | Single Line of Text | Yes | Max 255 chars |
| **Customer** | `cr_customer` | Choice | Yes | Choices: `BMW`, `Audi`, `VW`, `Daimler`, `JLR`, `Other` |
| Customer Other | `cr_customerother` | Single Line of Text | No | Required if Customer = "Other" |
| **Project Status** | `cr_projectstatus` | Choice | No | Choices: `Planned`, `In Development`, `In Production`, `Maintenance`, `Other` |
| Project Status Other | `cr_projectstatusother` | Single Line of Text | No | Required if Status = "Other" |
| Bosch Contact / Owner | `cr_boschcontactowner` | Single Line of Text | No | Name or email |
| Customer Contact | `cr_customercontact` | Single Line of Text | No | Name or email |
| **Microcontroller** | `cr_microcontroller` | Choice | No | Choices: `TC3xx`, `TC4xx`, `RH850`, `S32`, `Other` |
| Microcontroller Other | `cr_microcontrollerother` | Single Line of Text | No | Required if Microcontroller = "Other" |
| **Architecture** | `cr_architecture` | Choice | No | Choices: `Monolithic`, `Microservices`, `Event-Driven`, `Layered`, `Other` |
| Architecture Other | `cr_architectureother` | Single Line of Text | No | Required if Architecture = "Other" |
| **Protocols** | `cr_protocols` | Single Line of Text | No | Comma-separated (LIN, CAN, Ethernet, Not applicable, Other) |
| Protocols Other | `cr_protocolsother` | Single Line of Text | No | Required if Protocols contains "Other" |
| Support Needs / Blockers | `cr_supportneedsblockers` | Multiple Lines of Text | No | |
| **Completion Status** | `cr_completionstatus` | Choice | Yes | Choices: `Not Started`, `In Progress`, `Complete` |
| Last Visited Step | `cr_lastvisitedstep` | Whole Number | No | 1-4 (wizard step) |
| Last Updated On | `cr_lastupdatedon` | Date and Time | No | Track changes |
| Selected Feature Count | `cr_selectedfeaturecount` | Whole Number | No | Calculated field |
| Missing Spec Count | `cr_missingspeccount` | Whole Number | No | Calculated field |
| Missing Required Count | `cr_missingrequiredcount` | Whole Number | No | Calculated field |

**Relationships:**
- Many-to-One with `Submissions`
- One-to-Many with `ProjectSecurityDetails`
- One-to-Many with `ProjectAttachments`

---

### 3. Security Features Table

**Purpose:** Master catalog of available security features

| Display Name | Logical Name (Example) | Type | Required | Notes |
|--------------|------------------------|------|----------|-------|
| **Feature ID** | `cr_featureid` | Autonumber | Yes | Primary Key, format: `FEAT-{SEQNUM:4}` |
| **Feature Name** | `cr_featurename` | Single Line of Text | Yes | E.g., "Secure Boot", "Memory Protection" |
| Description | `cr_description` | Multiple Lines of Text | No | |
| Category | `cr_category` | Choice | No | E.g., `Boot Security`, `Crypto`, `Access Control` |
| Display Order | `cr_displayorder` | Whole Number | No | Sorting priority |
| Is Active | `cr_isactive` | Yes/No | Yes | Default: Yes |

**Relationships:**
- One-to-Many with `ProjectSecurityDetails`

**Seed Data:**
Create initial records for:
- Secure Boot
- Memory Protection
- Cryptographic Services
- Access Control
- Update Security
- Communication Security
- Intrusion Detection
- Audit Logging

---

### 4. Project Security Details Table

**Purpose:** Links projects to selected security features with implementation details

| Display Name | Logical Name (Example) | Type | Required | Notes |
|--------------|------------------------|------|----------|-------|
| **Detail ID** | `cr_detailid` | GUID | Yes | Primary Key (auto-generated) |
| **Project ID** | `cr_projectid` | Lookup (to Projects) | Yes | Parent project |
| **Feature ID** | `cr_featureid` | Lookup (to Security Features) | Yes | Selected feature |
| **Spec Version** | `cr_specversion` | Single Line of Text | Yes | E.g., "v2.1", "ISO 26262-2018" |
| **Spec Details** | `cr_specdetails` | Multiple Lines of Text | Yes | Implementation description |
| **Implementation Status** | `cr_implementationstatus` | Choice | Yes | Choices: `Full`, `Partial`, `Planned` |
| Notes | `cr_notes` | Multiple Lines of Text | No | |

**Relationships:**
- Many-to-One with `Projects`
- Many-to-One with `Security Features`

---

### 5. Project Attachments Table (Optional - for Document Links)

**Purpose:** Store SharePoint document links for each project

| Display Name | Logical Name (Example) | Type | Required | Notes |
|--------------|------------------------|------|----------|-------|
| **Attachment ID** | `cr_attachmentid` | GUID | Yes | Primary Key |
| **Project ID** | `cr_projectid` | Lookup (to Projects) | Yes | Parent project |
| File Name | `cr_filename` | Single Line of Text | Yes | E.g., "Requirements_v1.2.docx" |
| File Type | `cr_filetype` | Choice | No | Choices: `Specification`, `Test Report`, `Security Doc`, `Other` |
| File URL | `cr_fileurl` | Single Line of Text (URL) | Yes | SharePoint link |
| Uploaded On | `cr_uploadedon` | Date and Time | No | Auto-populated |

**Relationships:**
- Many-to-One with `Projects`

---

## Creating Tables in Dataverse

### Step-by-Step Guide

1. **Go to [make.powerapps.com](https://make.powerapps.com)**
2. **Select your environment** (top right)
3. **Click "Tables"** (left nav, under Dataverse)
4. **Click "+ New table" → "Add columns and data"**

5. **For each table:**
   - Set the **Display name** (e.g., `Submissions`)
   - The system will auto-generate a **Logical name** (e.g., `cr_submission` with your prefix)
   - Enable **"Primary column"** and set its display name (e.g., `Submission ID`)
   - Click **Create**

6. **Add columns:**
   - Click **"+ New column"** for each column in the tables above
   - Match the **Type** (Text, Choice, Lookup, etc.)
   - For **Choice** columns, click "New choice" and add the values listed above
   - For **Lookup** columns, select the related table

7. **Set up relationships:**
   - In the `Projects` table, add a **Lookup column** named `Submission ID` pointing to the `Submissions` table
   - In the `ProjectSecurityDetails` table, add lookups for both `Project ID` and `Feature ID`

8. **Save and publish** each table

---

## Updating PowerFx Code with Your Logical Names

After creating the tables, you **MUST** update the PowerFx formulas in the Canvas app to use your **actual logical names**.

### Example: Finding and Replacing Table Names

**Original code (placeholder):**
```powerfx
Filter(Submissions, Status.Value = "Draft")
```

**Your environment's code (if your prefix is `abc_`):**
```powerfx
Filter(abc_submissions, Status.Value = "Draft")
```

### Where to Update Table Names in PowerFx

1. **App.fx.yaml** - OnStart, global variables
2. **scrHome.fx.yaml** - Draft check
3. **scrProjectList.fx.yaml** - Project list display
4. **scrWizardStep1-4.fx.yaml** - Form fields and Patch calls
5. **scrSubmissionReview.fx.yaml** - Submission patch and email
6. **scrMySubmissions.fx.yaml** - Submission list
7. **scrAdminDashboard.fx.yaml** - Admin queries

### Column Logical Names

Column references in PowerFx also use logical names:

**Example:**
- Display name: `Project Name`
- Logical name: `cr_projectname`

**In formulas:**
```powerfx
ThisItem.cr_projectname  // ❌ WRONG
ThisItem.ProjectName     // ✅ CORRECT (Power Apps abstracts this!)
```

**Important:** Power Apps typically allows you to use the **Display Name** in formulas for columns, but for **table names**, you must use the **logical name**.

---

## Quick Reference Table

| Table Display Name | Example Logical Name | Primary Column | Primary Key Type |
|--------------------|----------------------|----------------|------------------|
| Submissions | `cr_submission` | Submission ID | Autonumber (`SUB-{SEQNUM:6}`) |
| Projects | `cr_project` | Project ID | Autonumber (`PROJ-{SEQNUM:6}`) |
| Security Features | `cr_securityfeature` | Feature Name | Text |
| Project Security Details | `cr_projectsecuritydetail` | Detail ID | GUID |
| Project Attachments | `cr_projectattachment` | Attachment ID | GUID |

---

## Validation and Testing

After creating tables and importing the app:

1. **Test data connection:**
   - Open the app in Power Apps Studio
   - Check **Data** pane (left sidebar)
   - Verify all tables appear with green checkmarks

2. **Test form functionality:**
   - Create a new submission
   - Add a project
   - Select security features
   - Verify data saves correctly

3. **Check relationships:**
   - Ensure projects link to submissions
   - Ensure security details link to projects

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| "Table not found" error | Update PowerFx code with your actual logical table names |
| Column not recognized | Check spelling, ensure column exists in Dataverse table |
| Relationship missing | Verify lookup columns are created correctly |
| Data not saving | Check table permissions, ensure user has write access |
| Choice values missing | Verify choice columns have all required options |

---

## Publisher Prefix Configuration

If you need to create a **custom publisher** with your own prefix:

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. **Settings** → **Advanced Settings**
3. **Settings** → **Solutions**
4. **Publishers** → **New**
5. Set **Prefix** (e.g., `mycompany` becomes `mycompany_tablename`)

---

*Generated for Cross-Divisional Project Database v2.1*
