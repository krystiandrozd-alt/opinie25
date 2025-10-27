# Azure Functions - Quick Start Guide

⚡ **15 minut** od zera do działających Azure Functions!

---

## 📋 Czego potrzebujesz?

- [ ] Konto Azure (można założyć darmowe)
- [ ] Przeglądarka internetowa
- [ ] Pliki z tego repozytorium

**NIE POTRZEBUJESZ:**
- ❌ Instalacji żadnych programów
- ❌ Wiedzy o programowaniu
- ❌ Skomplikowanej konfiguracji

---

## 🚀 Krok 1: Utwórz Function Apps (5 min)

### 1.1 Zaloguj się do Azure

👉 Otwórz: https://portal.azure.com

### 1.2 Utwórz Resource Group

```
Wyszukaj: "Resource groups"
→ Kliknij: "+ Create"
→ Wypełnij:
   Resource group name: rg-school-opinions-prod
   Region: West Europe
→ Kliknij: "Review + create" → "Create"
```

### 1.3 Utwórz Function App #1 (Markdown)

```
Wyszukaj: "Function App"
→ Kliknij: "+ Create"
→ Wypełnij:

   [Basics]
   Function App name: func-schoolopinions-markdown-prod
   Runtime stack: Node.js
   Version: 18 LTS
   Region: West Europe
   Operating System: Linux

   [Storage]
   Zostaw domyślne

   [Monitoring]
   Enable Application Insights: Yes

→ Kliknij: "Review + create" → "Create"
→ Poczekaj ~2 minuty
```

### 1.4 Utwórz Function App #2 (PDF)

```
Powtórz proces, ale zmień:
   Function App name: func-schoolopinions-mergepdf-prod
   Runtime stack: Python
   Version: 3.11

   [Pozostałe ustawienia takie same]
```

✅ **Checkpoint:** Masz 2 Function Apps w Azure Portal

---

## 📦 Krok 2: Wdróż kod (5 min)

### 2.1 Przygotuj pliki

**Funkcja Markdown:**

1. Na swoim komputerze przejdź do folderu:
   ```
   azure-functions/markdown-to-html/
   ```

2. Zaznacz wszystkie pliki:
   - function.json
   - index.js
   - package.json
   - host.json

3. Spakuj do ZIP:
   - **Windows:** Prawy przycisk → Send to → Compressed folder
   - **Mac:** Zaznacz pliki → Prawy przycisk → Compress
   - **Linux:** `zip -r markdown.zip function.json index.js package.json host.json`

4. Nazwij: `markdown.zip`

**Funkcja PDF:**

Powtórz proces dla folderu `merge-pdfs/`:
- function.json
- __init__.py
- requirements.txt
- host.json

Nazwij: `mergepdf.zip`

### 2.2 Upload do Azure (Metoda A - Kudu)

**Dla Markdown Function:**

```
1. Azure Portal → Otwórz: func-schoolopinions-markdown-prod
2. Menu lewe → Development Tools → Advanced Tools
3. Kliknij: "Go →"
4. W nowym oknie: Tools → Zip Push Deploy
5. Przeciągnij plik markdown.zip do okna przeglądarki
6. Poczekaj na "Deployment successful"
```

**Dla PDF Function:**

```
Powtórz proces dla: func-schoolopinions-mergepdf-prod
Użyj pliku: mergepdf.zip
```

### 2.3 Instaluj dependencies (tylko dla Markdown)

```
1. Azure Portal → func-schoolopinions-markdown-prod
2. Menu lewe → Development Tools → Console
3. W konsoli wpisz:
   cd site/wwwroot
   npm install
4. Poczekaj ~1 minutę
```

*Dla Python dependencies instalują się automatycznie*

✅ **Checkpoint:** Kod wdrożony, dependencies zainstalowane

---

## 🔑 Krok 3: Pobierz klucze i URL (2 min)

### 3.1 Function Keys

**Markdown Function:**

```
Azure Portal → func-schoolopinions-markdown-prod
→ Menu lewe → Functions → markdown-to-html
→ Function Keys
→ Skopiuj wartość klucza "default"
```

Zapisz klucz jako: `MARKDOWN_KEY`

**PDF Function:**

```
Azure Portal → func-schoolopinions-mergepdf-prod
→ Menu lewe → Functions → merge-pdfs
→ Function Keys
→ Skopiuj wartość klucza "default"
```

Zapisz klucz jako: `PDF_KEY`

### 3.2 Function URLs

**Markdown URL:**
```
https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html
```

**PDF URL:**
```
https://func-schoolopinions-mergepdf-prod.azurewebsites.net/api/merge-pdfs
```

✅ **Checkpoint:** Masz 2 klucze i 2 URL-e

---

## ✅ Krok 4: Testuj funkcje (3 min)

### 4.1 Test Markdown Function

**Przez Azure Portal:**

```
1. Azure Portal → func-schoolopinions-markdown-prod
2. Functions → markdown-to-html
3. Kliknij: "Code + Test"
4. Kliknij: "Test/Run"
5. Method: POST
6. Body: wklej poniższy JSON
```

**Test JSON:**
```json
{
  "markdown": "## Test\n\nTo jest **test** funkcji.\n\n- Punkt 1\n- Punkt 2",
  "options": {}
}
```

**Kliknij:** Run

**Oczekiwany wynik:**
```json
{
  "success": true,
  "html": "<h2>Test</h2>\n<p>To jest <strong>test</strong> funkcji...</p>",
  "stats": {
    "characterCount": 52,
    "wordCount": 9
  }
}
```

