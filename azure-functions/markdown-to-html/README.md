# Markdown to HTML Function

Azure Function do konwersji Markdown na HTML z sanityzacją.

## Opis

Funkcja przyjmuje tekst w formacie Markdown i konwertuje go na bezpieczny HTML:
- Używa biblioteki `marked` do parsowania Markdown
- Używa `DOMPurify` do sanityzacji HTML (zabezpieczenie przed XSS)
- Zwraca statystyki (liczba słów, znaków)

## Wymagania

- Node.js 18 LTS
- Azure Functions Runtime v4

## Instalacja lokalnie

```bash
# Zainstaluj dependencies
npm install

# Uruchom lokalnie
func start
```

## Testowanie lokalnie

```bash
# Wyślij test request
curl -X POST http://localhost:7071/api/markdown-to-html \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "## Nagłówek\n\nTo jest **pogrubiony** tekst.\n\n- Lista\n- Elementów",
    "options": {}
  }'
```

Oczekiwana odpowiedź:

```json
{
  "success": true,
  "html": "<h2>Nagłówek</h2>\n<p>To jest <strong>pogrubiony</strong> tekst.</p>\n<ul>\n<li>Lista</li>\n<li>Elementów</li>\n</ul>\n",
  "stats": {
    "characterCount": 58,
    "wordCount": 8,
    "htmlLength": 125
  },
  "timestamp": "2024-10-27T12:34:56.789Z"
}
```

## API

### Request

**Method:** POST
**Endpoint:** `/api/markdown-to-html`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "markdown": "string (required) - Tekst w formacie Markdown",
  "options": {
    "markedOptions": {
      "gfm": true,           // GitHub Flavored Markdown
      "breaks": true,        // Konwertuj \n na <br>
      "smartLists": true,    // Inteligentne listy
      "smartypants": false   // Typograficzne znaki
    }
  }
}
```

### Response

**Success (200):**
```json
{
  "success": true,
  "html": "string - HTML output",
  "stats": {
    "characterCount": "number - Liczba znaków w Markdown",
    "wordCount": "number - Liczba słów",
    "htmlLength": "number - Długość HTML"
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
  "error": "Failed to convert markdown to HTML",
  "message": "string - Szczegóły błędu"
}
```

## Zabezpieczenia

### Sanityzacja HTML

Funkcja używa DOMPurify do usuwania niebezpiecznych elementów:

**Dozwolone tagi:**
- Nagłówki: h1, h2, h3, h4, h5, h6
- Tekst: p, br, hr, strong, em, u, s, mark
- Listy: ul, ol, li
- Kod: blockquote, pre, code
- Tabele: table, thead, tbody, tr, th, td
- Media: a, img

**Dozwolone atrybuty:**
- href, src, alt, title, class

**Blokowane:**
- <script> tagi
- <iframe> tagi
- Event handlers (onclick, onerror, etc.)
- javascript: URLs

### Przykłady

**Input:**
```markdown
<script>alert('XSS')</script>
## Bezpieczny nagłówek
```

**Output:**
```html
<h2>Bezpieczny nagłówek</h2>
```

Script tag zostanie usunięty.

## Użycie w Power Automate

### Krok 1: Dodaj akcję HTTP

```
Action: HTTP
Method: POST
URI: https://YOUR_FUNCTION_APP.azurewebsites.net/api/markdown-to-html?code=YOUR_KEY

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

### Krok 2: Parse JSON response

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
    },
    "timestamp": { "type": "string" }
  }
}
```

### Krok 3: Użyj HTML

```
Action: Update a row (Dataverse)
Opinion HTML: @{body('Parse_JSON')?['html']}
Word Count: @{body('Parse_JSON')?['stats']?['wordCount']}
```

## Deployment

### Przez VS Code

1. Zainstaluj rozszerzenie Azure Functions
2. Kliknij prawym na folder funkcji
3. Wybierz "Deploy to Function App..."
4. Wybierz swoją Function App

### Przez Azure CLI

```bash
# Z folderu markdown-to-html
npm install
func azure functionapp publish YOUR_FUNCTION_APP_NAME
```

### Przez ZIP

```bash
# Spakuj pliki
zip -r function.zip function.json index.js package.json host.json

# Upload
az webapp deployment source config-zip \
  --resource-group YOUR_RG \
  --name YOUR_FUNCTION_APP \
  --src function.zip
```

## Troubleshooting

### "Module not found: marked"

```bash
# Zaloguj się do Kudu console
# https://YOUR_FUNCTION_APP.scm.azurewebsites.net

# W konsoli:
cd site/wwwroot
npm install
```

### "Function execution timeout"

Zwiększ timeout w `host.json`:
```json
{
  "functionTimeout": "00:05:00"
}
```

### Testowanie sanityzacji

```bash
curl -X POST http://localhost:7071/api/markdown-to-html \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "<script>alert(\"XSS\")</script>\n## Normalny tekst\n<img src=x onerror=alert(1)>"
  }'
```

Output powinien zawierać tylko czysty HTML bez scriptów.

## Performance

- Średni czas wykonania: **50-100ms**
- Maksymalna wielkość input: **1MB** (można zwiększyć w host.json)
- Throughput: **~100 requests/second** (Consumption plan)

## Monitoring

Sprawdź logi w Application Insights:

```kusto
traces
| where cloud_RoleName contains "markdown"
| where message contains "Markdown to HTML conversion"
| order by timestamp desc
```

## Licencje

- `marked` - MIT License
- `isomorphic-dompurify` - MPL-2.0 / Apache-2.0

## Wersja

**1.0.0** - Initial release
