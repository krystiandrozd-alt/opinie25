# SharePoint Configuration

Configuration files for SharePoint libraries used by the solution.

## Files

- `site-template.xml` - SharePoint site template (to be created)
- `libraries/SDS_Import.json` - Configuration for SDS Import library
- `libraries/OpinionPDFs.json` - Configuration for Opinion PDFs library

## Setup

### Create SharePoint Site

1. Go to **SharePoint Admin Center**
2. Click **Active sites** → **Create**
3. Select **Team site**
4. Name: "School Opinions"
5. URL: `/sites/SchoolOpinions`

### Create Document Libraries

#### SDS_Import Library

1. On the SharePoint site, click **New** → **Document library**
2. Name: `SDS_Import`
3. Add columns as defined in `libraries/SDS_Import.json`:
   - ImportDate (Date and Time)
   - FileType (Choice)
   - ImportStatus (Choice)
   - RecordsProcessed (Number)
   - ErrorMessage (Multiple lines of text)

#### OpinionPDFs Library

1. Click **New** → **Document library**
2. Name: `OpinionPDFs`
3. Add columns as defined in `libraries/OpinionPDFs.json`:
   - StudentName (Text)
   - SectionName (Text)
   - SchoolYear (Text)
   - Semester (Choice)
   - OpinionCycleID (Text)
   - PackageID (Text)
   - GeneratedDate (Date and Time)
   - SentToParents (Yes/No)
   - SentDate (Date and Time)
   - ParentEmail (Text)
   - TotalPages (Number)
   - OpinionCount (Number)

4. Create folder structure:
   - `/2024-2025/Semester1`
   - `/2024-2025/Semester2`
   - `/Archive`

### Permissions

1. Break inheritance for both libraries
2. Grant permissions:
   - **Full Control**: School Administrators
   - **Contribute**: Homeroom Teachers (OpinionPDFs only)
   - **Contribute**: System Flows service account

## Update Environment Variables

After creating libraries, update these environment variables in Power Platform:
- `SharePoint_SiteURL`
- `SharePoint_SDSLibrary`
- `SharePoint_OpinionPDFsLibrary`
