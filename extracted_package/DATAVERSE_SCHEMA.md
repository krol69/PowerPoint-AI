# Dataverse Schema Documentation

## Overview

This document contains the complete schema for all 8 Dataverse tables required by the Cross-Divisional Project Database app.

---

## Table 1: Submissions (`cr_submissions`)

**Purpose:** Parent table for project intake submissions

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_submissionid` | Submission ID | Autonumber | Auto | Format: `SUB-{SEQNUM:5}` |
| `cr_createdbyemail` | Created By Email | Text (100) | Yes | User's email |
| `cr_createdbyname` | Created By Name | Text (100) | Yes | User's display name |
| `cr_status` | Status | Choice | Yes | Draft, Submitted, Returned, Archived |
| `cr_lastsavedon` | Last Saved On | DateTime | No | Autosave timestamp |
| `cr_submittedon` | Submitted On | DateTime | No | Final submission timestamp |
| `cr_lastvisitedscreen` | Last Visited Screen | Text (100) | No | For resume functionality |
| `cr_lastvisitedprojectindex` | Last Visited Project Index | Whole Number | No | For resume functionality |
| `cr_totalprojectcount` | Total Project Count | Whole Number | No | Calculated on submit |
| `cr_completeprojectcount` | Complete Project Count | Whole Number | No | Calculated on submit |
| `cr_totalsecurityfeatures` | Total Security Features | Whole Number | No | Sum across all projects |
| `cr_totalmissingspecs` | Total Missing Specs | Whole Number | No | Should be 0 to submit |

**Choice Values for Status:**
- Draft
- Submitted
- Returned
- Archived

---

## Table 2: Projects (`cr_projects`)

**Purpose:** Child table containing individual project details (1-5 per submission)

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_projectid` | Project ID | Autonumber | Auto | Format: `PRJ-{SEQNUM:5}` |
| `cr_submissionid` | Submission | Lookup | Yes | FK to Submissions |
| `cr_projectindex` | Project Index | Whole Number | Yes | 1-5 |
| `cr_projectname` | Project Name | Text (200) | Yes | |
| `cr_projectdescription` | Project Description | Multiline Text | No | |
| `cr_additionalinfo` | Additional Info | Multiline Text | No | |
| `cr_customer` | Customer | Choice | Yes | See values below |
| `cr_customerother` | Customer Other | Text (100) | No | If Customer = "Other" |
| `cr_projectstatus` | Project Status | Choice | Yes | See values below |
| `cr_projectstatusother` | Project Status Other | Text (100) | No | If Status = "Other" |
| `cr_architecture` | Architecture | Choice | Yes | See values below |
| `cr_architectureother` | Architecture Other | Text (100) | No | If Architecture = "Other" |
| `cr_microcontroller` | Microcontroller | Choice | Yes | See values below |
| `cr_microcontrollerother` | Microcontroller Other | Text (100) | No | If Microcontroller = "Other" |
| `cr_protocols` | Protocols | Text (500) | Yes | Comma-separated values |
| `cr_protocolsother` | Protocols Other | Text (200) | No | If "Other" in protocols |
| `cr_boschcontactowner` | Bosch Contact Owner | Text (200) | Yes | |
| `cr_customercontact` | Customer Contact | Text (200) | No | |
| `cr_supportneedsblockers` | Support Needs/Blockers | Multiline Text | No | |
| `cr_completionstatus` | Completion Status | Choice | Yes | Not Started, In Progress, Complete |
| `cr_selectedfeaturecount` | Selected Feature Count | Whole Number | No | Count of security features |
| `cr_missingspeccount` | Missing Spec Count | Whole Number | No | Features without specs |
| `cr_missingrequiredcount` | Missing Required Count | Whole Number | No | Required fields not filled |
| `cr_lastupdatedon` | Last Updated On | DateTime | No | |
| `cr_lastvisitedstep` | Last Visited Step | Whole Number | No | 1-4 for wizard resume |

**Choice Values:**

**Customer:**
- GM
- Ford
- Tesla
- Chrysler
- Other

**Project Status:**
- Acquisition
- In-Development
- In-Production
- Other

**Architecture:**
- VIP/GB
- SDV
- Stellabrain
- Not applicable
- Other

**Microcontroller:**
- Infineon AURIX
- NXP S32
- Renesas RH850
- STM32
- Other

**Completion Status:**
- Not Started
- In Progress
- Complete

---

## Table 3: Security Features (`cr_securityfeatures`)

