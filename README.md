# School Opinions App v1.0

Aplikacja do zarządzania opiniami uczniów zbudowana na platformie Microsoft Power Platform.

## Opis

School Opinions App to kompleksowe rozwiązanie umożliwiające:
- Zarządzanie danymi uczniów
- Przypisywanie ocen i komentarzy przez nauczycieli
- Przeglądanie własnych opinii i raportów przez uczniów
- Automatyczne generowanie raportów w formacie Word
- Wysyłanie powiadomień e-mail

## Komponenty

Aplikacja wykorzystuje następujące komponenty Microsoft Power Platform:
- **Power Apps** - interfejs użytkownika
- **Dataverse** - baza danych
- **Power Automate** - automatyzacja procesów
- **Office 365** - integracja z pocztą i dokumentami

## Dokumentacja

- [Setup Guide](./docs/08_Setup_Guide_v1.0.md) - Instrukcja instalacji i konfiguracji
- [Security & ALM](./docs/07_Security_and_ALM_v1.0.md) - Zarządzanie bezpieczeństwem i wdrożeniami
- [CHANGELOG](./CHANGELOG.txt) - Historia zmian

## Wymagania

- Środowisko Microsoft Power Platform
- Licencje Power Apps i Power Automate
- Konto Office 365
- OneDrive for Business lub SharePoint

## Role użytkowników

### Admin (System Administrator)
- Pełny dostęp do aplikacji
- Zarządzanie użytkownikami i środowiskiem

### Nauczyciel (Teacher Role)
- Przeglądanie danych uczniów
- Przypisywanie ocen i komentarzy

### Uczeń (Student Role)
- Przegląd własnych opinii i raportów

## Instalacja

### 1. Import danych CSV → Dataflows

1. Otwórz Power Apps → Data → Dataflows → New dataflow → Import from CSV
2. Załaduj każdy z plików z folderu `StarterPack/data/`
3. Przypisz do odpowiednich tabel Dataverse

### 2. Importowanie przepływów Power Automate

1. Otwórz Power Automate → My Flows → Import
2. Wybierz odpowiedni plik `.flow.json` z folderu `StarterPack/flows/`
3. Podczas importu:
   - Wybierz poprawne **connection references**
   - Ustaw odpowiednie **environment variables**

### 3. Publikacja szablonu Word

1. Przejdź do OneDrive lub SharePoint
2. Umieść plik `StudentReport_Template.docx` z folderu `StarterPack/docs/`
3. Skopiuj link bezpośredni do pliku i przypisz go do zmiennej środowiskowej `ReportTemplate_FileUrl`

## Connection References

| Nazwa referencji           | Typ konektora       | Używane w flowach                    |
|---------------------------|----------------------|--------------------------------------|
| shared_office365          | Office 365 Outlook   | Send_Mail.flow.json                  |
| shared_dataverse          | Dataverse            | Wszystkie flowy: CRUD danych         |
| shared_onedriveforbusiness| OneDrive for Business| Generate_Opinions, Publish_and_Reports |

## Environment Variables

| Nazwa zmiennej             | Przeznaczenie                            |
|----------------------------|-------------------------------------------|
| ReportTemplate_FileUrl     | Ścieżka do szablonu raportu              |
| SchoolName                 | Nazwa szkoły używana w nagłówkach        |

## ALM – Application Lifecycle Management

### Środowiska
- **Dev** - Środowisko deweloperskie
- **Test** - Środowisko testowe
- **Prod** - Środowisko produkcyjne

### Deployment
- Power Platform Pipelines z przypiętymi connection references i zmiennymi środowiskowymi
- Export/Import: rozwiązania zarządzane (managed), eksport z Dev jako unmanaged

## Wersja

**v1.0** - Pierwsza wersja aplikacji

## Wsparcie

W razie pytań lub problemów skontaktuj się z zespołem rozwoju.

## Licencja

Wymagane licencje Microsoft Power Platform.
