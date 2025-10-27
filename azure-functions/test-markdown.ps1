# Test script dla Markdown to HTML Azure Function (PowerShell)
# Użycie: .\test-markdown.ps1 [-Mode local|azure]

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("local", "azure")]
    [string]$Mode = "local"
)

if ($Mode -eq "local") {
    $Endpoint = "http://localhost:7071/api/markdown-to-html"
    Write-Host "Testing LOCAL endpoint: $Endpoint" -ForegroundColor Cyan
} else {
    # Zmień na swój endpoint
    $FunctionKey = $env:AZURE_FUNCTION_KEY ?? "YOUR_FUNCTION_KEY"
    $Endpoint = "https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html?code=$FunctionKey"
    Write-Host "Testing AZURE endpoint: $Endpoint" -ForegroundColor Cyan
}

Write-Host ""

# Test 1: Basic Markdown
Write-Host "==========================" -ForegroundColor Yellow
Write-Host "Test 1: Basic Markdown" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

$body1 = @{
    markdown = @"
## Ocena zachowania

Uczeń wykazuje **bardzo dobre** zachowanie.

### Mocne strony

- Aktywny udział w lekcjach
- Sumienność w wykonywaniu zadań
- Kultura osobista

### Obszary do rozwoju

- Większa pewność siebie podczas odpowiedzi
"@
    options = @{
        markedOptions = @{
            gfm = $true
            breaks = $true
        }
    }
} | ConvertTo-Json

$response1 = Invoke-RestMethod -Uri $Endpoint -Method Post -Body $body1 -ContentType "application/json"
$response1 | ConvertTo-Json -Depth 10

Write-Host ""
Write-Host ""

# Test 2: Complex Markdown with table
Write-Host "==========================" -ForegroundColor Yellow
Write-Host "Test 2: Complex Markdown" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

$body2 = @{
    markdown = @"
# Raport ucznia

## Oceny

| Przedmiot | Ocena | Uwagi |
|-----------|-------|-------|
| Matematyka | 5 | Wzorowy |
| Polski | 4 | Dobry |
| WF | 5 | Bardzo aktywny |

## Komentarz

Uczeń wykazuje **znakomite** postępy w nauce.
"@
    options = @{}
} | ConvertTo-Json

$response2 = Invoke-RestMethod -Uri $Endpoint -Method Post -Body $body2 -ContentType "application/json"
$response2 | ConvertTo-Json -Depth 10

Write-Host ""
Write-Host ""

# Test 3: XSS Protection
Write-Host "==========================" -ForegroundColor Yellow
Write-Host "Test 3: XSS Protection" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

$body3 = @{
    markdown = @"
<script>alert("XSS")</script>
## Normalny nagłówek
<img src=x onerror=alert(1)>

Bezpieczny **tekst**.
"@
    options = @{}
} | ConvertTo-Json

$response3 = Invoke-RestMethod -Uri $Endpoint -Method Post -Body $body3 -ContentType "application/json"
$response3 | ConvertTo-Json -Depth 10

Write-Host ""
Write-Host ""

# Test 4: Empty input (should fail)
Write-Host "==========================" -ForegroundColor Yellow
Write-Host "Test 4: Empty input" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

$body4 = @{
    options = @{}
} | ConvertTo-Json

try {
    $response4 = Invoke-RestMethod -Uri $Endpoint -Method Post -Body $body4 -ContentType "application/json"
    $response4 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Expected error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host ""
Write-Host "Tests completed!" -ForegroundColor Green
