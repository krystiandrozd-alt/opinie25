# Azure Functions - School Opinions WSR

Dwie Azure Functions wspierające system School Opinions WSR.

## Funkcje

### 1. markdown-to-html (Node.js)

Konwersja Markdown na HTML z sanityzacją XSS.

**Runtime:** Node.js 18 LTS
**Endpoint:** `/api/markdown-to-html`
**Dokumentacja:** [markdown-to-html/README.md](markdown-to-html/README.md)

**Użycie:**
- Konwersja opinii z Markdown na HTML
- Automatyczna sanityzacja (zabezpieczenie przed XSS)
- Obliczanie statystyk tekstu (słowa, znaki)

### 2. merge-pdfs (Python)

Łączenie wielu PDF-ów i generowanie strony tytułowej.

**Runtime:** Python 3.11
**Endpoint:** `/api/merge-pdfs`
**Dokumentacja:** [merge-pdfs/README.md](merge-pdfs/README.md)

**Użycie:**
- Łączenie opinii z różnych przedmiotów w jeden PDF
- Generowanie profesjonalnej strony tytułowej
- Przygotowanie pakietu opinii do wysłania do rodziców

## Quick Start

### Konfiguracja w Azure Portal

Najłatwiejsza metoda - nie wymaga instalacji:

1. **Przejdź do przewodnika:** [SETUP_GUIDE.md](SETUP_GUIDE.md)
2. **Metoda 1** - deployment przez Azure Portal (krok po kroku)
3. **Zajmuje:** ~15 minut na obie funkcje

### Lokalne uruchomienie

Dla deweloperów chcących testować lokalnie:

#### Markdown to HTML

```bash
cd markdown-to-html
npm install
func start
```

Funkcja dostępna na: http://localhost:7071/api/markdown-to-html

#### Merge PDFs

```bash
cd merge-pdfs
pip install -r requirements.txt
func start
```

Funkcja dostępna na: http://localhost:7072/api/merge-pdfs

## Testowanie

### Testy automatyczne

**Linux/Mac:**
```bash
# Test Markdown function
chmod +x test-markdown.sh
./test-markdown.sh local    # Test lokalnie
./test-markdown.sh azure    # Test na Azure
```

**Windows:**
```powershell
# Test Markdown function
.\test-markdown.ps1 -Mode local   # Test lokalnie
.\test-markdown.ps1 -Mode azure   # Test na Azure
```

### Testy manualne

**Markdown to HTML:**
```bash
curl -X POST http://localhost:7071/api/markdown-to-html \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "## Test\n\nTo jest **test**.",
    "options": {}
  }'
```

**Merge PDFs:**
```bash
curl -X POST http://localhost:7072/api/merge-pdfs \
  -H "Content-Type: application/json" \
  -d '{
    "pdfs": [],
    "options": {
      "addCoverPage": true,
      "coverPageInfo": {
        "studentName": "Jan Kowalski",
        "sectionName": "1A"
      }
    }
  }'
```

## Deployment do Azure

### Metoda 1: Azure Portal (zalecana dla początkujących)

Zobacz: [SETUP_GUIDE.md](SETUP_GUIDE.md) → Metoda 1

### Metoda 2: VS Code (zalecana dla deweloperów)

1. Zainstaluj rozszerzenie **Azure Functions** w VS Code
2. Zaloguj się do Azure (`Ctrl+Shift+P` → `Azure: Sign In`)
3. Kliknij prawym na folder funkcji → **Deploy to Function App...**
4. Wybierz swoją Function App

### Metoda 3: Azure CLI (dla zaawansowanych)

```bash
# Markdown to HTML
cd markdown-to-html
npm install
func azure functionapp publish func-schoolopinions-markdown-prod

# Merge PDFs
cd ../merge-pdfs
func azure functionapp publish func-schoolopinions-mergepdf-prod --build remote
```

## Konfiguracja w Power Platform

Po wdrożeniu funkcji:

1. **Pobierz Function Keys:**
   - Azure Portal → Function App → Functions → [function name] → Function Keys
   - Skopiuj klucz `default`

2. **Pobierz Function URLs:**
   ```
   Markdown: https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html
   PDF: https://func-schoolopinions-mergepdf-prod.azurewebsites.net/api/merge-pdfs
   ```

