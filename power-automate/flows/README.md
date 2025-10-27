# Power Automate Flows

Place the exported flow ZIP files here.

## Files (14 flows)

### SDS Import Flows
- `SDS_Import_School.zip` - Import schools from CSV
- `SDS_Import_Teachers.zip` - Import teachers from CSV
- `SDS_Import_Sections.zip` - Import sections/classes from CSV
- `SDS_Import_Students.zip` - Import students from CSV
- `SDS_Import_StudentEnrollment.zip` - Import student enrollments from CSV
- `SDS_Import_TeacherRoster.zip` - Import teacher rosters from CSV

### Opinion Workflow Flows
- `WSR_CreateDraftOpinions.zip` - Create draft opinions when cycle opens
- `WSR_SubmitOpinion.zip` - Process opinion submission
- `WSR_ApproveOpinion.zip` - Process opinion approval
- `WSR_RejectOpinion.zip` - Process opinion rejection
- `WSR_GenerateOpinionPDF.zip` - Generate PDF for opinion package
- `WSR_AggregateOpinions.zip` - Aggregate opinions for student
- `WSR_SendOpinionPackage.zip` - Send opinion package to parents
- `WSR_CloseCycle.zip` - Close opinion cycle

## How to Export

1. Open **Power Automate** → **My flows**
2. Select a flow
3. Click **Export** → **Package (.zip)**
4. Download the ZIP file
5. Place it in this directory

## How to Import

Use the deployment script:
```powershell
.\deployment\deploy.ps1 -EnvironmentUrl "https://yourorg.crm4.dynamics.com"
```

Or manually:
1. Open **Power Automate** → **My flows**
2. Click **Import** → **Import Package (Legacy)**
3. Upload the ZIP file
4. Configure connection references
5. Click **Import**

## After Import

Don't forget to:
1. Update connection references
2. Set environment variables
3. Turn on the flows
4. Test each flow
