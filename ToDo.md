# ToDo

Statusy:
- `[TODO]` do wykonania
- `[IN PROGRESS]` w trakcie
- `[DONE]` zakończone
- `[BLOCKED]` zablokowane

## Faza 1. Fundament projektu

- `[DONE]` Zdefiniować rejestr aktów i model progresji kampanii.
  Zakres: przygotować dane dla 5 aktów, zależności odblokowania i przejścia między aktami.

- `[DONE]` Zaimplementować graf obszarów i połączeń między strefami.
  Zakres: wejścia/wyjścia, podobszary, hierarchię dungeonów oraz podstawy ładowania i rozładowania stref.

- `[DONE]` Przygotować schemat zadań i evaluator celów.
  Zakres: obsłużyć typy celów `kill`, `find`, `interact`, `collect`, `combine`, `travel`.

- `[DONE]` Dodać maszynę stanów przebiegu rozgrywki.
  Zakres: przejścia `hub -> field -> dungeon -> boss room -> town`, warunki sukcesu/porażki i restart runu.

## Faza 2. Postać i walka

- `[DONE]` Zaimplementować architekturę klas postaci.
  Zakres: definicje klas, bazowe statystyki, ograniczenia ekwipunku oraz powiązanie z animacjami/akcjami.

- `[DONE]` Dodać system atrybutów i statystyk pochodnych.
  Zakres: punkty za poziom, walidację rozdawania oraz przeliczanie statystyk wynikowych.

- `[DONE]` Zaimplementować system umiejętności i specjalizacji.
  Zakres: drzewka umiejętności, zależności, skille aktywne/pasywne, skalowanie rang i przypisanie do hotbara.

- `[DONE]` Dodać system doświadczenia i awansów poziomów.
  Zakres: XP z potworów, bossów i questów oraz pipeline nagród za level-up.

- `[DONE]` Zbudować podstawowy system walki czasu rzeczywistego.
  Zakres: ruch, wybór celu, ataki melee/ranged, timing uderzeń i pipeline obrażeń.

- `[DONE]` Dodać typy obrażeń, odporności i mitygację.
  Zakres: obrażenia fizyczne/żywiołowe, kolejność redukcji oraz hooki efektów on-hit.

- `[DONE]` Zaimplementować system zasobów bojowych.
  Zakres: mana/stamina, koszty akcji, regeneracja, leech, mikstury i komunikaty braku zasobu.

- `[DONE]` Dodać system śmierci, odrodzenia i odzyskiwania po zgonie.
  Zakres: flow śmierci gracza, miejsce respawnu, zasady odzysku i tuning kar.

## Faza 3. Przeciwnicy i spotkania

- `[DONE]` Przygotować framework archetypów przeciwników.
  Zakres: szablony danych potworów, typy AI i skalowanie trudności zależnie od aktu i obszaru.

- `[DONE]` Zaimplementować resolver spawnów dla obszarów.
  Zakres: przypisywanie tabel spawnów do stref, trudności i rodzaju lokacji.

- `[DONE]` Dodać system elit i championów.
  Zakres: pule modyfikatorów, mnożniki statystyk, nadpisania zachowań i czytelność wizualna.

- `[DONE]` Zaimplementować system walk z bossami.
  Zakres: areny, unikalne AI, fazy walki, sekwencje wejścia/pokonania oraz blokady przejścia.

- `[DONE]` Dodać specjalne reguły nagród dla bossów.
  Zakres: first-kill, repeat-kill, quest rewards oraz zabezpieczenia przed exploitem farmienia.

## Faza 4. Przedmioty i ekwipunek

- `[DONE]` Zaimplementować model danych przedmiotów.
  Zakres: dropy światowe, serializacja, stackowalność, jakość, affixy, sockety, poziom i flagi własności.

- `[DONE]` Dodać system jakości i rzadkości przedmiotów.
  Zakres: pipeline rolli jakości, generację statystyk zależnych od jakości i reprezentację w UI.

- `[DONE]` Zaimplementować generator affixów.
  Zakres: prefixy/suffixy, ograniczenia typów przedmiotów, level gating i wsparcie dla seedów debugowych.

- `[DONE]` Dodać sloty ekwipunku i system paper-doll.
  Zakres: walidację zakładania, ograniczenia klas/atrybutów/poziomu i przeliczanie statystyk.

- `[DONE]` Zaimplementować system tabel dropu i resolver łupów.
  Zakres: potwory, bossowie, skrzynie, quest items, złoto, consumables i ekwipunek.

- `[DONE]` Dodać system podnoszenia przedmiotów i przepływu world drop -> inventory.
  Zakres: reprezentację dropów na mapie, interakcję pickup i walidację miejsca w ekwipunku.

- `[DONE]` Zaimplementować gridowy ekwipunek.
  Zakres: zajętość pól, rozmiary przedmiotów, auto-place oraz drag and drop działają w runtime/UI.

- `[DONE]` Dodać stash jako trwały magazyn przedmiotów.
  Zakres: pojemność, serializację, politykę shared/character stash oraz walidację antyduplikacyjną.

## Faza 5. Progresja świata i podróżowanie

