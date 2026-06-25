# Fase 0 — Researchplan ACNL Turnip Bank Plugin

## Doel

We willen een aparte Animal Crossing: New Leaf 3DS-plugin bouwen, geïnspireerd op Vapecord, met uiteindelijk deze functionaliteit:

* turnips uit de inventory detecteren;
* turnips “depositen” naar een eigen plugin-storagebestand op de SD-kaart;
* actuele Re-Tail turnip price automatisch uitlezen;
* opgeslagen turnips direct verkopen vanuit het menu;
* bells veilig naar de ABD/bank toevoegen;
* anti-overflow toepassen;
* regio- en versiecompatibiliteit behouden;
* uiteindelijk een eigen plugin/menu/hotkey gebruiken, niet de standaard Vapecord-combinatie.

Deze Fase 0 is alleen bedoeld om de benodigde technische informatie te verzamelen. We bouwen nog geen definitieve feature.

---

# Stap 0.1 — Repository en buildomgeving vastleggen

## Doel

Achterhalen of Vapecord lokaal reproduceerbaar te builden is, en welke toolchain/libs nodig zijn.

## Taken

1. Fork of clone de Vapecord-ACNL-Plugin repository.
2. Noteer:

   * repository-URL;
   * commit hash;
   * branch;
   * benodigde devkitPro/devkitARM-versie indien vermeld;
   * benodigde LibCTRPF-versie/branch;
   * buildcommand voor Windows/Linux;
   * outputbestandstype, waarschijnlijk `.3gx`.

## Te onderzoeken bestanden

* `README.md`
* `Makefile`
* `build.bat`
* eventuele setup/build documentatie
* dependency-verwijzingen naar CTRPluginFramework / LibCTRPF

## Uitkomst invullen

````md
## Buildomgeving

Repo:
Commit:
Branch:

Benodigde tools:
- 
- 
- 

Buildcommand:
```bash
...
````

## Build-output:

Buildstatus:

* [ ] Build succesvol
* [ ] Build faalt

Buildfout indien van toepassing:

```text
...
```

````

## Acceptatiecriterium

We moeten Vapecord ongewijzigd kunnen builden of exact weten waarom dat nog niet lukt.

---

# Stap 0.2 — Projectstructuur in kaart brengen

## Doel

Begrijpen waar features, menu-items, offsets, helpers en memoryfuncties zitten.

## Taken

Breng de belangrijkste mappen en bestanden in kaart.

Zoek naar termen:

```text
Menu
PluginMenu
MenuEntry
Keyboard
Hotkey
Inventory
Pockets
Storage
Money
Bells
Bank
ABD
Turnip
Item
Player
Offset
Region
Version
TitleID
````

## Uitkomst invullen

```md
## Projectstructuur

Belangrijke mappen:

| Map/bestand | Doel |
|---|---|
| `src/...` | ... |
| `include/...` | ... |
| `Sources/...` | ... |

Feature-registratie/menu:
- Bestand:
- Belangrijke functies/classes:

Memory helpers:
- Bestand:
- Belangrijke functies/classes:

Offset/region handling:
- Bestand:
- Belangrijke functies/classes:

Inventory/item handling:
- Bestand:
- Belangrijke functies/classes:

Money/bank handling:
- Bestand:
- Belangrijke functies/classes:
```

## Acceptatiecriterium

We moeten weten waar we later nieuwe code zouden toevoegen en welke bestaande modules we kunnen hergebruiken.

---

# Stap 0.3 — Menu en hotkey-systeem onderzoeken

## Doel

Achterhalen hoe Vapecord het menu opent en hoe we later een eigen menu of andere hotkey kunnen gebruiken.

## Taken

Zoek naar:

```text
Hotkey
Key
Controller
IsDown
WasPressed
PluginMenu
Menu
Open
Settings
```

Onderzoek:

1. Waar wordt de standaard menu-open-combinatie ingesteld?
2. Is deze hardcoded of via CTRPF settings wijzigbaar?
3. Kunnen we de pluginnaam/menu-titel aanpassen?
4. Kunnen we een gestripte plugin maken met alleen eigen menu-items?
5. Is er code die expliciet Vapecord branding/menu entries injecteert?

## Uitkomst invullen