**Purpose:** Catalog table of available security features (seed data - 22 records)

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_featureid` | Feature ID | Autonumber | Auto | Primary key |
| `cr_featurename` | Feature Name | Text (200) | Yes | |
| `cr_displayorder` | Display Order | Whole Number | Yes | For sorting |
| `cr_isactive` | Is Active | Yes/No | Yes | Default: Yes |

**Seed Data (22 records):**
1. Secure Flashing (Customer)
2. Secure Flashing (RB)
3. Encrypted Software Updates
4. Security Access (Customer)
5. Security Access (RB)
6. Hardware Interface Protection
7. Boot Time Integrity Checks
8. Encrypted Boot
9. Runtime Manipulation Detection
10. Secure Data Storage
11. Secure Logging
12. Sandboxing
13. Hardware-based Crypto Features
14. Secure In-Vehicle Communication
15. Secure Offboard Communication
16. Firewall
17. Host-based IDS
18. Network-based IDS
19. Vulnerability Monitoring
20. Security Maintenance
21. Software Signing incl. KMS
22. KMS Interface with OEM Infrastructure

---

## Table 4: Project Security Details (`cr_projectsecuritydetails`)

**Purpose:** Junction table linking projects to security features with specifications

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_projectsecuritydetailid` | ID | Autonumber | Auto | |
| `cr_projectid` | Project | Lookup | Yes | FK to Projects |
| `cr_featureid` | Feature | Lookup | Yes | FK to Security Features |
| `cr_specversion` | Spec Version | Text (50) | Yes* | Required when feature selected |
| `cr_specdetails` | Spec Details | Multiline Text | Yes* | Required when feature selected |
| `cr_implementationstatus` | Implementation Status | Choice | Yes | Full, Partial, Planned |

**Choice Values for Implementation Status:**
- Full
- Partial
- Planned

---

## Table 5: Project Attachments (`cr_projectattachments`)

**Purpose:** File storage for project-related documents

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_attachmentid` | Attachment ID | Autonumber | Auto | |
| `cr_projectid` | Project | Lookup | Yes | FK to Projects |
| `cr_filename` | File Name | Text (255) | Yes | |
| `cr_filetype` | File Type | Text (50) | No | MIME type |
| `cr_filesize` | File Size | Whole Number | No | In bytes |
| `cr_fileurl` | File URL | URL | No | If using SharePoint |
| `cr_filecontent` | File Content | File | No | If using Dataverse storage |

---

## Table 6: Tickets (`cr_tickets`)

**Purpose:** Support ticket system

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_ticketid` | Ticket ID | Autonumber | Auto | Format: `TKT-{SEQNUM:5}` |
| `cr_submissionid` | Submission | Lookup | No | Optional link |
| `cr_projectid` | Project | Lookup | No | Optional link |
| `cr_createdbyemail` | Created By Email | Text (100) | Yes | |
| `cr_createdbyname` | Created By Name | Text (100) | Yes | |
| `cr_category` | Category | Choice | Yes | See values below |
| `cr_priority` | Priority | Choice | Yes | Low, Medium, High |
| `cr_status` | Status | Choice | Yes | See values below |
| `cr_subject` | Subject | Text (200) | Yes | |
| `cr_description` | Description | Multiline Text | Yes | |
| `cr_assignedtoemail` | Assigned To | Text (100) | No | Admin email |
| `cr_closedon` | Closed On | DateTime | No | |

**Choice Values:**

**Category:**
- Data Question
- Security Feature
- Tooling
- Other

**Priority:**
- Low
- Medium
- High

**Status:**
- Open
- Waiting on User
- Waiting on Admin
- Closed

---

## Table 7: Ticket Messages (`cr_ticketmessages`)

**Purpose:** Chat messages within tickets

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_messageid` | Message ID | Autonumber | Auto | |
| `cr_ticketid` | Ticket | Lookup | Yes | FK to Tickets |
| `cr_senderemail` | Sender Email | Text (100) | Yes | |
| `cr_sendername` | Sender Name | Text (100) | Yes | |
| `cr_messagetext` | Message | Multiline Text | Yes | |
| `cr_senton` | Sent On | DateTime | Yes | |

---

## Table 8: App Config (`cr_appconfig`)

**Purpose:** Application configuration settings

| Column Name | Display Name | Data Type | Required | Notes |
|-------------|--------------|-----------|----------|-------|
| `cr_configkey` | Config Key | Text (100) | Yes | Primary Name column |
| `cr_configvalue` | Config Value | Text (500) | No | |
| `cr_description` | Description | Text (500) | No | |

**Required Seed Data:**

| ConfigKey | ConfigValue | Description |
|-----------|-------------|-------------|
| `AdminEmail` | `<<CHANGE_ADMIN_EMAIL>>` | Primary admin email for notifications |
| `AdminEmailCC` | (empty) | CC recipients (comma-separated) |
| `AdminGroupId` | (empty) | Azure AD group ID for admin detection |
| `AutosaveIntervalSeconds` | `90` | Autosave timer interval |
| `MaxProjectsPerSubmission` | `5` | Maximum projects per submission |

---

## Relationships Diagram

```
Submissions (1) ──────┬────── (N) Projects
                      │              │
                      │              ├──── (N) ProjectSecurityDetails ◄── SecurityFeatures
                      │              │
                      │              └──── (N) ProjectAttachments
                      │
                      └────── (N) Tickets ──── (N) TicketMessages

AppConfig (standalone)
SecurityFeatures (standalone catalog)
```

---

## Quick Setup Script (Power Platform CLI)

If you have `pac` installed, you can create tables programmatically. Otherwise, create them manually in [make.powerapps.com](https://make.powerapps.com) → Tables.

```bash
# Example: Create Submissions table
pac solution init --publisher-name YourCompany --publisher-prefix cr
pac table create --name submissions --display-name "Submissions"
# ... continue for each table
```

For most users, manual table creation in the maker portal is recommended.