- `[DONE]` Zaimplementować waypointy i szybkie podróżowanie.
  Zakres: odblokowanie per postać, UI podziału na akty oraz ograniczenia użycia.

- `[DONE]` Dodać system Town Portal.
  Zakres: tymczasowy portal dwukierunkowy, owner binding, warunki unieważnienia i zasady anty-exploit.

- `[DONE]` Zaimplementować system hubów miejskich i usług NPC.
  Zakres: safe zone, przełączanie stanu audio/UI, vendorzy, stash, NPC questowi i craftingowi.

- `[TODO]` Dodać system obiektów interaktywnych świata.
  Zakres: shriny, wejścia, urządzenia questowe, stany locked/unlocked i wsparcie minimapy/UI.

- `[TODO]` Zaimplementować lifecycle quest itemów.
  Zakres: flagi questowe, ograniczenia transferu/despawnu, integrację ze śmiercią i ochronę przed duplikacją.

## Faza 6. Horadric Cube i crafting

- `[TODO]` Dodać kontener i UI Horadric Cube.
  Zakres: pojemność, wkładanie/wyjmowanie przedmiotów, akcję transmute i integrację z questami.

- `[TODO]` Zaimplementować silnik receptur transmutacji.
  Zakres: baza receptur, dopasowanie wzorców, walidację metadanych i generowanie wyniku.

- `[TODO]` Dodać questowe receptury łączenia przedmiotów.
  Zakres: Horadric Staff, Khalim's Will, odblokowanie receptur przez stan questa i zabezpieczenie przed utratą krytycznych itemów.

- `[TODO]` Zaimplementować receptury rerollu i upgrade'u.
  Zakres: losowe konwersje, ograniczenia jakości/poziomu i balans ekonomiczny.

- `[TODO]` Dodać feedback sukcesu i błędów transmutacji.
  Zakres: komunikaty UI, powody odrzucenia receptury i bezpieczne zużycie inputów.

## Faza 7. Interfejs użytkownika

- `[DONE]` Zaimplementować HUD i UI statusu walki.
  Zakres: health, resource, hotbar, buffy/debuffy, target info i overlay HP bossa.

- `[IN PROGRESS]` Dodać komplet UI dla inventory, equipment, stash i cube.
  Zakres: inventory, equipment, stash, vendor i journal mają już okienkowe UI z tooltipami hover, porównaniem itemów, kolorowaniem slotów per rzadkość itemu i akcjami kontekstowymi; drag and drop działa już dla inventory/equipment/stash, ale nadal brakuje Horadric Cube, domknięcia przepływu vendorowego myszą i finalnego polishu layoutu.

- `[IN PROGRESS]` Zaimplementować journal questów i UI progresji.
  Zakres: lista questów, statusy i panel szczegółów działają; nadal brakuje lepszego grupowania per akt i podpowiedzi celu.

- `[DONE]` Dodać UI podróżowania przez waypointy.
  Zakres: zakładki aktów, stany enabled/disabled i reguły dostępności.

## Faza 8. Zapis, reset świata i ekonomia

- `[DONE]` Zaimplementować system zapisu stanu postaci.
  Zakres: statystyki, skille, questy, waypointy, ekwipunek, stash i postęp kampanii.

- `[DONE]` Dodać walidację integralności save'a i strategię migracji wersji.
  Zakres: wersjonowanie danych, zgodność wsteczna i wykrywanie uszkodzonych zapisów.

- `[DONE]` Zaimplementować reset świata i obsługę powtarzalnych runów.
  Zakres: respawn przeciwników, reset lokalnych obiektów oraz zachowanie trwałych odblokowań.

- `[DONE]` Dodać system vendorów i transakcji.
  Zakres: ceny, odświeżanie asortymentu, buyback oraz wsparcie dla consumables i equipment.

- `[TODO]` Zaimplementować system identyfikacji przedmiotów.
  Zakres: stan unidentified, akcję reveal i zmianę tooltipu po identyfikacji.

- `[DONE]` Dodać system consumables.
  Zakres: typy mikstur, quick-sloty, stackowanie i reguły auto-pickupu.

## Faza 9. Integracja techniczna i testy

- `[TODO]` Rozdzielić każdy główny system na warstwy: data model, logika, UI, save/load.
  Zakres: utrzymać spójną strukturę modułów zgodnie z założeniami projektu.

- `[DONE]` Przygotować strukturę katalogów zgodną z planem implementacji.
  Zakres: `systems/quests`, `systems/combat`, `systems/items`, `systems/cube`, `systems/world`, `systems/ui`, `data/acts`, `data/items`, `data/recipes`.

- `[TODO]` Dodać test cases dla krytycznych przepływów systemowych.
  Zakres: progresja questów, dropy, transmutacje, save/load, respawn świata i boss gating.

- `[IN PROGRESS]` Przeprowadzić integrację całościowego loopu gry.
  Zakres: uproszczony loop `town -> eksploracja -> walka -> boss -> loot -> powrót -> postęp aktu` działa już dla kampanii sandboxowej Act 1; nadal brakuje pełnej integracji questów z obiektami świata, przejściami specjalnymi i docelowym contentem kolejnych aktów.