✅ Jeśli widzisz podobny wynik - **DZIAŁA!**

### 4.2 Test PDF Function

```
1. Azure Portal → func-schoolopinions-mergepdf-prod
2. Functions → merge-pdfs
3. Code + Test → Test/Run
4. Method: POST
5. Body: wklej poniższy JSON
```

**Test JSON:**
```json
{
  "pdfs": [],
  "options": {
    "addCoverPage": true,
    "coverPageInfo": {
      "studentName": "Jan Kowalski",
      "sectionName": "1A",
      "schoolYear": "2024/2025",
      "semester": "Semestr 1"
    }
  }
}
```

**Kliknij:** Run

**Oczekiwany wynik:**
```json
{
  "success": true,
  "pdfBase64": "JVBERi0xLjQKJeLjz9...",
  "stats": {
    "totalPages": 1,
    "sourceDocuments": 0
  }
}
```

✅ Jeśli widzisz podobny wynik - **DZIAŁA!**

---

## 🔗 Krok 5: Skonfiguruj Power Platform (2 min)

### 5.1 Skonstruuj pełne URL-e z kluczami

**Markdown URL:**
```
https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html?code=[MARKDOWN_KEY]
```
Zastąp `[MARKDOWN_KEY]` swoim kluczem

**PDF URL:**
```
https://func-schoolopinions-mergepdf-prod.azurewebsites.net/api/merge-pdfs?code=[PDF_KEY]
```
Zastąp `[PDF_KEY]` swoim kluczem

### 5.2 Zaktualizuj Environment Variables

```
1. Otwórz: Power Apps (make.powerapps.com)
2. Solutions → School Opinions WSR
3. Environment Variables
4. Znajdź i zaktualizuj:

   AzureFunction_MarkdownToHTML_URL
   → Wklej: [Twój Markdown URL z kluczem]

   AzureFunction_MergePDFs_URL
   → Wklej: [Twój PDF URL z kluczem]

5. Kliknij: Save
```

### 5.3 Skonfiguruj CORS (opcjonalnie)

```
1. Azure Portal → func-schoolopinions-markdown-prod
2. API → CORS
3. Dodaj:
   https://flow.microsoft.com
   https://*.powerapps.com
4. Kliknij: Save

Powtórz dla: func-schoolopinions-mergepdf-prod
```

---

## 🎉 Gratulacje!

**Azure Functions są gotowe do użycia!**

### ✅ Co masz teraz:

- ✅ Funkcja Markdown→HTML działa
- ✅ Funkcja PDF Merge działa
- ✅ Environment Variables skonfigurowane
- ✅ Power Automate może korzystać z funkcji

### 📊 Następne kroki:

1. **Testuj w Power Automate:**
   - Otwórz flow: WSR_SubmitOpinion
   - Uruchom testowo
   - Sprawdź czy HTML jest generowane

2. **Monitoruj:**
   - Application Insights → sprawdzaj logi
   - Metrics → śledź użycie

3. **Optymalizuj:**
   - Zobacz koszty w Cost Management
   - Dostosuj timeout jeśli potrzeba

---

## 🆘 Problemy?

### "Function not found"

**Przyczyna:** Kod nie został wdrożony
**Rozwiązanie:**
- Sprawdź czy ZIP był poprawny
- Spróbuj ponownie upload

### "Host not running"

**Przyczyna:** Function App nie wystartował
**Rozwiązanie:**
1. Azure Portal → Function App → Restart
2. Poczekaj 1-2 minuty
3. Sprawdź ponownie

### "Module not found"

**Przyczyna:** Dependencies nie zainstalowane
**Rozwiązanie:**
- Markdown: Wykonaj `npm install` w Console
- PDF: Restart Function App

### "Unauthorized"

**Przyczyna:** Błędny function key
**Rozwiązanie:**
- Pobierz ponownie klucz z Azure Portal
- Upewnij się że URL zawiera `?code=[KEY]`

### "CORS error"

**Przyczyna:** CORS nie skonfigurowany
**Rozwiązanie:**
- Dodaj `https://flow.microsoft.com` w CORS
- Dodaj `https://*.powerapps.com` w CORS

---

## 💡 Wskazówki

### Koszty

**Consumption Plan (domyślny):**
- **1 milion wykonań FREE/miesiąc**
- Szkoła (10,000 opinii/rok): **~€0.05/miesiąc**
- Praktycznie darmowe! 🎉

### Bezpieczeństwo

- **Nie udostępniaj** function keys publicznie
- **Rotuj klucze** co 90 dni
- **Monitoruj** użycie w Application Insights

### Performance

- **Cold start:** Pierwsze wywołanie może trwać ~2-3s
- **Warm calls:** Następne wywołania ~50-100ms
- Dla lepszej wydajności: Premium Plan

---

## 📚 Dalsze czytanie

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Szczegółowy przewodnik z alternatywnymi metodami
- **[README.md](README.md)** - Przegląd funkcji i API
- **[markdown-to-html/README.md](markdown-to-html/README.md)** - Dokumentacja funkcji Markdown
- **[merge-pdfs/README.md](merge-pdfs/README.md)** - Dokumentacja funkcji PDF

---

## ✉️ Wsparcie

Pytania? Problemy?

- **Email:** support@yourschool.edu.pl
- **Dokumentacja:** [Azure Functions Docs](https://docs.microsoft.com/azure/azure-functions/)
- **GitHub Issues:** [Link do repo]

---

**Wersja:** 1.0.0
**Ostatnia aktualizacja:** 2024-10-27

**Powodzenia! 🚀**
