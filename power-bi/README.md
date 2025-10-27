# Power BI Reports

Place the Power BI report file here.

## File

- `OpinionCycleKPIs.pbix` - Opinion Cycle KPIs and Dashboards

## How to Create

1. Open **Power BI Desktop**
2. Connect to **Dataverse** environment
3. Import tables:
   - wsr_school
   - wsr_section
   - wsr_teacher
   - wsr_student
   - wsr_opinioncycle
   - wsr_opinion
   - wsr_studentopinionpackage

4. Create measures (see `dataset-config.json` for definitions)
5. Build report pages:
   - Overview
   - Teacher Performance
   - Package Status

6. Save as `OpinionCycleKPIs.pbix`

## How to Publish

1. Open the `.pbix` file in **Power BI Desktop**
2. Click **Publish**
3. Select workspace
4. Configure refresh schedule
5. Share with users

## Data Refresh

Configure automatic refresh:
1. Go to **Power BI Service**
2. Open dataset settings
3. Configure **Scheduled refresh**
4. Set to run daily at 6:00 AM

## Security

Configure Row-Level Security (RLS):
1. Define roles in Power BI Desktop
2. Set filters (see `dataset-config.json`)
3. Publish to service
4. Assign users to roles
