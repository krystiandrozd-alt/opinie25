# Post-Deployment Steps

After running the automated deployment script, complete these manual steps to fully configure the School Opinions WSR system.

## 1. Configure Connection References

### Power Automate Connections

1. Go to **Power Automate** → **Data** → **Connections**
2. Create the following connections if they don't exist:
   - **Microsoft Dataverse** - Connect using your service account
   - **Office 365 Outlook** - Connect using the system email account
   - **SharePoint** - Connect to your SharePoint site
   - **Azure Functions** (if using) - Configure with Function Keys

3. Update all flows with correct connection references:
   - Open each flow
   - Update connection references
   - Save and test the flow

## 2. Configure Environment Variables

Go to **Power Apps** → **Solutions** → **School Opinions WSR** → **Environment Variables**

Update the following variables with your actual values:

| Variable Name | Example Value | Description |
|--------------|---------------|-------------|
| SharePoint_SiteURL | `https://contoso.sharepoint.com/sites/SchoolOpinions` | SharePoint site URL |
| SharePoint_SDSLibrary | `SDS_Import` | Library name for SDS CSV files |
| SharePoint_OpinionPDFsLibrary | `OpinionPDFs` | Library for generated PDFs |
| AzureFunction_MarkdownToHTML_URL | `https://func-markdown.azurewebsites.net/api/markdown-to-html` | Markdown conversion function URL |
| AzureFunction_MergePDFs_URL | `https://func-mergepdf.azurewebsites.net/api/merge-pdfs` | PDF merge function URL |
| Email_SenderAddress | `noreply@school.edu.pl` | From address for automated emails |

## 3. Set Up SharePoint Document Libraries

### Create SDS_Import Library

1. Navigate to your SharePoint site
2. Create a new document library named **SDS_Import**
3. Add the following columns:
   - ImportDate (Date and Time)
   - FileType (Choice: School, Teacher, Section, Student, StudentEnrollment, TeacherRoster)
   - ImportStatus (Choice: Pending, Processing, Completed, Failed)
   - RecordsProcessed (Number)
   - ErrorMessage (Multiple lines of text)
4. Create a view "Pending Imports" filtered by ImportStatus = "Pending"

### Create OpinionPDFs Library

1. Create a new document library named **OpinionPDFs**
2. Add the following columns:
   - StudentName (Single line of text)
   - SectionName (Single line of text)
   - SchoolYear (Single line of text)
   - Semester (Choice: Semester 1, Semester 2, Year-End)
   - OpinionCycleID (Single line of text)
   - PackageID (Single line of text)
   - GeneratedDate (Date and Time)
   - SentToParents (Yes/No)
   - SentDate (Date and Time)
   - ParentEmail (Single line of text)
3. Create folder structure:
   - `/2024-2025/Semester1`
   - `/2024-2025/Semester2`
   - `/Archive`

## 4. Configure Security Roles and Permissions

### Assign Security Roles

1. Go to **Power Platform Admin Center**
2. Select your environment → **Settings** → **Users + permissions** → **Security roles**
3. Assign roles to users:

| User Type | Security Role | Notes |
|-----------|--------------|-------|
| Subject Teachers | WSR Teacher | Can create/edit own opinions |
| Homeroom Teachers | WSR Homeroom Teacher | Can review and approve opinions for their class |
| School Principal | WSR Principal | Full access to all data |
| System Administrator | System Administrator | For IT staff |

### Configure Dataverse Teams

1. Create Azure AD security groups:
   - **All Teachers** - All teaching staff
   - **Homeroom Teachers** - Teachers who are class homeroom teachers
   - **School Administration** - Principal and vice-principals

2. Link these groups to Dataverse teams
3. Assign security roles to teams

## 5. Deploy Azure Functions

### Markdown to HTML Function

```bash
cd azure-functions/markdown-to-html
npm install
func azure functionapp publish func-schoolopinions-markdown-prod
```

Get the function URL and key:
```bash
func azure functionapp list-functions func-schoolopinions-markdown-prod --show-keys
```

### Merge PDFs Function

```bash
cd azure-functions/merge-pdfs
pip install -r requirements.txt
func azure functionapp publish func-schoolopinions-mergepdf-prod --build remote
```

Get the function URL and key:
```bash
func azure functionapp list-functions func-schoolopinions-mergepdf-prod --show-keys
```

Update environment variables with these URLs.

## 6. Configure SDS Data Import

### Prepare CSV Files

Ensure your School Data Sync (SDS) exports contain the following files:

1. **School.csv**
   - Columns: `SDS ORG ID`, `Name`, `School Number`, `City`, `Address`

2. **Teacher.csv**
   - Columns: `SDS ID`, `First Name`, `Last Name`, `Email`, `Title`

3. **Section.csv**
   - Columns: `SDS ID`, `School SDS ID`, `Section Name`, `Grade`, `School Year`

4. **Student.csv**
   - Columns: `SDS ID`, `First Name`, `Last Name`, `Email`, `Student Number`, `Birth Date`, `Parent Email`

