<img width="120" height="50" alt="Netflix_Logo_CMYK" src="https://github.com/user-attachments/assets/e54563c3-6459-43f3-bd8c-e8385afb8373"  align="right"/>

# Analiza Biblioteki Treści 

<img width="1197" height="675" alt="Dashboard_Netflix_F" src="https://github.com/user-attachments/assets/914cd81e-950c-46fd-a81e-032b1305b5f3" />
<img width="1197" height="672" alt="Dashboard_Netflix_S" src="https://github.com/user-attachments/assets/3c3d865b-c2e7-444c-af55-bad1e5bf0817" />

## Cel projektu
Głównym celem projektu była analiza globalnej biblioteki filmów i seriali dostępnych na platformie Netflix. Dashboard został zaprojektowany z myślą o kadrze zarządzającej i zespołach contentowych. Interfejs oparto na motywie "Dark Mode" z wykorzystaniem palety kolorystycznej marki (czerń i czerwień), co zapewnia immersyjne doświadczenie i wysoką czytelność kluczowych wskaźników.
## Wykorzystane technologie
* **pgAdmin:** Budowa bazy danych oraz przeprowadzenie procesów ETL (czyszczenie, transformacja i normalizacja surowych danych CSV).
* **SQL:** Zaawansowane manipulacje danymi za pomocą funkcji tekstowych, tablicowych i warunkowych ('UNNEST', 'STRING_TO_ARRAY', 'SPLIT_PART', 'COALESCE', 'CASE').
* **Power BI:** Projektowanie interfejsu (Dark Mode), tworzenie relacji między stronicowych oraz budowa ukrytych etykiet narzędzi (Report Page Tooltip).
* **Modelowanie Danych:** Budowa modelu relacyjnego w oparciu o tabelę słownikowe.
* **DAX:** Tworzenie kluczowych miar (KPI) na potrzeby analizy trendów i rankingów.

## Wyzwania techniczne i inżynieria danych (SQL & Power BI)
Zbiór danych Netflixa wymagał gruntownego czyszczenia i normalizacji przed wczytaniem do warstwy wizualnej. Cały proces transformacji (ETL) przeprowadziłam z wykorzystaniem zapytań SQL w środowisku **pgAdmin**, a modelowanie i wizualizację w **Power BI**.

* **Przygotowanie bazy i czyszczenie danych (NULL):**
  Utworzyłam dedykowane tabele dla surowego pliku CSV. Braki danych (wartości NULL) zestandaryzowałam używając funkcji 'COALESCE', podmieniając je na wartości 'unknown'. Przekonwertowałam również tekstowe formy dat na type 'DATE', z którego wyizolowałam sam rok premiery.
* ** Ekstrakcja logiki biznesowej(CASE & SPLIT_PART):**
  Kolumna określająca czas trwania zawierał wymieszane dane - minuty dla filmów oraz liczbę sezonów dla seriali. Używając funkcji 'SPLIT_PART' oraz instrukcji warunkowej 'CASE', rozdzieliłam te wartości do dwóch osobnych miar analitycznych.
* **Normalizacja relacji (Rozbijanie list tekstowych do wierszy):**
  Kluczowym problemem zbioru był fakt, że w jednej komórce znajdowało się wiele państw, gatunków lub reżyserów oddzielonych przecinkiem. Używając kombinacji funkcji 'TRIM', 'STRING_TO_ARRAY', oraz 'UNNEST', zdenormalizowałam te kolumny, tworząc nowy wiersz dla każdego gatunku, państwa i reżysera przypisanego do danego tytułu. Uwzględniłam przy tym brak danych o reżyserach w przypadku seriali.

  -- Przykładowa logika rozbijania państw z użyciem UNNEST:
  <img width="700" height="600" alt="SQL_panstwa" src="https://github.com/user-attachments/assets/463048aa-e887-4de6-9dbb-0f82b156bfe2" />

* **Modelowanie danych (Tabela słownikowa):**
Raport opierał się na danych zasilających różne wizualizacje. Aby umożliwić odbiorcy filtrowanie całego dashboardu (wszystkich wykresów) za pomocą jednego wspólnego przycisku wyboru typu produkcji, zaprojektowałam tabelę słownikową. Utworzyłam główną tabelę słownikową z typem produkcji ("Movie"/"TV Show"), która filtruje wykresy na dashboardzie (rankingi TOP 10).  Stworzyło to poprawną architekturę relacyjną (most między tabelami), pozwalając filtrom swobodnie przepływać przez cały model.
<img width="800" height="650" alt="Relacje_tabel" src="https://github.com/user-attachments/assets/c0e71010-4131-4c70-a64c-ee343924cf27" />

