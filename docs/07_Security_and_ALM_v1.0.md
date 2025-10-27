# 07 – Security & ALM (v1.0)

## Role bezpieczeństwa w Dataverse

- **Admin (System Administrator)** – pełny dostęp do aplikacji, zarządzanie użytkownikami i środowiskiem.
- **Nauczyciel (Teacher Role)** – przeglądanie danych uczniów, przypisywanie ocen i komentarzy.
- **Uczeń (Student Role)** – przegląd własnych opinii i raportów.

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

## ALM – Pipelines

- **Środowiska**: Dev → Test → Prod
- **Deployment**: Power Platform Pipelines z przypiętymi connection references i zmiennymi środowiskowymi
- **Export/Import**: rozwiązania zarządzane (managed), eksport z Dev jako unmanaged