5. **StudentEnrollment.csv**
   - Columns: `SDS ID`, `Section SDS ID`, `Student SDS ID`, `Enrollment Date`

6. **TeacherRoster.csv**
   - Columns: `SDS ID`, `Section SDS ID`, `Teacher SDS ID`, `Subject`, `Role`

### Upload CSV Files

1. Upload CSV files to **SDS_Import** SharePoint library
2. Set FileType metadata for each file
3. Flows will automatically process files daily at 2:00 AM
4. Or manually trigger flows for immediate import

## 7. Create First Opinion Cycle

1. Open **School Opinions Manager** app
2. Go to **Opinion Cycles**
3. Click **New**
4. Fill in:
   - Name: "Semester 1 2024/2025"
   - School Year: "2024/2025"
   - Semester: "Semester 1"
   - Start Date: 2024-09-01
   - End Date: 2025-01-31
   - Submission Deadline: 2025-01-15
   - Approval Deadline: 2025-01-25
   - Template Markdown: (copy from sample)
5. Set Status to **Open**
6. This will automatically create draft opinions for all students

## 8. Test the System

### Test Opinion Creation Flow

1. Log in as a subject teacher
2. Open an opinion in Draft status
3. Fill in the markdown content
4. Change status to **Submitted**
5. Verify:
   - HTML is generated
   - Word/character count is calculated
   - Homeroom teacher receives notification

### Test Opinion Approval Flow

1. Log in as a homeroom teacher
2. Review a submitted opinion
3. Change status to **Approved**
4. Verify:
   - Student opinion package is updated
   - Subject teacher receives confirmation

### Test PDF Generation

1. When all opinions for a student are approved
2. Package status should change to "Ready for Review"
3. Manually trigger PDF generation
4. Verify:
   - PDF is created in SharePoint
   - PDF URL is stored in package record

### Test Email Delivery

1. Trigger "Send Opinion Package" flow
2. Verify:
   - Email is sent to parent
   - PDF is attached
   - Package status changes to "Sent to Parents"

## 9. Configure Power BI Reports

1. Open **Power BI Desktop**
2. Import `OpinionCycleKPIs.pbix`
3. Update data source connection to your Dataverse environment
4. Publish to Power BI Service
5. Configure refresh schedule
6. Share with school administrators

## 10. Train Users

### Training Materials

Create training sessions for:

1. **Subject Teachers** (1 hour)
   - How to access the app
   - Writing opinions in Markdown
   - Submitting opinions
   - Responding to revision requests

2. **Homeroom Teachers** (2 hours)
   - All subject teacher tasks
   - Reviewing and approving opinions
   - Adding homeroom comments
   - Generating and sending packages

3. **Administrators** (3 hours)
   - Creating opinion cycles
   - Managing SDS imports
   - Monitoring progress
   - Using Power BI dashboards
   - Troubleshooting issues

## 11. Monitoring and Maintenance

### Daily Checks

- Monitor SDS import flows for failures
- Check for failed opinion submissions
- Review error logs in Application Insights

### Weekly Tasks

- Review opinion completion rates
- Send reminders to teachers with pending opinions
- Check Azure Function performance metrics

### Monthly Tasks

- Review and archive old opinion cycles
- Clean up unused SharePoint files
- Update security role assignments
- Review and optimize Power Automate flows

## 12. Backup and Disaster Recovery

### Dataverse Backups

- Dataverse automatic backups are enabled
- Retention: 28 days
- For critical cycles, export solution as unmanaged

### SharePoint Backups

- Configure SharePoint retention policies
- Keep PDFs for at least 5 years (legal requirement)
- Archive old files annually

### Azure Functions

- Keep source code in Git repository
- Document function keys securely
- Test disaster recovery procedures quarterly

## Support Contacts

- **Technical Support**: it-support@yourschool.edu.pl
- **Power Platform Admin**: admin@yourschool.edu.pl
- **School Administration**: principal@yourschool.edu.pl

---

## Troubleshooting Common Issues

### Issue: SDS Import Fails

**Solution:**
1. Check CSV file format matches specification
2. Verify SharePoint permissions for flow service account
3. Check flow run history for detailed error messages
4. Validate data in CSV files (no missing required fields)

### Issue: Opinion HTML Not Generated

**Solution:**
1. Verify Azure Function URL is correct in environment variables
2. Check Azure Function logs for errors
3. Test function directly with sample markdown
4. Verify function authentication keys are valid

### Issue: PDF Not Generated

**Solution:**
1. Check if all opinions are approved
2. Verify SharePoint library permissions
3. Check Azure Function for PDF merge
4. Review flow run history

### Issue: Email Not Sent

**Solution:**
1. Verify Office 365 connection is valid
2. Check parent email address is correct
3. Review email sending limits
4. Check flow run history for errors

---

**Last Updated:** 2024-10-27
**Version:** 1.0.0