* **Zaawansowany UX (Raport Page Tooltip):**
  Główny wykres pokazujący "Strategię Netflixa w latach" opiera się na procentowych udziale filmów i seriali, co utrudnia odczytanie wartości bezwględnych. Rozwiązałam to za pomocą ukrytej strony "Tooltip". Po najechaniu kursorem na konkretny rok, wyświetla się dynamiczna tabela pokazująca dokładną, liczbową wartość wyprodukowanych filmów i seriali w danym okresie.
  
  <img width="700" height="300" alt="tabela_strategii" src="https://github.com/user-attachments/assets/771fca3d-6c93-40c1-a22b-e7cdd999546f" />
## Struktura Dashboardu i KPI
Interfejs użytkownika został zaprojektowany w czytelnym układzie "Dark Mode", kładąc nacisk na najważniejsze wskaźniki produkcyjne:

**Kluczowe wskaźniki efektywności (KPI)**
* Całkowita ilość filmów i seriali.
* Podział na łączną ilość filmów i seriali.
* Państwo produkujące najwięcej filmów.
* Państwo produkujące najwięcej seriali.

**Analiza wizualna (Wykresy)**
* **Strategia Netflixa w czasie:** Wykres przedstawiający procentowy udział filmów i seriali w poszczególnych latach (ze wspomnianym zaawansowanym Tooltipem).
* **Top 10 Reżyserów filmów:** Dla seriali w udostępnionej bazie danych nie podano reżyserów.
* **TOP 10 Gatunków:** Najpopularniejsze kategorie treści na platformie.
* **TOP 10 Państw:** Ranking globalnych dostawców treści dla serwisu.

## Kluczowe wnioski biznesowe
Analiza 9 tysięcy tytułów dostępnych w bibliotece pozwoliły na wyodrębnienie kluczowych trendów produkcyjnych i strategicznych platformy:
* **Dominacja formatu filmowego:**
  Globalna biblioteka Netflixa opiera się głównie na filmach pełnometrażowych, które stanowią 2/3 całej oferty (około 6 tysięcy filmów wobec 3 tysięcy seriali).
* **Dywersyfikacja rynków dostawców:**
  Stany Zjednoczone są bezdyskusyjnym liderem produkcji w obu formatach. Jednak na kolejnych miejscach widać wyraźny podział rynkowy: produkcję filmową napędzają Indie (2 miejsce) i Wielka Brytania (3 miejsce), podczas gdy rynek serialowy zdominowany jest przez Wielką Brytanię (2 miejsce) oraz Japonię (3 miejsce).
* **Uniwersalne preferencje gatunkowe:**
Niezależnie od formatu, użytkownicy platformy otrzymują głównie treści z kategorii Dramas i Comedies. Najbardziej płodnymi reżyserami zasilającymi bibliotekę w kategorii filmów okazali się Rajiv Chilaka oraz Jan Suter. Współpraca Netflixa z uznanymi twórcami potwierdza strategię platformy opartą na dywersyfikacji contentu oraz wykorzystaniu doświadczonych producentów do budowania silnego, międzynarodowego portfolio. Rajiv Chilaka i Jan Suter reprezentują różne segmenty rynku - od animacji i contentu dziecięcego po seriale, filmy i produkcje komediowe. 
* **Zmiana strategii platformy (od 2018 roku) i analiza anomalii historycznych:**
  Począwszy od 2018 roku, wykres trendu pokazuje stabilny rosnący udział seriali w całkowitej liczbie dodawanych produkcji (utrzymujący się na poziomie 24-33%).
  
*Uwaga analityczna (Data Quality):* Analiza lat 2008-2014 wykazała drastyczne i niereprezentatywne skoki procentowe udziału seriali (np. 50% w 2008 roku, 0% w latach 2009-2012, 45% w 2013 roku). Narzędzie Tooltip ujaeniło, że wynika to ze skrajnie małego wolumenu danych historycznych w tych latach (mp. w 2008 r. dodano łącznie tylko 2 produkcje, a w 2010 r. zaledwie 1). Powyższe dane wskazują, że agresywna rozbudowa biblioteki platformy rozpoczęła się dopiero po 2014 roku.       

---
*Disclaimer: Ten projekt ma charakter wyłącznie edukacyjny. Nie jest powiązany, sponsorowany ani popierany przez Netflix, Inc.* 
