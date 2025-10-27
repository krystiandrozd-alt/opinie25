# 08 – Setup Guide (v1.0)

## 1. Import danych CSV → Dataflows

1. Otwórz Power Apps → Data → Dataflows → New dataflow → Import from CSV
2. Załaduj każdy z plików z folderu `StarterPack/data/`
3. Przypisz do odpowiednich tabel Dataverse

## 2. Importowanie przepływów Power Automate

1. Otwórz Power Automate → My Flows → Import
2. Wybierz odpowiedni plik `.flow.json` z folderu `StarterPack/flows/`
3. Podczas importu:
   - Wybierz poprawne **connection references**
   - Ustaw odpowiednie **environment variables**

## 3. Publikacja szablonu Word

1. Przejdź do OneDrive lub SharePoint
2. Umieść plik `StudentReport_Template.docx` z folderu `StarterPack/docs/`
3. Skopiuj link bezpośredni do pliku i przypisz go do zmiennej środowiskowej `ReportTemplate_FileUrl`
