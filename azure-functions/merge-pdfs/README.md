# Merge PDFs Function

Azure Function do łączenia wielu PDF-ów i generowania strony tytułowej.

## Opis

Funkcja przyjmuje wiele PDF-ów w formacie base64 i:
- Łączy je w jeden dokument
- Opcjonalnie dodaje stronę tytułową z informacjami o uczniu
- Zwraca wynikowy PDF jako base64
- Podaje statystyki (liczba stron, rozmiar)

## Wymagania

- Python 3.11
- Azure Functions Runtime v4

## Instalacja lokalnie

```bash
# Zainstaluj dependencies
pip install -r requirements.txt

# Lub z użyciem virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# lub
.venv\Scripts\activate     # Windows

pip install -r requirements.txt

# Uruchom lokalnie
func start
```

## Testowanie lokalnie

### Test 1: Tylko strona tytułowa (bez PDF-ów)

```bash
curl -X POST http://localhost:7071/api/merge-pdfs \
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

### Test 2: Z PDF-ami

```bash
# Najpierw zakoduj PDF do base64
base64 -i test.pdf -o test.b64

# Użyj w request
curl -X POST http://localhost:7071/api/merge-pdfs \
  -H "Content-Type: application/json" \
  -d '{
    "pdfs": ["'$(cat test.b64)'"],
    "options": {
      "addCoverPage": true,
      "coverPageInfo": {
        "studentName": "Jan Kowalski",
        "sectionName": "1A"
      }
    }
  }'
```

## API

### Request

**Method:** POST
**Endpoint:** `/api/merge-pdfs`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "pdfs": [
    "string (base64) - Pierwszy PDF",
    "string (base64) - Drugi PDF",
    "..."
  ],
  "options": {
    "addCoverPage": false,
    "coverPageInfo": {
      "studentName": "string - Imię i nazwisko ucznia",
      "sectionName": "string - Nazwa klasy (np. 1A)",
      "schoolYear": "string - Rok szkolny (np. 2024/2025)",
      "semester": "string - Semestr (np. Semestr 1)",
      "schoolName": "string - Nazwa szkoły"
    },
    "addPageNumbers": true
  }
}
```

### Response

**Success (200):**
```json
{
  "success": true,
  "pdfBase64": "string - Połączony PDF w base64",
  "stats": {
    "totalPages": "number - Całkowita liczba stron",
    "sourceDocuments": "number - Liczba źródłowych PDF-ów",
    "fileSizeBytes": "number - Rozmiar w bajtach"
  },
  "timestamp": "string - ISO 8601 timestamp"
}
```

**Error (400):**
```json
{
  "error": "string - Opis błędu",
  "message": "string - Szczegóły"
}
```

**Error (500):**
```json
{
  "error": "Failed to merge PDFs",
  "message": "string - Szczegóły błędu"
}
```

## Funkcje

### 1. Łączenie PDF-ów

Używa biblioteki `PyPDF2` do łączenia wielu PDF-ów w jeden dokument.

**Przykład:**
```python
# Input: 3 PDF-y (2 strony każdy)
# Output: 1 PDF (6 stron)
```

### 2. Generowanie strony tytułowej

Używa biblioteki `reportlab` do tworzenia profesjonalnej strony tytułowej.

**Elementy strony:**
- Tytuł: "Opinia Ucznia" (wyśrodkowany, bold, 24pt)
- Dane ucznia:
  - Uczeń: [Imię i nazwisko]
  - Klasa: [Klasa]
  - Rok szkolny: [Rok]
  - Semestr: [Semestr]
  - Szkoła: [Nazwa szkoły]
- Data wygenerowania (dół strony, 10pt)

**Układ:**
```
┌────────────────────────────────┐
│                                │
│      Opinia Ucznia             │  <- 24pt bold, wyśrodkowany
│                                │
│  Uczeń: Jan Kowalski          │
│  Klasa: 1A                     │
│  Rok szkolny: 2024/2025        │
│  Semestr: Semestr 1            │
│  Szkoła: SP nr 13              │
│                                │
│                                │
│  Wygenerowano: 2024-10-27      │  <- Dół strony
└────────────────────────────────┘
```

### 3. Numerowanie stron (opcjonalne)

**Uwaga:** W wersji 1.0 numerowanie stron nie jest jeszcze zaimplementowane.
Planowane w wersji 1.1.

## Użycie w Power Automate

### Scenario 1: Łączenie opinii z różnych przedmiotów

#### Krok 1: Pobierz wszystkie opinie dla ucznia

```
Action: List rows (Dataverse)
Table: Opinions
Filter: wsr_studentid eq '[student_id]' and wsr_status eq 3
```

#### Krok 2: Dla każdej opinii wygeneruj PDF

```
Action: Apply to each
Items: @{outputs('List_rows')?['value']}

Inside loop:
  Action: Create file (SharePoint or OneDrive)
  Site: [Your site]
  File Name: opinion_@{items('Apply_to_each')?['wsr_opinionid']}.pdf
  File Content: [Convert HTML to PDF - użyj Word template lub innej metody]

  Action: Get file content
  File: [File created above]

  Action: Append to array variable
  Variable: PDFArray
  Value: @{base64(body('Get_file_content'))}
```

#### Krok 3: Połącz wszystkie PDF-y

```
Action: HTTP
Method: POST
URI: https://YOUR_FUNCTION_APP.azurewebsites.net/api/merge-pdfs?code=YOUR_KEY

Body:
{
  "pdfs": @{variables('PDFArray')},
  "options": {
    "addCoverPage": true,
    "coverPageInfo": {
      "studentName": "@{triggerBody()?['studentName']}",
      "sectionName": "@{triggerBody()?['sectionName']}",
      "schoolYear": "@{triggerBody()?['schoolYear']}",
      "semester": "@{triggerBody()?['semester']}",
      "schoolName": "Szkoła Podstawowa nr 13"
    }
  }
}
```

