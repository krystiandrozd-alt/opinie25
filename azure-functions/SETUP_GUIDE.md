# Azure Functions - Przewodnik Konfiguracji

Kompleksowy przewodnik konfiguracji Azure Functions dla systemu School Opinions WSR.

## Spis treści

1. [Wymagania wstępne](#wymagania-wstępne)
2. [Tworzenie Function Apps w Azure Portal](#tworzenie-function-apps-w-azure-portal)
3. [Metoda 1: Deployment przez Azure Portal (najprostsza)](#metoda-1-deployment-przez-azure-portal-najprostsza)
4. [Metoda 2: Deployment przez VS Code (zalecana)](#metoda-2-deployment-przez-vs-code-zalecana)
5. [Metoda 3: Deployment przez Azure CLI](#metoda-3-deployment-przez-azure-cli)
6. [Konfiguracja po deployment](#konfiguracja-po-deployment)
7. [Testowanie funkcji](#testowanie-funkcji)
8. [Integracja z Power Automate](#integracja-z-power-automate)
9. [Monitoring i troubleshooting](#monitoring-i-troubleshooting)

---

## Wymagania wstępne

### 1. Konto Azure

- Aktywna subskrypcja Azure
- Uprawnienia do tworzenia zasobów
- Dostęp do Azure Portal: https://portal.azure.com

### 2. Narzędzia (wybierz jedną metodę)

**Opcja A: Azure Portal** (najprostsza, bez instalacji)
- Tylko przeglądarka internetowa

**Opcja B: VS Code** (zalecana dla deweloperów)
- Visual Studio Code: https://code.visualstudio.com/
- Rozszerzenie Azure Functions dla VS Code
- Node.js 18 LTS: https://nodejs.org/
- Python 3.11: https://www.python.org/

**Opcja C: Azure CLI** (dla zaawansowanych)
- Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli
- Azure Functions Core Tools: https://docs.microsoft.com/azure/azure-functions/functions-run-local

---

## Tworzenie Function Apps w Azure Portal

### Krok 1: Utworzenie Resource Group

1. Zaloguj się do **Azure Portal**: https://portal.azure.com
2. Wyszukaj **Resource groups**
3. Kliknij **+ Create**
4. Wypełnij:
   - **Subscription**: Twoja subskrypcja
   - **Resource group**: `rg-school-opinions-prod`
   - **Region**: `West Europe` (lub najbliższy region)
5. Kliknij **Review + create** → **Create**

### Krok 2: Utworzenie Function App dla Markdown→HTML

1. W Azure Portal wyszukaj **Function App**
2. Kliknij **+ Create**
3. Wypełnij zakładkę **Basics**:

   ```
   Subscription: [Twoja subskrypcja]
   Resource Group: rg-school-opinions-prod
   Function App name: func-schoolopinions-markdown-prod

   Publish: Code
   Runtime stack: Node.js
   Version: 18 LTS
   Region: West Europe

   Operating System: Linux
   Plan type: Consumption (Serverless)
   ```

4. Kliknij **Next: Storage**
5. Storage (zostaw domyślne lub utwórz nowe):
   ```
   Storage account: [auto-generated] lub utwórz nowe
   ```

6. Kliknij **Next: Networking**
   - Zostaw domyślne ustawienia (Enable public access)

7. Kliknij **Next: Monitoring**
   ```
   Enable Application Insights: Yes
   Application Insights: [Create new] lub wybierz istniejące
   ```

8. Kliknij **Review + create** → **Create**

9. Poczekaj na zakończenie deployment (~2-3 minuty)

### Krok 3: Utworzenie Function App dla Merge PDFs

Powtórz proces, ale z następującymi ustawieniami:

```
Function App name: func-schoolopinions-mergepdf-prod
Runtime stack: Python
Version: 3.11
[Pozostałe ustawienia takie same]
```

---

## Metoda 1: Deployment przez Azure Portal (najprostsza)

### A. Deployment Markdown→HTML Function

#### Krok 1: Przygotowanie kodu

1. Na swoim komputerze utwórz folder: `markdown-function`
2. Skopiuj pliki z repozytorium:
   ```
   markdown-function/
   ├── function.json
   ├── index.js
   ├── package.json
   └── host.json
   ```

3. Spakuj wszystkie pliki do ZIP:
   - Windows: Zaznacz wszystkie pliki → Prawy przycisk → Send to → Compressed folder
   - Mac/Linux: `zip -r markdown-function.zip function.json index.js package.json host.json`

   **WAŻNE**: ZIP powinien zawierać pliki bezpośrednio, NIE folder!

#### Krok 2: Upload do Azure

1. Otwórz Function App: `func-schoolopinions-markdown-prod`
2. W menu lewym wybierz **Deployment Center**
3. W **Source** wybierz **Local Git** lub **ZIP Deploy**

**Opcja A: ZIP Deploy (łatwiejsza)**

1. Otwórz Cloud Shell w Azure Portal (ikona `>_` na górze)
2. Wybierz **Bash**
3. Upload pliku ZIP:
   ```bash
   # Upload ZIP
   az webapp deployment source config-zip \
     --resource-group rg-school-opinions-prod \
     --name func-schoolopinions-markdown-prod \
     --src ./markdown-function.zip
   ```

**Opcja B: Przez Advanced Tools (Kudu)**

1. W Function App przejdź do **Advanced Tools** → **Go**
2. W Kudu console wybierz **Tools** → **Zip Push Deploy**
3. Przeciągnij plik ZIP do okna przeglądarki
4. Poczekaj na zakończenie upload

#### Krok 3: Instalacja dependencies

1. W Azure Portal otwórz Function App
2. Przejdź do **Console** (w Development Tools)
3. Wykonaj:
   ```bash
   cd site/wwwroot
   npm install
   ```

### B. Deployment Merge PDFs Function

Powtórz proces dla funkcji Python:

1. Spakuj pliki z folderu `merge-pdfs/`:
   ```
   merge-pdfs/
   ├── function.json
   ├── __init__.py
   ├── requirements.txt
   └── host.json
   ```

2. Upload ZIP do `func-schoolopinions-mergepdf-prod`

3. Dependencies zainstalują się automatycznie podczas pierwszego uruchomienia

---

## Metoda 2: Deployment przez VS Code (zalecana)

### Krok 1: Instalacja rozszerzeń VS Code

1. Otwórz VS Code
2. Zainstaluj rozszerzenia:
   - **Azure Functions**
   - **Azure Account**
   - **Azure Resources**

### Krok 2: Logowanie do Azure

1. W VS Code naciśnij `Ctrl+Shift+P` (Windows) lub `Cmd+Shift+P` (Mac)
2. Wpisz: `Azure: Sign In`
3. Zaloguj się do swojego konta Azure

### Krok 3: Deployment Markdown→HTML Function

1. Otwórz folder `azure-functions/markdown-to-html` w VS Code
2. Naciśnij `Ctrl+Shift+P`
3. Wpisz: `Azure Functions: Deploy to Function App...`
4. Wybierz:
   - Subscription: [Twoja subskrypcja]
   - Function App: `func-schoolopinions-markdown-prod`
5. Potwierdź deployment
6. Poczekaj na zakończenie (~2-3 minuty)

### Krok 4: Deployment Merge PDFs Function

Powtórz proces dla folderu `azure-functions/merge-pdfs`

### Krok 5: Weryfikacja

1. W VS Code otwórz panel **Azure** (ikona Azure po lewej)
2. Rozwiń:
   - **Resources** → **Function App** → `func-schoolopinions-markdown-prod`
3. Powinieneś zobaczyć funkcję: `markdown-to-html`

---

## Metoda 3: Deployment przez Azure CLI

### Krok 1: Logowanie

```bash
# Zaloguj się do Azure
az login

# Ustaw domyślną subskrypcję
az account set --subscription "Twoja-Subskrypcja"
```

### Krok 2: Deployment Markdown→HTML

```bash
# Przejdź do folderu funkcji
cd azure-functions/markdown-to-html

# Zainstaluj dependencies lokalnie
npm install

# Deploy funkcji
func azure functionapp publish func-schoolopinions-markdown-prod

# Pobierz URL i klucze
func azure functionapp list-functions func-schoolopinions-markdown-prod --show-keys
```

### Krok 3: Deployment Merge PDFs

```bash
# Przejdź do folderu funkcji
cd ../merge-pdfs

# Deploy funkcji (dependencies zainstalują się automatycznie)
func azure functionapp publish func-schoolopinions-mergepdf-prod --build remote

# Pobierz URL i klucze
func azure functionapp list-functions func-schoolopinions-mergepdf-prod --show-keys
```

---

## Konfiguracja po deployment

### Krok 1: Pobierz Function Keys (klucze dostępu)

#### Metoda A: Azure Portal

1. Otwórz Function App: `func-schoolopinions-markdown-prod`
2. Przejdź do **Functions** → wybierz funkcję `markdown-to-html`
3. Kliknij **Function Keys**
4. Skopiuj wartość klucza `default` lub `host`

#### Metoda B: Azure CLI

```bash
# Markdown to HTML
az functionapp keys list \
  --name func-schoolopinions-markdown-prod \
  --resource-group rg-school-opinions-prod

# Merge PDFs
az functionapp keys list \
  --name func-schoolopinions-mergepdf-prod \
  --resource-group rg-school-opinions-prod
```

### Krok 2: Pobierz Function URLs

Funkcje będą dostępne pod adresami:

**Markdown to HTML:**
```
https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html
```

**Merge PDFs:**
```
https://func-schoolopinions-mergepdf-prod.azurewebsites.net/api/merge-pdfs
```

### Krok 3: Skonfiguruj CORS (jeśli potrzebne)

1. W Function App przejdź do **CORS**
2. Dodaj dozwolone origins:
   ```
   https://flow.microsoft.com
   https://*.powerapps.com
   ```
3. Kliknij **Save**

### Krok 4: Zaktualizuj Environment Variables w Power Platform

1. Otwórz **Power Apps** → **Solutions** → **School Opinions WSR**
2. Przejdź do **Environment Variables**
3. Zaktualizuj:

   **AzureFunction_MarkdownToHTML_URL:**
   ```
   https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html?code=[TWÓJ_FUNCTION_KEY]
   ```

   **AzureFunction_MergePDFs_URL:**
   ```
   https://func-schoolopinions-mergepdf-prod.azurewebsites.net/api/merge-pdfs?code=[TWÓJ_FUNCTION_KEY]
   ```

   Zastąp `[TWÓJ_FUNCTION_KEY]` kluczem pobranym w Kroku 1.

---

## Testowanie funkcji

### Test 1: Markdown to HTML

#### Przez Azure Portal

1. Otwórz Function App → **Functions** → `markdown-to-html`
2. Kliknij **Code + Test**
3. Kliknij **Test/Run**
4. Wybierz **POST** method
5. W **Body** wklej:

```json
{
  "markdown": "## Ocena zachowania\n\nUczeń wykazuje **bardzo dobre** zachowanie.\n\n### Mocne strony\n\n- Aktywny udział w lekcjach\n- Sumienność w wykonywaniu zadań\n- Kultura osobista\n\n### Obszary do rozwoju\n\n- Większa pewność siebie podczas odpowiedzi",
  "options": {
    "markedOptions": {
      "gfm": true,
      "breaks": true
    }
  }
}
```

6. Kliknij **Run**
7. Sprawdź **Output** - powinien zawierać HTML:

```json
{
  "success": true,
  "html": "<h2>Ocena zachowania</h2>\n<p>Uczeń wykazuje <strong>bardzo dobre</strong> zachowanie...</p>",
  "stats": {
    "characterCount": 215,
    "wordCount": 28,
    "htmlLength": 340
  }
}
```

#### Przez Postman / cURL

```bash
curl -X POST \
  "https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html?code=YOUR_FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "## Test\n\nTo jest **test** funkcji.",
    "options": {}
  }'
```

### Test 2: Merge PDFs

```bash
curl -X POST \
  "https://func-schoolopinions-mergepdf-prod.azurewebsites.net/api/merge-pdfs?code=YOUR_FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "pdfs": [],
    "options": {
      "addCoverPage": true,
      "coverPageInfo": {
        "studentName": "Jan Kowalski",
        "sectionName": "1A",
        "schoolYear": "2024/2025",
        "semester": "Semestr 1",
        "schoolName": "Szkoła Podstawowa nr 13"
      }
    }
  }'
```

---

## Integracja z Power Automate

### Krok 1: Utwórz HTTP Connection w Power Automate

1. Otwórz **Power Automate** → **Data** → **Connections**
2. Kliknij **+ New connection**
3. Wyszukaj **HTTP**
4. Kliknij **Create**

### Krok 2: Użycie w Flow - Markdown to HTML

Dodaj akcję **HTTP** w swoim flow:

```
Action: HTTP
Method: POST
URI: [Environment Variable: AzureFunction_MarkdownToHTML_URL]

Headers:
{
  "Content-Type": "application/json"
}

Body:
{
  "markdown": "@{triggerBody()?['wsr_opinionmarkdown']}",
  "options": {
    "markedOptions": {
      "gfm": true,
      "breaks": true
    }
  }
}
```

Następnie sparsuj odpowiedź:

```
Action: Parse JSON
Content: @{body('HTTP')}
Schema:
{
  "type": "object",
  "properties": {
    "success": { "type": "boolean" },
    "html": { "type": "string" },
    "stats": {
      "type": "object",
      "properties": {
        "characterCount": { "type": "integer" },
        "wordCount": { "type": "integer" },
        "htmlLength": { "type": "integer" }
      }
    }
  }
}
```

Użyj HTML:

```
Action: Update a row (Dataverse)
Table: Opinions
Row ID: [opinion_id]
Opinion HTML: @{body('Parse_JSON')?['html']}
Word Count: @{body('Parse_JSON')?['stats']?['wordCount']}
Character Count: @{body('Parse_JSON')?['stats']?['characterCount']}
```

### Krok 3: Użycie w Flow - Merge PDFs

```
Action: HTTP
Method: POST
URI: [Environment Variable: AzureFunction_MergePDFs_URL]

Body:
{
  "pdfs": [@{variables('PDFArray')}],
  "options": {
    "addCoverPage": true,
    "coverPageInfo": {
      "studentName": "@{items('For_each_student')?['wsr_name']}",
      "sectionName": "@{items('For_each_student')?['wsr_sectionid@OData.Community.Display.V1.FormattedValue']}",
      "schoolYear": "@{triggerBody()?['wsr_schoolyear']}",
      "semester": "Semestr @{triggerBody()?['wsr_semester']}",
      "schoolName": "Szkoła Podstawowa nr 13"
    }
  }
}
```

---

## Monitoring i troubleshooting

### Application Insights

1. Otwórz Function App
2. Przejdź do **Application Insights**
3. Kliknij **View Application Insights data**

#### Sprawdzanie logów

1. W Application Insights przejdź do **Logs**
2. Wykonaj query:

```kusto
traces
| where timestamp > ago(1h)
| where cloud_RoleName contains "markdown"
| order by timestamp desc
| take 50
```

#### Metryki

1. Przejdź do **Metrics**
2. Dodaj metryki:
   - **Function Execution Count** - liczba wykonań
   - **Function Execution Duration** - czas wykonania
   - **HTTP 5xx errors** - błędy serwera

### Diagnozowanie błędów

#### Error: "Host is not running"

**Przyczyna**: Function App nie uruchomił się
**Rozwiązanie**:
1. Sprawdź **Platform features** → **Configuration**
2. Upewnij się, że runtime stack jest poprawny
3. Restart Function App

#### Error: "Module not found"

**Przyczyna**: Dependencies nie zainstalowały się
**Rozwiązanie**:
```bash
# Dla Node.js
cd site/wwwroot
npm install

# Dla Python
# Dependencies instalują się automatycznie, ale możesz wymusić:
az functionapp config appsettings set \
  --name func-schoolopinions-mergepdf-prod \
  --resource-group rg-school-opinions-prod \
  --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

#### Error: "Request timeout"

**Przyczyna**: Funkcja wykonuje się zbyt długo
**Rozwiązanie**:
1. Zmień plan z Consumption na Premium
2. Lub zwiększ timeout:
   ```json
   // host.json
   {
     "functionTimeout": "00:10:00"
   }
   ```

#### Error: "CORS policy"

**Przyczyna**: CORS nie jest skonfigurowany
**Rozwiązanie**:
1. Function App → **CORS**
2. Dodaj: `https://flow.microsoft.com`

---

## Koszty i skalowanie

### Consumption Plan (domyślny)

**Zalety:**
- Płacisz tylko za wykonania
- Automatyczne skalowanie
- 1 milion wykonań free/miesiąc

**Koszty:**
- €0.169 za milion wykonań
- €0.000014 za GB-s pamięci

**Przykład:**
- 10,000 wykonań/miesiąc
- Średnio 500ms każde
- **~€0.02/miesiąc** (praktycznie darmowe!)

### Premium Plan (dla dużych obciążeń)

Jeśli masz:
- Więcej niż 100,000 wykonań/miesiąc
- Potrzebujesz stałego czasu odpowiedzi
- Wymagasz VNET integration

**Koszty:**
- EP1: ~€120/miesiąc
- EP2: ~€240/miesiąc

---

## Checklist - podsumowanie

- [ ] Utworzono Resource Group
- [ ] Utworzono 2 Function Apps (Markdown, PDF)
- [ ] Wdrożono kod funkcji (jedna z 3 metod)
- [ ] Pobrano Function Keys
- [ ] Pobrano Function URLs
- [ ] Skonfigurowano CORS
- [ ] Zaktualizowano Environment Variables w Power Platform
- [ ] Przetestowano funkcję Markdown→HTML
- [ ] Przetestowano funkcję Merge PDFs
- [ ] Zintegrowano z Power Automate flows
- [ ] Skonfigurowano Application Insights
- [ ] Przetestowano end-to-end workflow

---

## Wsparcie

### Dokumentacja Microsoft

- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Functions - Node.js Developer Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-node)
- [Azure Functions - Python Developer Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-python)

### Troubleshooting

W razie problemów sprawdź:
1. Logi w Application Insights
2. Kudu console: `https://[function-app-name].scm.azurewebsites.net`
3. Function execution logs w Azure Portal

### Kontakt

- **Email**: support@yourschool.edu.pl
- **GitHub Issues**: [Link do repo]

---

**Wersja:** 1.0.0
**Ostatnia aktualizacja:** 2024-10-27