```md
## Menu en hotkey

Plugin/menu titel wordt ingesteld in:
- Bestand:
- Regel/functie:

Menu-open hotkey wordt ingesteld in:
- Bestand:
- Regel/functie:

Hotkey is:
- [ ] hardcoded
- [ ] configureerbaar via CTRPF
- [ ] onbekend

Kan eigen plugin/menu:
- [ ] ja
- [ ] nee
- [ ] waarschijnlijk, maar nog testen

Notities:
```

## Acceptatiecriterium

We moeten weten of de uiteindelijke plugin als eigen menu met eigen hotkey haalbaar is.

---

# Stap 0.4 — Region/version-detectie onderzoeken

## Doel

Achterhalen hoe Vapecord regio’s en gameversies ondersteunt.

ACNL heeft meerdere regio’s/versies, onder andere USA, EUR, JPN, KOR en Welcome amiibo. Onze plugin mag geen losse hardcoded offsets gebruiken zonder regio-laag.

## Taken

Zoek naar:

```text
Region
USA
EUR
JPN
KOR
TitleID
GameVersion
Welcome
Amiibo
Offset
Address
```

Onderzoek:

1. Hoe detecteert Vapecord de game/regio?
2. Wordt TitleID gebruikt?
3. Wordt gameversion gebruikt?
4. Is er een centrale offset table?
5. Zijn er helperfuncties zoals `GetRegion()`, `GetOffset()`, `Process::Read...`?
6. Zijn offsets per regio hardcoded of via pattern scanning?

## Uitkomst invullen

````md
## Region/version handling

Regio-detectie:
- Bestand:
- Functie/class:
- Methode:

Ondersteunde regio’s:
- [ ] USA
- [ ] EUR
- [ ] JPN
- [ ] KOR
- [ ] Welcome amiibo
- [ ] anders:

Offsetstructuur:
- Bestand:
- Voorbeeld:

```cpp
...
````

Aanbevolen manier om nieuwe offsets toe te voegen:

````

## Acceptatiecriterium

We moeten een duidelijke strategie hebben voor regio-compatibiliteit voordat we turnip price/bank offsets toevoegen.

---

# Stap 0.5 — Huidige speler / player base achterhalen

## Doel

Achterhalen hoe Vapecord bepaalt welke speler actief is, omdat inventory, bank en mogelijk save-data per speler kunnen verschillen.

## Taken

Zoek naar:

```text
Player
CurrentPlayer
PlayerBase
Mayor
Character
Resident
Index
````

Onderzoek:

1. Hoe wordt de actieve speler bepaald?
2. Is er een player index?
3. Waar begint de player struct?
4. Zijn bank/inventory per speler of globaal?
5. Kan Vapecord wisselen tussen speler 1/2/3/4?

## Uitkomst invullen

```md
## Current player / player base

Actieve speler detectie:
- Bestand:
- Functie:

Player index/type:
- Type:
- Mogelijke waarden:

Player base:
- Hoe bepaald:
- Regio-afhankelijk:
  - [ ] ja
  - [ ] nee
  - [ ] onbekend

Open vragen:
- 
```

## Acceptatiecriterium

We moeten weten hoe we de juiste speler selecteren voor inventory en bankbewerkingen.

---

# Stap 0.6 — Inventory/pockets-structuur onderzoeken

## Doel

Achterhalen hoe turnips in de inventory staan, zodat we ze later veilig kunnen depositen.

## Taken

Zoek naar:

```text
Inventory
Pockets
Pocket
Slot
Item
ItemID
ItemId
Flags
Count
Quantity
Spawner
Text2Item
Drop
```

Onderzoek bestaande Vapecord-features zoals:

* Item Spawner
* Text2Item
* Inventory buttons
* Drop/item functies
* Put Item To Storage
* eventuele item search functies

Vragen beantwoorden:

1. Hoeveel pocket slots zijn er?
2. Hoe wordt een slot gelezen?
3. Hoe wordt een slot leeggemaakt?
4. Hoe wordt item-ID opgeslagen?
5. Hoe worden flags/quantity opgeslagen?
6. Is een turnip stack één item met quantity/flags?
7. Of zijn turnips alleen een item-ID zonder quantity?
8. Welke bestaande functies kunnen we hergebruiken?

## Uitkomst invullen

````md
## Inventory/pockets

Aantal slots:
- 