3. **Zaktualizuj Environment Variables w Power Platform:**
   - Power Apps → Solutions → School Opinions WSR → Environment Variables
   - `AzureFunction_MarkdownToHTML_URL`: [URL]?code=[KEY]
   - `AzureFunction_MergePDFs_URL`: [URL]?code=[KEY]

## Integracja z Power Automate

### Przykład: Konwersja Markdown w Flow

```
1. Trigger: When opinion is submitted

2. HTTP Action:
   Method: POST
   URI: @{variables('MarkdownFunctionURL')}
   Body: {
     "markdown": "@{triggerBody()?['wsr_opinionmarkdown']}"
   }

3. Parse JSON:
   Content: @{body('HTTP')}

4. Update Dataverse:
   Opinion HTML: @{body('Parse_JSON')?['html']}
   Word Count: @{body('Parse_JSON')?['stats']?['wordCount']}
```

Szczegóły w dokumentacji każdej funkcji.

## Monitoring

### Application Insights

1. Azure Portal → Function App → Application Insights
2. Przejdź do **Logs**
3. Query:

```kusto
traces
| where timestamp > ago(24h)
| where cloud_RoleName contains "schoolopinions"
| order by timestamp desc
```

### Metryki

1. Application Insights → **Metrics**
2. Dodaj metryki:
   - Function Execution Count
   - Function Execution Duration
   - HTTP 5xx errors

## Koszty

### Consumption Plan (domyślny)

**Koszt miesięczny (przykład):**
- 10,000 wykonań/miesiąc
- Średnio 500ms każde
- **~€0.02-€0.05/miesiąc**

**Free tier:**
- 1 milion wykonań free
- 400,000 GB-s free

### Premium Plan

Jeśli potrzebujesz:
- Stały czas odpowiedzi (no cold start)
- Więcej pamięci
- VNET integration

**Koszt:**
- EP1: ~€120/miesiąc
- EP2: ~€240/miesiąc

## Troubleshooting

### Problem: "Host is not running"

**Rozwiązanie:**
1. Azure Portal → Function App → Restart
2. Sprawdź logs w Application Insights

### Problem: "Module not found"

**Rozwiązanie:**

**Node.js:**
```bash
# Kudu console (https://[app-name].scm.azurewebsites.net)
cd site/wwwroot
npm install
```

**Python:**
```bash
# Force remote build
az functionapp config appsettings set \
  --name [app-name] \
  --resource-group [rg-name] \
  --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

### Problem: "Function timeout"

**Rozwiązanie:**

Zwiększ timeout w `host.json`:
```json
{
  "functionTimeout": "00:10:00"
}
```

Lub przejdź na Premium Plan.

## Bezpieczeństwo

### Function Keys

- **NIGDY** nie commituj function keys do Git
- Używaj zmiennych środowiskowych
- Rotuj klucze regularnie (co 90 dni)

### CORS

Skonfiguruj dozwolone origins:
- `https://flow.microsoft.com`
- `https://*.powerapps.com`

### Input Validation

Obie funkcje walidują input:
- Sprawdzają typy danych
- Limitują rozmiar payload
- Sanityzują HTML (markdown-to-html)
- Walidują PDF (merge-pdfs)

## Dokumentacja

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Kompletny przewodnik konfiguracji
- **[markdown-to-html/README.md](markdown-to-html/README.md)** - Dokumentacja funkcji Markdown
- **[merge-pdfs/README.md](merge-pdfs/README.md)** - Dokumentacja funkcji PDF

## Wsparcie

### Microsoft Docs

- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Node.js Developer Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-node)
- [Python Developer Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-python)

### Issues

W razie problemów:
1. Sprawdź logi w Application Insights
2. Przeczytaj SETUP_GUIDE.md
3. Sprawdź dokumentację funkcji
4. Otwórz issue na GitHub

## Wersje

- **markdown-to-html:** 1.0.0
- **merge-pdfs:** 1.0.0
- **Ostatnia aktualizacja:** 2024-10-27

## Licencja

Część projektu School Opinions WSR.
Dependencies używają licencji MIT/BSD - zobacz package.json i requirements.txt.
