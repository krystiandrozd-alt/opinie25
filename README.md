# School Opinions WSR - Power Platform Repository

[![Power Platform](https://img.shields.io/badge/Power%20Platform-742774?style=flat&logo=microsoft&logoColor=white)](https://powerplatform.microsoft.com/)
[![Dataverse](https://img.shields.io/badge/Dataverse-0078D4?style=flat&logo=microsoft&logoColor=white)](https://powerplatform.microsoft.com/dataverse/)
[![Azure Functions](https://img.shields.io/badge/Azure%20Functions-0062AD?style=flat&logo=azure-functions&logoColor=white)](https://azure.microsoft.com/services/functions/)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.txt)

Kompletne repozytorium systemu do zarządzania opiniami uczniów (WSR) zbudowanego na Microsoft Power Platform. System automatyzuje proces tworzenia, zatwierdzania i dystrybucji opinii szkolnych.

## Spis treści

- [Opis systemu](#opis-systemu)
- [Architektura](#architektura)
- [Struktura repozytorium](#struktura-repozytorium)
- [Wymagania](#wymagania)
- [Instalacja](#instalacja)
- [Konfiguracja](#konfiguracja)
- [Role użytkowników](#role-użytkowników)
- [Dokumentacja](#dokumentacja)

---

## Opis systemu

**School Opinions WSR** to kompletne rozwiązanie dla szkół podstawowych umożliwiające:

- **Import danych** z School Data Sync (SDS) - automatyczne pobieranie danych o szkołach, nauczycielach, uczniach i klasach
- **Zarządzanie cyklami opinii** - tworzenie cykli semestralnych z automatycznym generowaniem szkiców opinii
- **Pisanie opinii** - nauczyciele przedmiotowi tworzą opinie w formacie Markdown z automatyczną konwersją do HTML
- **Workflow zatwierdzania** - wychowawcy przeglądają, zatwierdzają lub proszą o poprawki
- **Agregacja opinii** - automatyczne łączenie wszystkich opinii przedmiotowych dla ucznia
- **Generowanie PDF** - tworzenie profesjonalnych dokumentów PDF z opiniami
- **Dystrybucja email** - automatyczne wysyłanie opinii do rodziców
- **Raportowanie** - dashboardy Power BI z metrykami i KPI

### Kluczowe funkcje

- ✅ Pełna automatyzacja workflow opinii
- ✅ Integracja z School Data Sync (SDS)
- ✅ 14 przepływów Power Automate
- ✅ 2 funkcje Azure (Markdown→HTML, łączenie PDF)
- ✅ Aplikacja Model-Driven w Power Apps
- ✅ Dashboardy Power BI z metrykami
- ✅ 3 role bezpieczeństwa (nauczyciel, wychowawca, dyrektor)
- ✅ Wsparcie dla formatowania Markdown
- ✅ Automatyczne powiadomienia email

---

## Architektura

```
┌─────────────────────────────────────────────────────────────────┐
│                       Power Platform Environment                 │
│                                                                   │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│  │  Power Apps  │◄────►│  Dataverse   │◄────►│Power Automate│  │
│  │ (Model App)  │      │  (9 Tables)  │      │  (14 Flows)  │  │
│  └──────────────┘      └──────────────┘      └───────┬──────┘  │
│         │                      │                      │          │
└─────────┼──────────────────────┼──────────────────────┼──────────┘
          │                      │                      │
          │                      │                      ▼
          │                      │              ┌──────────────┐
          │                      │              │ SharePoint   │
          │                      │              │ - SDS Import │
          │                      │              │ - Opinion PDFs│
          │                      │              └──────────────┘
          │                      │
          │                      ▼
          │              ┌──────────────┐
          │              │Azure Functions│
          │              │- MD→HTML     │
          │              │- Merge PDFs  │
          │              └──────────────┘
          │
          ▼
  ┌──────────────┐
  │  Power BI    │
  │  Dashboards  │
  └──────────────┘
```

---

## Struktura repozytorium

```
school-opinions-wsr/
├── README.md                                    # Ten plik
├── CHANGELOG.txt                                # Historia zmian
├── .gitignore                                   # Git ignore rules
│
├── dataverse/                                   # Dataverse - baza danych
│   ├── solution/                                # Eksport rozwiązania (ZIP)
│   │   └── SchoolOpinionsWSR_1_0_0_0.zip
│   ├── table-definitions/                       # Definicje 9 tabel
│   │   ├── wsr_school.json                      # Szkoły
│   │   ├── wsr_section.json                     # Oddziały/klasy
│   │   ├── wsr_teacher.json                     # Nauczyciele
│   │   ├── wsr_student.json                     # Uczniowie
│   │   ├── wsr_studentenrollment.json           # Zapisywanie uczniów do oddziałów
│   │   ├── wsr_teacherroster.json               # Przypisanie nauczycieli do przedmiotów
│   │   ├── wsr_opinioncycle.json                # Cykle opinii (semestry)
│   │   ├── wsr_opinion.json                     # Pojedyncze opinie
│   │   └── wsr_studentopinionpackage.json       # Pakiety opinii dla ucznia
│   ├── security-roles/                          # Role bezpieczeństwa
│   │   ├── WSRTeacher.json                      # Nauczyciel przedmiotu
│   │   ├── WSRHomeroomTeacher.json              # Wychowawca klasy
│   │   └── WSRPrincipal.json                    # Dyrektor szkoły
│   └── sample-data/                             # Przykładowe dane
│       └── school_13001.json                    # Dane szkoły przykładowej
│
├── power-automate/                              # Power Automate - automatyzacja
│   ├── flows/                                   # Eksporty przepływów (ZIP)
│   │   ├── SDS_Import_School.zip
│   │   ├── SDS_Import_Teachers.zip
│   │   ├── SDS_Import_Sections.zip
│   │   ├── SDS_Import_Students.zip
│   │   ├── SDS_Import_StudentEnrollment.zip
│   │   ├── SDS_Import_TeacherRoster.zip
│   │   ├── WSR_CreateDraftOpinions.zip
│   │   ├── WSR_SubmitOpinion.zip
│   │   ├── WSR_ApproveOpinion.zip
│   │   ├── WSR_RejectOpinion.zip
│   │   ├── WSR_GenerateOpinionPDF.zip
│   │   ├── WSR_AggregateOpinions.zip
│   │   ├── WSR_SendOpinionPackage.zip
│   │   └── WSR_CloseCycle.zip
│   └── flow-definitions/                        # Dokumentacja przepływów
│       └── flows-metadata.json
│
├── azure-functions/                             # Azure Functions - przetwarzanie
│   ├── markdown-to-html/                        # Konwersja Markdown→HTML
│   │   ├── function.json
│   │   ├── index.js
│   │   ├── package.json
│   │   └── host.json
│   └── merge-pdfs/                              # Łączenie PDF-ów
│       ├── function.json
│       ├── __init__.py
│       ├── requirements.txt
│       └── host.json
│
├── power-apps/                                  # Power Apps - interfejs użytkownika
│   ├── SchoolOpinionsManager.msapp              # Aplikacja Model-Driven
│   └── app-metadata.json                        # Metadane aplikacji
│
├── power-bi/                                    # Power BI - raportowanie
│   ├── OpinionCycleKPIs.pbix                    # Raport z KPI
│   └── dataset-config.json                      # Konfiguracja datasetu
│
├── sharepoint/                                  # SharePoint - przechowywanie plików
│   ├── site-template.xml                        # Szablon strony
│   └── libraries/                               # Biblioteki dokumentów
│       ├── SDS_Import.json                      # Importy CSV z SDS
│       └── OpinionPDFs.json                     # Wygenerowane PDF-y
│
├── deployment/                                  # Skrypty wdrożeniowe
│   ├── deploy.ps1                               # Automatyczny deployment (PowerShell)
│   ├── deploy-config.json                       # Konfiguracja wdrożenia
│   └── post-deployment-steps.md                 # Instrukcje po wdrożeniu
│
└── docs/                                        # Dokumentacja
    ├── 07_Security_and_ALM_v1.0.md             # Bezpieczeństwo i ALM
    └── 08_Setup_Guide_v1.0.md                  # Instrukcja instalacji
```

---

## Wymagania

### Microsoft Power Platform

- **Licencje:**
  - Power Apps (per user lub per app)
  - Power Automate (per user lub per flow)
  - Office 365 E3/E5 (dla integracji email i SharePoint)
- **Środowisko Dataverse** z wystarczającą pojemnością bazy danych
- **SharePoint Online** - strona zespołowa z bibliotekami dokumentów

### Azure Services (opcjonalne, ale zalecane)

- **Azure Functions** - Consumption lub Premium plan
  - Node.js 18 LTS (dla markdown-to-html)
  - Python 3.11 (dla merge-pdfs)
- **Application Insights** - do monitorowania i logowania

### Narzędzia deweloperskie

- **Power Platform CLI** ([pobierz](https://aka.ms/PowerPlatformCLI))
- **Azure CLI** ([pobierz](https://docs.microsoft.com/cli/azure/install-azure-cli))
- **Git** - do klonowania repozytorium
- **VS Code** (zalecane) z rozszerzeniami:
  - Power Platform Tools
  - Azure Functions

### Integracja z School Data Sync

- Konfiguracja SDS w Microsoft 365 Admin Center
- Eksport CSV do SharePoint (automatyczny lub manualny)

---

## Instalacja

### Metoda 1: Automatyczne wdrożenie (zalecane)

```powershell
# 1. Sklonuj repozytorium
git clone https://github.com/yourorg/school-opinions-wsr.git
cd school-opinions-wsr

# 2. Edytuj konfigurację
notepad deployment/deploy-config.json
# Zaktualizuj: EnvironmentUrl, SharePoint URLs, Azure Function names

# 3. Uruchom skrypt wdrożeniowy
.\deployment\deploy.ps1 -EnvironmentUrl "https://yourorg.crm4.dynamics.com"

# 4. Wykonaj kroki post-deployment
# Zobacz: deployment/post-deployment-steps.md
```

### Metoda 2: Manualne wdrożenie

Szczegółowe kroki w: [`deployment/post-deployment-steps.md`](deployment/post-deployment-steps.md)

1. Import rozwiązania Dataverse
2. Tworzenie bibliotek SharePoint
3. Import przepływów Power Automate
4. Konfiguracja connection references
5. Deploy funkcji Azure
6. Przypisanie ról bezpieczeństwa
7. Import danych przykładowych (opcjonalnie)

---

## Konfiguracja

### Environment Variables (wymagane)

Po instalacji skonfiguruj następujące zmienne środowiskowe w Power Platform:

| Zmienna | Przykład | Opis |
|---------|----------|------|
| `SharePoint_SiteURL` | `https://contoso.sharepoint.com/sites/SchoolOpinions` | URL strony SharePoint |
| `SharePoint_SDSLibrary` | `SDS_Import` | Nazwa biblioteki dla plików SDS |
| `SharePoint_OpinionPDFsLibrary` | `OpinionPDFs` | Nazwa biblioteki dla PDF-ów |
| `AzureFunction_MarkdownToHTML_URL` | `https://func-md.azurewebsites.net/api/markdown-to-html` | URL funkcji konwersji |
| `AzureFunction_MergePDFs_URL` | `https://func-pdf.azurewebsites.net/api/merge-pdfs` | URL funkcji łączenia PDF |
| `Email_SenderAddress` | `noreply@school.edu.pl` | Adres nadawcy email |

### Connection References

Skonfiguruj połączenia dla przepływów Power Automate:

- **Dataverse** - połączenie do środowiska
- **Office 365 Outlook** - konto do wysyłki emaili
- **SharePoint** - połączenie do strony SharePoint
- **Azure Functions** - uwierzytelnienie z function keys

---

## Role użytkowników

System wykorzystuje 3 role bezpieczeństwa:

### 1. WSR Teacher (Nauczyciel przedmiotu)

**Uprawnienia:**
- ✅ Tworzenie i edycja własnych opinii
- ✅ Wysyłanie opinii do zatwierdzenia
- ✅ Przeglądanie danych uczniów z własnych zajęć
- ✅ Odpowiadanie na prośby o poprawki
- ❌ Nie może zatwierdzać opinii
- ❌ Nie ma dostępu do pakietów opinii

**Typowi użytkownicy:** Wszyscy nauczyciele przedmiotowi

### 2. WSR Homeroom Teacher (Wychowawca klasy)

**Uprawnienia:**
- ✅ Wszystkie uprawnienia nauczyciela przedmiotu
- ✅ Przeglądanie wszystkich opinii w swojej klasie
- ✅ Zatwierdzanie lub odrzucanie opinii
- ✅ Dodawanie komentarzy wychowawcy
- ✅ Generowanie pakietów opinii dla uczniów
- ✅ Wysyłanie pakietów do rodziców
- ❌ Nie ma dostępu do innych klas

**Typowi użytkownicy:** Wychowawcy klas

### 3. WSR Principal (Dyrektor)

**Uprawnienia:**
- ✅ Pełny dostęp do wszystkich danych
- ✅ Zarządzanie cyklami opinii
- ✅ Przeglądanie wszystkich opinii w szkole
- ✅ Dostęp do raportów Power BI
- ✅ Zarządzanie konfiguracją systemu

**Typowi użytkownicy:** Dyrektor szkoły, wicedyrektor

---

## Przepływy pracy

### Workflow opinii

```
1. DYREKTOR: Tworzy nowy cykl opinii (np. Semestr 1 2024/2025)
   └─► Status: OPEN

2. SYSTEM: Automatycznie tworzy szkice opinii dla wszystkich uczniów
   └─► Opinie w statusie: DRAFT

3. NAUCZYCIEL: Pisze opinie w formacie Markdown
   └─► Wypełnia pola: zachowanie, postępy, mocne strony, obszary rozwoju
   └─► Zapisuje jako DRAFT lub wysyła jako SUBMITTED

4. SYSTEM: Po wysłaniu (SUBMITTED)
   └─► Konwertuje Markdown → HTML (Azure Function)
   └─► Oblicza liczbę słów/znaków
   └─► Wysyła powiadomienie do wychowawcy

5. WYCHOWAWCA: Przegląda opinie
   └─► APPROVED: Zatwierdza opinię
   └─► REJECTED/REVISION REQUESTED: Prosi o poprawki

6. SYSTEM: Gdy wszystkie opinie ucznia zatwierdzone
   └─► Agreguje opinie w pakiet
   └─► Status pakietu: READY FOR REVIEW

7. WYCHOWAWCA: Dodaje komentarz końcowy
   └─► Generuje PDF (Azure Function)
   └─► Wysyła do rodziców
   └─► Status pakietu: SENT TO PARENTS

8. SYSTEM: Pakiet wysłany
   └─► Email z PDF do rodzica
   └─► PDF zapisany w SharePoint
```

### Import danych SDS

```
1. SDS eksportuje dane → pliki CSV w SharePoint (codziennie o 1:00)

2. Power Automate flows uruchamiają się (codziennie o 2:00-3:15):
   ├─► 2:00 - Import szkół
   ├─► 2:15 - Import nauczycieli
   ├─► 2:30 - Import oddziałów
   ├─► 2:45 - Import uczniów
   ├─► 3:00 - Import zapisów uczniów
   └─► 3:15 - Import przypisań nauczycieli

3. Dane aktualizowane w Dataverse (upsert)
   └─► Istniejące rekordy aktualizowane po SDS ID
   └─► Nowe rekordy dodawane
```

---

## Dokumentacja

### Dokumentacja techniczna

- [**Security & ALM**](docs/07_Security_and_ALM_v1.0.md) - Role bezpieczeństwa, connection references, zmienne środowiskowe, ALM
- [**Setup Guide**](docs/08_Setup_Guide_v1.0.md) - Instrukcja instalacji i konfiguracji
- [**Post-Deployment Steps**](deployment/post-deployment-steps.md) - Szczegółowe kroki po wdrożeniu

### Dokumentacja kodu

- **Dataverse Tables**: [`dataverse/table-definitions/`](dataverse/table-definitions/) - Schematy 9 tabel
- **Security Roles**: [`dataverse/security-roles/`](dataverse/security-roles/) - Definicje uprawnień
- **Power Automate Flows**: [`power-automate/flow-definitions/`](power-automate/flow-definitions/) - Metadane przepływów
- **Azure Functions**:
  - [`azure-functions/markdown-to-html/`](azure-functions/markdown-to-html/) - Konwersja Markdown→HTML
  - [`azure-functions/merge-pdfs/`](azure-functions/merge-pdfs/) - Łączenie PDF-ów

### Dashboardy i raporty

Power BI dashboardy zawierają metryki:

- **Submission Rate** - % wysłanych opinii
- **Approval Rate** - % zatwierdzonych opinii
- **Package Completion Rate** - % wysłanych pakietów do rodziców
- **Opinie wg oddziałów** - statystyki per klasa
- **Opinie wg nauczycieli** - statystyki per nauczyciel
- **Średnia długość opinii** - statystyki tekstowe

---

## Technologie

| Komponent | Technologia | Wersja |
|-----------|------------|--------|
| Power Platform | Dataverse | Latest |
| Power Apps | Model-Driven App | Latest |
| Power Automate | Cloud Flows | Latest |
| Azure Functions (MD→HTML) | Node.js | 18 LTS |
| Azure Functions (PDF) | Python | 3.11 |
| SharePoint | SharePoint Online | Latest |
| Power BI | Power BI Service | Latest |
| Deployment | PowerShell | 7.x |

---

## Roadmap

### v1.1 (Q1 2025)

- [ ] Wsparcie dla wielu szkół w jednym środowisku
- [ ] Integracja z Microsoft Teams (notyfikacje)
- [ ] Mobilna aplikacja Power Apps dla nauczycieli
- [ ] Szablony opinii per przedmiot

### v1.2 (Q2 2025)

- [ ] AI-powered sugestie opinii (Azure OpenAI)
- [ ] Automatyczna detekcja błędów ortograficznych
- [ ] Wsparcie dla wielu języków (EN, PL)
- [ ] Export do dziennika elektronicznego

### v2.0 (Q3 2025)

- [ ] Portal dla rodziców (Power Pages)
- [ ] Podpis cyfrowy opinii
- [ ] Integracja z systemem ocen
- [ ] Archiwum wieloletnie z zaawansowanym wyszukiwaniem

---

## Wsparcie

### Kontakt techniczny

- **Email**: support@yourschool.edu.pl
- **Teams**: [School IT Support Team]
- **GitHub Issues**: [github.com/yourorg/school-opinions-wsr/issues]

### Dokumentacja Microsoft

- [Power Platform Documentation](https://docs.microsoft.com/power-platform/)
- [Dataverse Documentation](https://docs.microsoft.com/power-apps/developer/data-platform/)
- [Power Automate Documentation](https://docs.microsoft.com/power-automate/)
- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)

---

## Licencja

Ten projekt jest własnością [Nazwa Szkoły/Organizacji]. Wymagane licencje Microsoft Power Platform.

### Wymagane licencje dla użytkowników

- **Nauczyciele**: Power Apps per user LUB Power Apps per app
- **Wychowawcy**: Power Apps per user (zalecane)
- **Dyrektor**: Power Apps per user + Power BI Pro
- **System/Flows**: Power Automate per flow (5 licencji zalecane)

---

## Autorzy i podziękowania

- **Architektura systemu**: [Imię Nazwisko]
- **Rozwój Power Platform**: [Imię Nazwisko]
- **Azure Functions**: [Imię Nazwisko]
- **Power BI Dashboards**: [Imię Nazwisko]

Podziękowania dla Microsoft Power Platform Community za wsparcie i inspirację.

---

## Changelog

Zobacz [CHANGELOG.txt](./CHANGELOG.txt) dla pełnej historii zmian.

**Aktualna wersja: 1.0.0** (2024-10-27)

---

**Ostatnia aktualizacja:** 2024-10-27
**Status:** Production Ready ✅