Slotstructuur:
```cpp
...
````

Slot lezen:

* Functie:
* Bestand:

Slot schrijven/leegmaken:

* Functie:
* Bestand:

## Item-ID type:

## Flags/quantity:

## Bestaande helperfuncties:

*

## Risico’s:

````

## Acceptatiecriterium

We moeten minimaal één inventory-slot betrouwbaar kunnen uitlezen en veilig kunnen leegmaken.

---

# Stap 0.7 — Turnip item-ID en stackgedrag bevestigen

## Doel

Exact achterhalen hoe turnips in ACNL worden gerepresenteerd.

## Taken

Zoek in item ID-lijsten en Vapecord-code naar:

```text
Turnip
Turnips
White turnip
Spoiled turnip
Spoilt turnip
````

Onderzoek:

1. Item-ID van normale turnips.
2. Item-ID van rotte turnips.
3. Verschil tussen normale en rotte turnips.
4. Hoe een stack van 10/100 turnips wordt opgeslagen.
5. Of turnips quantity in flags gebruiken.
6. Of turnip amount uit item variant/metadata komt.

## Praktijktest

Maak in-game deze testcases:

```text
Case A: 10 turnips in pockets
Case B: 100 turnips in pockets
Case C: meerdere stacks van 100
Case D: rotte turnips
```

Log per slot:

```text
slot index
raw item value
item id
flags
quantity/metadata
herkende naam
```

## Uitkomst invullen

````md
## Turnip item data

Normale turnip:
- Item-ID:
- Raw value voorbeeld:
- Flags/quantity voorbeeld:

Rotte turnip:
- Item-ID:
- Raw value voorbeeld:
- Flags/quantity voorbeeld:

Stackgedrag:
- [ ] quantity/flags
- [ ] aparte itemvariant
- [ ] onbekend

Voorbeeldlogs:
```text
...
````

````

## Acceptatiecriterium

We moeten een functie kunnen ontwerpen:

```cpp
bool IsTurnip(Item item);
u32 GetTurnipAmount(Item item);
Item EmptySlot();
````

---

# Stap 0.8 — Re-Tail turnip price table vinden

## Doel

Automatisch de actuele turnip price kunnen bepalen.

ACNL heeft turnip prices per dag en per dagdeel. We moeten de huidige prijs uit save/memory halen, niet handmatig invoeren.

## Taken

Zoek eerst in bekende save-editor/source-data naar offsets voor:

```text
Turnip price
Turnip prices
Monday AM
Monday PM
Tuesday AM
Tuesday PM
Wednesday AM
Wednesday PM
Thursday AM
Thursday PM
Friday AM
Friday PM
Saturday AM
Saturday PM
```

Onderzoek daarna in Vapecord of er al functies bestaan voor:

```text
Game time
Weekday
Clock
Date
Time
Retail
Shop
```

Vragen beantwoorden:

1. Waar staat de turnip price table?
2. Is dit in RAM, save-buffer of beide?
3. Welk datatype gebruikt de prijs? `u16`? `u32`?
4. Hoeveel entries zijn er?
5. Welke volgorde hebben de entries?
6. Hoe bepaal je AM/PM?
7. Hoe bepaal je zondag/no-sale?
8. Is de price table regio-afhankelijk?
9. Kan de waarde live veranderen wanneer de dag/PM wisselt?

## RAM-verificatieprocedure

Voer op echte hardware of emulator/debugomgeving uit:

```text
1. Start game op maandag AM.
2. Vraag Re-Tail prijs op bij Reese.
3. Zoek in RAM naar deze prijs als u16 en eventueel u32.
4. Noteer kandidaat-adressen.
5. Ga naar maandag PM of dinsdag AM.
6. Vraag nieuwe prijs op.
7. Filter kandidaat-adressen op nieuwe waarde.
8. Herhaal minimaal 3 prijswissels.
9. Vergelijk kandidaat-adressen met save-editor-offsets.
```

## Uitkomst invullen

````md
## Turnip price table

Bron:
- [ ] Vapecord-code
- [ ] Save editor
- [ ] RAM search
- [ ] anders:

Adres/offset:
- USA:
- EUR:
- JPN:
- KOR:

Datatype:
- [ ] u16
- [ ] u32
- [ ] anders:

Aantal entries:
- 

