# Dataverse Solution

Place the exported Dataverse solution ZIP file here.

## File

- `SchoolOpinionsWSR_1_0_0_0.zip` - Complete Dataverse solution export

## How to Export

1. Open **Power Apps** → **Solutions**
2. Select **School Opinions WSR** solution
3. Click **Export** → **Export as Managed**
4. Download the ZIP file
5. Place it in this directory

## How to Import

Use the deployment script:
```powershell
.\deployment\deploy.ps1 -EnvironmentUrl "https://yourorg.crm4.dynamics.com"
```

Or manually:
1. Open **Power Apps** → **Solutions**
2. Click **Import**
3. Select the ZIP file
4. Follow the import wizard
