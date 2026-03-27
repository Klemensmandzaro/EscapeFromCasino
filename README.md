GDD (Game Design Document) - Escape From Casino
1. Informacje Ogólne
Tytuł roboczy: Escape From Casino

Silnik gry: Godot Engine 4.6.1

Gatunek: Roguelite / Symulator Kasyna

Platforma docelowa: PC (Windows)

Target Audience: Gracze 18+ (motywy hazardowe), fani gier typu Roguelite (np. Balatro, Hades) oraz speedrunnerzy.

Główny twórca: Kamil Klemiato

2. O czym jest gra? (High Concept)
Escape From Casino to innowacyjne połączenie klasycznych minigier kasynowych z mechanikami znanymi z gier typu roguelite (meta-progresja, permadeath w obrębie "runa", unikalne klasy postaci). Gracz wciela się w hazardzistę, który musi przejść przez serię coraz trudniejszych stołów kasynowych. Utrata żetonów oznacza wyrzucenie z kasyna (Game Over) i konieczność rozpoczęcia pętli od nowa, jednak gracz zachowuje specjalne Punkty VIP, za które może kupować stałe ulepszenia ułatwiające kolejne podejścia.

3. Główna Pętla Rozgrywki (Core Loop)
Rozgrywka dzieli się na pojedyncze podejścia ("Runy"). Pętla wygląda następująco:

Rozpoczęcie Runa: Gracz startuje przy pierwszym stole z domyślną pulą gotówki.

Minigry: Przechodzenie przez kolejne stoły (Kości -> Blackjack -> Autobus). Warunkiem awansu jest osiągnięcie wyznaczonego progu finansowego (Level Requirements).

Koniec Runa: * Wygrana: Pokonanie ostatniego stołu (Autobus).

Przegrana (Bankructwo): Utrata wszystkich żetonów.

Nagroda: Niezależnie od wyniku, za pokonane poziomy gracz otrzymuje walutę premium (Punkty VIP).

Sklep VIP: Gracz wydaje punkty na stałe ulepszenia lub odblokowanie klas postaci.

Restart: Rozpoczęcie nowego Runa z ulepszonymi statystykami.

4. Minigry (Poziomy Kasyna)
Gra składa się z trzech głównych modułów (stołów):

Etap 1: Kości (Dice Game) - Prosta gra oparta na rachunku prawdopodobieństwa i rzutach kośćmi. Służy jako wprowadzenie do mechaniki obstawiania i budowania początkowego kapitału.

Etap 2: Blackjack - Klasyczne oczko. Rozgrywka z krupierem, gdzie gracz musi decydować o dobieraniu kart (Hit/Stand), starając się nie przekroczyć wartości 21.

Etap 3: Jazda Autobusem (Ride the Bus) - Najbardziej rozbudowana gra 4-etapowa:

Czerwone czy Czarne?

Wyższa czy Niższa?

Pomiędzy czy Na zewnątrz?

Zgadnij Znak (Pik, Kier, Trefl, Karo)

Unikalna mechanika: Opcja "Cash Out" – po każdym z etapów Autobusu gracz może stchórzyć i wyciągnąć bezpieczną, pomnożoną stawkę, lub zaryzykować wszystko dla Jackpota na końcu (x10).

5. Meta-progresja i Sklep VIP
Za zdobywane podczas gry Punkty VIP (obliczane na podstawie pokonanych etapów i zebranej w ich trakcie gotówki), gracz może ulepszać swoje konto:

Gruby Portfel (Upgrade): Zwiększa początkową ilość gotówki na start każdego nowego Runa.

Magnes na Kasę (Upgrade): Szansa procentowa na to, że przy każdej wygranej gracz znajdzie dodatkowe, bonusowe monety.

Druga Szansa / Przetrwanie (Upgrade): Szansa procentowa na to, że przy bankructwie gracz nie skończy gry, lecz otrzyma od kasyna "koło ratunkowe" w postaci 10 monet na odbicie się od dna.

Klasy Postaci
Gracz może wybrać jedną z 3 klas, modyfikującą zasady gry:

Bogacz: Skupia się na bezpiecznej grze, otrzymuje ogromny bonus do gotówki początkowej z ulepszenia "Gruby Portfel".

Ryzykant: Posiada 20% szans na magiczne podwojenie absolutnie każdej wygranej puli.

Szuler: Zmienia zasady gry. W grach takich jak Blackjack czy Autobus, wszystkie remisy (trafienie w słupek/równą wartość) są traktowane jako wygrana gracza, zamiast kasyna.

6. Systemy Techniczne i Architektura (Technical Design)
GameManager (Singleton): Serce gry działające w tle. Przechowuje globalne statystyki, śledzi poziomy, przelicza walutę i obsługuje system audio.

SaveManager: System automatycznego zapisu i odczytu gry wykorzystujący format pliku .cfg (ConfigFile). Zapisuje postępy w sklepie, wybraną klasę oraz łączny czas gry. Pozwala to na wyłączenie aplikacji i powrót do statystyk z poprzedniej sesji.

Speedrun Timer: Globalny stoper wbudowany w system gry. Zlicza dokładny czas (co do milisekund) od kliknięcia "Nowa Gra", tykając nieprzerwanie przez wszystkie porażki i pobyty w menu, aż do ostatecznego zwycięstwa, wspierając społeczność speedrunnerską.

7. Wykorzystane Zasoby (Credits)
Kod: Logika i architektura (w tym GameManager, pętle minigier) zostały opracowane we współpracy z modelami sztucznej inteligencji, a następnie ręcznie przetestowane, zmodyfikowane i dopracowane o autorskie mechaniki.

Grafika (UI / Tła / Żetony): Połączenie wygenerowanych przez AI obrazów (Leonardo AI) z darmowymi zasobami wektorowymi z otwartej biblioteki Kenney.nl.

Audio: Klimatyczne utwory Jazzowe w tle pobrane na darmowej licencji CC0 (Public Domain) z serwisu Pixabay.com.
