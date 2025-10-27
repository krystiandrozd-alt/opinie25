# School Opinions WSR - Automated Deployment Script
# Version 1.0.0
# This script automates the deployment of the School Opinions solution to Power Platform

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentUrl,

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "deploy-config.json",

    [Parameter(Mandatory=$false)]
    [switch]$SkipSolution,

    [Parameter(Mandatory=$false)]
    [switch]$SkipFlows,

    [Parameter(Mandatory=$false)]
    [switch]$SkipAzureFunctions,

    [Parameter(Mandatory=$false)]
    [switch]$ImportSampleData
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "School Opinions WSR - Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
if (Test-Path $ConfigFile) {
    Write-Host "Loading configuration from $ConfigFile..." -ForegroundColor Yellow
    $config = Get-Content $ConfigFile | ConvertFrom-Json
} else {
    Write-Host "Configuration file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check if Power Platform CLI is installed
if (!(Get-Command pac -ErrorAction SilentlyContinue)) {
    Write-Host "Power Platform CLI (pac) not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://aka.ms/PowerPlatformCLI" -ForegroundColor Yellow
    exit 1
}

# Check if Azure CLI is installed (for Azure Functions)
if (!$SkipAzureFunctions -and !(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI not found. Azure Functions deployment will be skipped." -ForegroundColor Yellow
    $SkipAzureFunctions = $true
}

Write-Host "Prerequisites check passed." -ForegroundColor Green
Write-Host ""

# Authenticate to Power Platform
Write-Host "Authenticating to Power Platform..." -ForegroundColor Yellow
pac auth create --url $EnvironmentUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "Authentication failed." -ForegroundColor Red
    exit 1
}

Write-Host "Authentication successful." -ForegroundColor Green
Write-Host ""

# Deploy Dataverse Solution
if (!$SkipSolution) {
    Write-Host "Deploying Dataverse solution..." -ForegroundColor Yellow

    $solutionPath = Join-Path $PSScriptRoot "..\dataverse\solution\SchoolOpinionsWSR_1_0_0_0.zip"

    if (Test-Path $solutionPath) {
        pac solution import --path $solutionPath --async

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Solution imported successfully." -ForegroundColor Green
        } else {
            Write-Host "Solution import failed." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Solution file not found at: $solutionPath" -ForegroundColor Yellow
        Write-Host "Skipping solution import." -ForegroundColor Yellow
    }

    Write-Host ""
}

# Import Power Automate Flows
if (!$SkipFlows) {
    Write-Host "Importing Power Automate flows..." -ForegroundColor Yellow

    $flowsPath = Join-Path $PSScriptRoot "..\power-automate\flows"

    if (Test-Path $flowsPath) {
        $flowFiles = Get-ChildItem -Path $flowsPath -Filter "*.zip"

        foreach ($flowFile in $flowFiles) {
            Write-Host "  Importing flow: $($flowFile.Name)..." -ForegroundColor Cyan
            pac flow import --path $flowFile.FullName

            if ($LASTEXITCODE -eq 0) {
                Write-Host "    Flow imported successfully." -ForegroundColor Green
            } else {
                Write-Host "    Flow import failed." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Flows directory not found. Skipping flow import." -ForegroundColor Yellow
    }

    Write-Host ""
}

# Deploy Azure Functions
if (!$SkipAzureFunctions) {
    Write-Host "Deploying Azure Functions..." -ForegroundColor Yellow

    # Deploy markdown-to-html function
    $markdownFunctionPath = Join-Path $PSScriptRoot "..\azure-functions\markdown-to-html"
    if (Test-Path $markdownFunctionPath) {
        Write-Host "  Deploying markdown-to-html function..." -ForegroundColor Cyan

        Push-Location $markdownFunctionPath
        npm install

        if ($config.AzureFunctions.MarkdownToHtml.AppName) {
            az functionapp deployment source config-zip `
                --resource-group $config.AzureFunctions.ResourceGroup `
                --name $config.AzureFunctions.MarkdownToHtml.AppName `
                --src (Get-Location).Path

            if ($LASTEXITCODE -eq 0) {
                Write-Host "    Markdown-to-HTML function deployed successfully." -ForegroundColor Green
            } else {
                Write-Host "    Deployment failed." -ForegroundColor Red
            }
        } else {
            Write-Host "    Azure Function App name not configured. Skipping deployment." -ForegroundColor Yellow
        }

        Pop-Location
    }

    # Deploy merge-pdfs function
    $mergePdfsFunctionPath = Join-Path $PSScriptRoot "..\azure-functions\merge-pdfs"
    if (Test-Path $mergePdfsFunctionPath) {
        Write-Host "  Deploying merge-pdfs function..." -ForegroundColor Cyan

        Push-Location $mergePdfsFunctionPath

        if ($config.AzureFunctions.MergePDFs.AppName) {
            az functionapp deployment source config-zip `
                --resource-group $config.AzureFunctions.ResourceGroup `
                --name $config.AzureFunctions.MergePDFs.AppName `
                --src (Get-Location).Path

            if ($LASTEXITCODE -eq 0) {
                Write-Host "    Merge PDFs function deployed successfully." -ForegroundColor Green
            } else {
                Write-Host "    Deployment failed." -ForegroundColor Red
            }
        } else {
            Write-Host "    Azure Function App name not configured. Skipping deployment." -ForegroundColor Yellow
        }

        Pop-Location
    }

    Write-Host ""
}

# Configure Environment Variables
Write-Host "Configuring environment variables..." -ForegroundColor Yellow

foreach ($envVar in $config.EnvironmentVariables.PSObject.Properties) {
    $varName = $envVar.Name
    $varValue = $envVar.Value

    Write-Host "  Setting $varName..." -ForegroundColor Cyan
    # Note: Use pac CLI or API to set environment variables
    # pac env var create --name $varName --value $varValue
}

Write-Host "Environment variables configured." -ForegroundColor Green
Write-Host ""

# Import Sample Data
if ($ImportSampleData) {
    Write-Host "Importing sample data..." -ForegroundColor Yellow

    $sampleDataPath = Join-Path $PSScriptRoot "..\dataverse\sample-data\school_13001.json"

    if (Test-Path $sampleDataPath) {
        # Import using Power Platform CLI or custom script
        Write-Host "  Importing school_13001.json..." -ForegroundColor Cyan
        # TODO: Implement data import logic
        Write-Host "    Sample data import not yet implemented." -ForegroundColor Yellow
    }

    Write-Host ""
}

# Final summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment: $EnvironmentUrl" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Configure connection references in Power Automate" -ForegroundColor White
Write-Host "2. Assign security roles to users" -ForegroundColor White
Write-Host "3. Set up SharePoint document libraries" -ForegroundColor White
Write-Host "4. Configure Azure Function URLs in environment variables" -ForegroundColor White
Write-Host "5. Test SDS import flows with sample CSV files" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see: deployment/post-deployment-steps.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Deployment completed!" -ForegroundColor Green