Entry-volgorde:
```text
0 = 
1 = 
2 = 
...
````

AM/PM bepaling:

* Bestand/functie:
* Methode:

Weekday bepaling:

* Bestand/functie:
* Methode:

Zondag/no-sale:

* Gedrag:

Voorbeeldlogs:

```text
Monday AM price:
Monday PM price:
Tuesday AM price:
...
```

Conceptfunctie:

```cpp
u16 GetCurrentRetailTurnipPrice()
{
    // TODO
}
```

````

## Acceptatiecriterium

We moeten met logging de actuele Re-Tail-prijs tonen die overeenkomt met wat Reese in-game zegt.

---

# Stap 0.9 — Bank/ABD balance vinden

## Doel

Payout veilig naar de ABD/bank kunnen schrijven.

## Taken

Zoek in Vapecord naar money/bank functies:

```text
Money
Bells
Wallet
Bank
ABD
Savings
Debt
Loan
MaxMoney
````

Onderzoek:

1. Is er bestaande code voor wallet bells?
2. Is er bestaande code voor bank/ABD balance?
3. Is bank balance per speler?
4. Welk datatype gebruikt bank balance?
5. Wat is de maximale bankwaarde?
6. Zijn er checksums/secure values nodig?
7. Moet de waarde direct naar RAM of save-buffer?
8. Blijft de waarde behouden na save + reboot?

## Praktijktest

Maak of gebruik een bestaande testfunctie:

```text
1. Lees huidige bankwaarde.
2. Log bankwaarde.
3. Tel 1.000 bells op.
4. Save de game.
5. Herstart de game.
6. Controleer of ABD/bankwaarde klopt.
```

## Uitkomst invullen

````md
## Bank/ABD balance

Bank balance gevonden:
- [ ] ja
- [ ] nee

Bestand/functie:
- 

Adres/offset:
- USA:
- EUR:
- JPN:
- KOR:

Datatype:
- [ ] u32
- [ ] u64
- [ ] anders:

Maximale veilige waarde:
- 

Per speler:
- [ ] ja
- [ ] nee
- [ ] onbekend

Checksum/secure value nodig:
- [ ] ja
- [ ] nee
- [ ] onbekend

Bestaande helperfunctie:
```cpp
...
````

Testresultaat:

```text
Voor:
Na +1000:
Na save/reboot:
```

````

## Acceptatiecriterium

We moeten bankwaarde betrouwbaar kunnen lezen en veilig kunnen verhogen zonder corruptie of overflow.

---

# Stap 0.10 — Anti-overflow en payoutregels definiëren

## Doel

Voorkomen dat de plugin bankwaarden corrumpeert of wraparound veroorzaakt.

## Taken

Onderzoek:

1. Maximale bankwaarde in ACNL.
2. Maximale walletwaarde indien relevant.
3. Maximale item/turnip count die onze plugin mag opslaan.
4. Maximale payout bij `turnips × price`.
5. Of `u64` nodig is voor berekening.
6. Wat de plugin moet doen als payout groter is dan beschikbare bankruimte.

## Gewenst gedrag

Voorlopig ontwerp:

```text
Als payout past:
- voeg volledig bedrag toe aan bank
- trek verkochte turnips af van plugin-storage

Als payout niet past:
- verkoop blokkeren
- toon melding: "Bank limit would be exceeded"
- geen turnips aftrekken

Alternatief later:
- gedeeltelijke verkoop toestaan tot banklimiet
````

## Uitkomst invullen

````md
## Anti-overflow

Max bank:
- 

Max wallet:
- 

Berekeningstype:
- [ ] u32 voldoende
- [ ] u64 nodig

Gekozen gedrag bij overflow:
- [ ] verkoop blokkeren
- [ ] gedeeltelijke verkoop
- [ ] anders:

Conceptcode:
```cpp
bool CanAddToBank(u64 currentBank, u64 payout, u64 maxBank)
{
    return payout <= (maxBank - currentBank);
}
````

````

## Acceptatiecriterium

We hebben duidelijke limieten en kunnen overflow vóór schrijven detecteren.

---

# Stap 0.11 — Eigen plugin-storage op SD-kaart onderzoeken

## Doel

Bepalen hoe we opgeslagen turnips veilig buiten de game-save opslaan.

## Taken

Zoek in Vapecord/CTRPF naar file I/O:

```text
File
Directory
Path
sdmc
fopen
File::Open
Directory
Save
Backup
Settings
Config
````