#### Krok 4: Parse response i zapisz PDF

```
Action: Parse JSON
Content: @{body('HTTP')}
Schema: [Zobacz API Response schema powyżej]

Action: Create file (SharePoint)
Site: [Your site]
Folder: /OpinionPDFs/2024-2025/Semester1
File Name: @{triggerBody()?['studentName']}_opinia.pdf
File Content: @{base64ToBinary(body('Parse_JSON')?['pdfBase64'])}
```

### Scenario 2: Tylko strona tytułowa

```
Action: HTTP
Method: POST
URI: https://YOUR_FUNCTION_APP.azurewebsites.net/api/merge-pdfs?code=YOUR_KEY

Body:
{
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
}
```

## Deployment

### Przez VS Code

1. Zainstaluj rozszerzenie Azure Functions
2. Kliknij prawym na folder funkcji
3. Wybierz "Deploy to Function App..."
4. Wybierz swoją Function App (Python 3.11)

### Przez Azure CLI

```bash
# Z folderu merge-pdfs
func azure functionapp publish YOUR_FUNCTION_APP_NAME --build remote
```

**Ważne:** Użyj `--build remote`, aby dependencies zainstalowały się na Azure.

### Przez ZIP

```bash
# Spakuj pliki (bez .venv!)
zip -r function.zip function.json __init__.py requirements.txt host.json

# Upload
az webapp deployment source config-zip \
  --resource-group YOUR_RG \
  --name YOUR_FUNCTION_APP \
  --src function.zip
```

## Troubleshooting

### "ModuleNotFoundError: No module named 'PyPDF2'"

Dependencies nie zainstalowały się. Wymuszenie instalacji:

```bash
az functionapp config appsettings set \
  --name YOUR_FUNCTION_APP \
  --resource-group YOUR_RG \
  --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

# Restart function app
az functionapp restart \
  --name YOUR_FUNCTION_APP \
  --resource-group YOUR_RG
```

### "Function execution timeout"

PDF-y są zbyt duże lub jest ich za dużo. Zwiększ timeout:

**host.json:**
```json
{
  "functionTimeout": "00:10:00"
}
```

Lub przejdź na Premium Plan.

### "Memory limit exceeded"

Zbyt wiele dużych PDF-ów. Rozwiązania:
1. Przejdź na Premium Plan (więcej pamięci)
2. Zmniejsz rozdzielczość PDF-ów przed wysłaniem
3. Łącz PDF-y w mniejszych partiach

### Testowanie strony tytułowej

```python
# Test lokalnie w Pythonie
from __init__ import create_cover_page

cover_info = {
    "studentName": "Jan Kowalski",
    "sectionName": "1A",
    "schoolYear": "2024/2025",
    "semester": "Semestr 1",
    "schoolName": "SP nr 13"
}

pdf_buffer = create_cover_page(cover_info)

# Zapisz do pliku
with open("test_cover.pdf", "wb") as f:
    f.write(pdf_buffer.read())
```

## Limity

### Consumption Plan
- Max execution time: **10 minut** (konfigurowalny)
- Max memory: **1.5 GB**
- Max payload: **100 MB** (HTTP trigger)

### Zalecenia
- Pojedynczy PDF: max **10 MB**
- Liczba PDF-ów: max **20** za jednym razem
- Całkowity rozmiar: max **50 MB**

Dla większych operacji rozważ:
- Premium Plan (więcej zasobów)
- Durable Functions (długie operacje)
- Storage Queue (asynchroniczne przetwarzanie)

## Performance

- Średni czas wykonania: **500ms - 2s** (zależnie od liczby i rozmiaru PDF-ów)
- Generowanie strony tytułowej: **~100ms**
- Łączenie 5 PDF-ów (po 2MB): **~1.5s**

## Monitoring

Sprawdź logi w Application Insights:

```kusto
traces
| where cloud_RoleName contains "mergepdf"
| where message contains "PDF"
| order by timestamp desc
```

Metryki:

```kusto
requests
| where cloud_RoleName contains "mergepdf"
| summarize
    AvgDuration=avg(duration),
    P95Duration=percentile(duration, 95),
    Count=count()
  by bin(timestamp, 1h)
| render timechart
```

## Bezpieczeństwo

### Walidacja input

Funkcja sprawdza:
- Czy `pdfs` jest tablicą
- Czy base64 jest poprawny
- Czy PDF-y są prawidłowe (PyPDF2 validation)

### Limity rozmiaru

Maksymalny rozmiar payload: **100 MB** (Azure Functions limit)

Jeśli potrzebujesz większych plików:
1. Użyj Azure Blob Storage
2. Przekaż tylko URL do PDF-ów
3. Funkcja pobierze je z storage

## Roadmap

### v1.1
- [ ] Numerowanie stron
- [ ] Customizowalna strona tytułowa (kolory, logo)
- [ ] Kompresja wynikowego PDF
- [ ] Batch processing (więcej niż 20 PDF-ów)

### v1.2
- [ ] Watermarking
- [ ] Podpis cyfrowy
- [ ] OCR na zeskanowanych dokumentach
- [ ] Automatyczna optymalizacja rozmiaru

## Licencje

- `PyPDF2` - BSD License
- `reportlab` - BSD License
- `azure-functions` - MIT License

## Wersja

**1.0.0** - Initial release