Onderzoek:

1. Hoe schrijft Vapecord settings/data naar SD?
2. Welke file helpers zijn beschikbaar?
3. Wat is een veilige directory?
4. Kunnen we atomic writes doen?
5. Kunnen we backup/corruptie-detectie toevoegen?

## Gewenst opslagformaat v1

Bijvoorbeeld:

```text
sdmc:/3ds/ACNLTurnipBank/turnip_bank.dat
```

Inhoud conceptueel:

```text
magic: ATB1
version: 1
region/titleid
player_id
stored_turnips
last_update_timestamp
crc/checksum
```

## Uitkomst invullen

````md
## Plugin storage

Beschikbare file I/O helpers:
- 

Voorgesteld pad:
- 

Bestandsformaat:
```cpp
struct TurnipBankFile {
    char magic[4];
    u32 version;
    u64 storedTurnips;
    u32 checksum;
};
````

Atomic write mogelijk:

* [ ] ja
* [ ] nee
* [ ] onbekend

## Backupstrategie:

````

## Acceptatiecriterium

We weten hoe we een klein eigen storagebestand veilig kunnen lezen/schrijven.

---

# Stap 0.12 — Save backup en testprotocol

## Doel

Voorkomen dat testen een echte ACNL-save beschadigt.

## Taken

Onderzoek:

1. Heeft Vapecord bestaande save-backupfunctionaliteit?
2. Waar worden backups opgeslagen?
3. Kunnen we vóór bank/inventory tests automatisch of handmatig backup maken?
4. Hoe herstellen we een backup?
5. Welke testomgeving gebruiken we: echte 3DS, emulator, kopie-save?

## Uitkomst invullen

```md
## Backup/testprotocol

Testomgeving:
- [ ] echte 3DS
- [ ] emulator
- [ ] beide

Backupmethode:
- 

Backup vóór elke risicotest:
- [ ] ja
- [ ] nee

Herstelprocedure:
```text
...
````

Minimale testmatrix:

* [ ] USA
* [ ] EUR
* [ ] JPN
* [ ] KOR
* [ ] Welcome amiibo
* [ ] speler 1
* [ ] speler 2/3/4

````

## Acceptatiecriterium

We kunnen bank/inventory/price-tests uitvoeren zonder onherstelbare save-schade.

---

# Stap 0.13 — Onderzoeksresultaten samenvoegen

## Doel

Alle gevonden informatie bundelen zodat daarna een echt ontwikkelplan gemaakt kan worden.

## Einddocument moet bevatten

```md
# ACNL Turnip Bank — Research Results

## 1. Buildstatus
...

## 2. Menu/hotkey
...

## 3. Region/version strategy
...

## 4. Current player
...

## 5. Inventory/pockets
...

## 6. Turnip item data
...

## 7. Re-Tail price table
...

## 8. Bank/ABD balance
...

## 9. Anti-overflow
...

## 10. Plugin storage
...

## 11. Backup/testprotocol
...

## 12. Open questions
...

## 13. Ready/not ready for development

- [ ] klaar voor pluginplan
- [ ] nog niet klaar

Blokkerende punten:
- 
- 
````

## Definition of Done voor Fase 0

Fase 0 is pas klaar als deze punten zijn ingevuld:

```md
- [ ] Vapecord build werkt lokaal
- [ ] We weten hoe menu/hotkey werkt
- [ ] We weten hoe regio/version detectie werkt
- [ ] We weten hoe actieve speler bepaald wordt
- [ ] We kunnen inventory slots lezen
- [ ] We kunnen turnips herkennen
- [ ] We weten hoe turnip amount/stack werkt
- [ ] We kunnen actuele Re-Tail turnip price uitlezen
- [ ] We kunnen bank/ABD balance uitlezen
- [ ] We kunnen bank/ABD balance veilig verhogen
- [ ] We weten maximale bankwaarde
- [ ] We hebben anti-overflow-regels
- [ ] We weten hoe eigen SD-storage werkt
- [ ] We hebben een backup/testprotocol
```

Pas na deze Definition of Done maken we Fase 1: het daadwerkelijke ontwikkelplan voor de plugin.
