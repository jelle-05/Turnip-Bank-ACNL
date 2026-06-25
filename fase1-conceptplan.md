# Fase 1 — Concept-ontwikkelplan: ACNL Turnip Bank Plugin

> Bouwt voort op de Fase 0-research in [`research/`](research/). Build werkt (`Vapecord_Public.3gx`),
> volledige API + offsets + EncVal-decode zijn bekend en grotendeels op een echte save bevestigd.
> Dit is een **conceptplan**: definitieve dag-index/persistentie pas na de live-checks (zie §10).

---

## 1. Doel & scope (v1)

Een eigen menu waarmee de speler:
1. **turnips uit de pockets stort** ("Deposit") naar een eigen plugin-storage op de SD-kaart;
2. de **actuele Re-Tail-prijs** automatisch ziet;
3. opgeslagen turnips **verkoopt** (alles of per batch van 1000), met een **bevestigingsmelding**
   die de prijs per turnip toont;
4. de opbrengst **veilig naar de bank (ABD)** geschreven krijgt, met anti-overflow;
5. een **nette melding** krijgt als verkoop niet kan (zondag / banklimiet / niets opgeslagen).

Buiten scope v1: gedeeltelijke verkoop tot exact de banklimiet, meerdere valuta, online sync.

---

## 2. Architectuur & plaatsing

Hergebruik van bestaande Vapecord-modules (zie `research/0.2`):

| Nodig | Hergebruik |
|---|---|
| Actieve speler | `Player::GetSaveData()` |
| Town (prijzen, tijd) | `Town::GetSaveData()` |
| Bank lezen/schrijven | `Game::DecryptValue()` / `Game::EncryptValue()` (secure value!) |
| Inventory | `Inventory::ReadSlot/WriteSlot/GetNextItem`, leeg = `{0x7FFE,0}` |
| SD-opslag | CTRPF `File`/`Directory` (binaire struct-I/O, zie `Plugin_Color.cpp`) |
| Regio | `Address::LoadRegion()` / `Process::GetTitleID()` |
| Menu | `MenuCreate.cpp`-patroon `CreateEntry(...) → Folder->Append(...)` |

**Nieuwe bestanden (voorstel):**
```
src/features/TurnipBank/TurnipBank.cpp      // menu-acties (deposit/sell/view)
src/features/TurnipBank/TurnipStorage.cpp   // .dat lezen/schrijven + checksum
src/features/TurnipBank/TurnipPrice.cpp     // huidige prijs + weekday/AM-PM
include/features/TurnipBank/...             // headers
```
Registratie: nieuwe `MenuFolder "Turnip Bank"` in `InitMenu()` (`MenuCreate.cpp`).
Keuze (productbeslissing, zie `research/0.3`): eigen gestripte plugin **of** folder binnen Vapecord —
v1 als folder binnen de bestaande build is het snelst; eigen branding later.

---

## 3. Datamodel — turnip helpers (Fase 0 / 0.7)

```cpp
inline bool IsTurnip(Item it)        { return it.ID >= 0x2283 && it.ID <= 0x228C; }
inline bool IsSpoiledTurnip(Item it) { return it.ID == 0x228D; }
inline u32  GetTurnipAmount(Item it) { return IsTurnip(it) ? (it.ID - 0x2283 + 1) * 10 : 0; }
inline Item EmptySlot()              { return Item{0x7FFE, 0}; }
```
Aantal zit in het **item-ID** (10..100 per slot), niet in `Flags`. Onze storage telt het **totaal**
(een u64), dus we zijn niet gebonden aan veelvouden van 10.

---

## 4. Plugin-storage (Fase 0 / 0.11)

Per speler + town gescheiden, op de SD-kaart:
```
E:/3ds/ACNLTurnipBank/<regio>/<TID>_<PID>.dat
```
```cpp
#pragma pack(push,1)
struct TurnipBankFile {
    char magic[4];      // "ATB1"
    u32  version;       // 1
    u64  titleId;       // Process::GetTitleID()  (regio/versie)
    u16  townId;        // ACNL_TownData TID
    u16  playerId;      // PlayerID PID
    u64  storedTurnips; // totaal opgeslagen turnips
    u64  lastUpdate;    // CurrentTime bij laatste wijziging
    u32  checksum;      // CRC32 over alle voorgaande bytes
};
#pragma pack(pop)
```
Schrijven: tmp-bestand → verifiëren → vervangen; tweede kopie `.bak`. Bij corruptie (`magic`/`checksum`)
val terug op `.bak`. Raakt de game-save **niet**.

---

## 5. Menu-items (v1)

Eigen folder **"Turnip Bank"**:

| Entry | Actie |
|---|---|
| **Deposit Turnips** | Scan pockets → tel turnips → tel op bij storage → maak die slots leeg |
| **Sell All Turnips** | Verkoop alle opgeslagen turnips tegen de actuele prijs (met bevestiging) |
| **Sell 1,000 Turnips** | Verkoop 1000 (of minder als er minder is) tegen de actuele prijs (met bevestiging) |
| **View Turnip Bank** | Toon: opgeslagen aantal, actuele prijs, mogelijke opbrengst |

---

## 6. Verkoopflow (kern) + meldingen (Engels)

### 6.1 Volgorde van checks
```text
1. Storage laden. Als storedTurnips == 0  -> melding "niets opgeslagen".
2. Actuele prijs bepalen (zie §7). Als ZONDAG / no-sale -> melding Sunday.
3. Te verkopen aantal bepalen (alles, of min(1000, storedTurnips)).
4. payout = (u64)amount * (u64)price.   // u64, anti-overflow (0.10)
5. Bank lezen: cur = DecryptValue(&player->BankAmount).
   Als !CanAddToBank(cur, payout, 999'999'999) -> melding "bank limit".
6. BEVESTIGINGSMELDING tonen (prijs per turnip + totaal). Yes/No.
7. Bij Yes: EncryptValue(&player->BankAmount, cur + payout);
            storedTurnips -= amount; storage opslaan (tmp -> verify -> .bak).
   Bij No : niets wijzigen.
```
Belangrijk: turnips pas aftrekken **na** een geslaagde bankupdate (geen "geld weg, turnips ook weg").

### 6.2 Bevestigingsmelding (DialogYesNo)
> Toont expliciet de prijs per turnip, zoals gevraagd. `%u`/`%s` via `Utils::Format`.

**Sell All:**
```
Sell all 4,200 turnips at 132 bells each?

Total payout: 554,400 bells
This will be added to your bank (ABD).

Sell now?            [ Yes ]   [ No ]
```

**Sell 1,000 (batch):**
```
Sell 1,000 turnips at 132 bells each?

Total payout: 132,000 bells
This will be added to your bank (ABD).

Sell now?            [ Yes ]   [ No ]
```

Implementatie (CTRPF, zoals `badges()`):
```cpp
std::string msg = Utils::Format(
    "Sell %s turnips at %u bells each?\n\n"
    "Total payout: %s bells\n"
    "This will be added to your bank (ABD).\n\n"
    "Sell now?",
    FormatThousands(amount).c_str(), price, FormatThousands(payout).c_str());

bool ok = MessageBox(msg, DialogType::DialogYesNo).SetClear(ClearScreen::Top)();
if (!ok) return;   // gebruiker koos No
```

### 6.3 Zondag / no-sale-melding (info-box)
```
Re-Tail isn't buying turnips today.

It's Sunday - Reese only buys turnips
Monday through Saturday.
(On Sunday, Joan sells turnips instead.)

Come back tomorrow!
```
```cpp
MessageBox(
  "Re-Tail isn't buying turnips today.\n\n"
  "It's Sunday - Reese only buys turnips\n"
  "Monday through Saturday.\n"
  "(On Sunday, Joan sells turnips instead.)\n\n"
  "Come back tomorrow!"
).SetClear(ClearScreen::Top)();
return;
```

### 6.4 Overige nette meldingen (Engels)
**Niets opgeslagen:**
```
You have no turnips stored in the Turnip Bank.
Deposit some turnips first!
```
**Banklimiet zou overschreden worden (0.10):**
```
This sale would exceed the bank limit
(999,999,999 bells).

Your turnips were NOT sold.
Withdraw or spend some bells, then try again.
```
**Deposit-bevestiging:**
```
Deposited 1,250 turnips.
Turnip Bank total: 5,450 turnips.
```

---

## 7. Actuele prijs bepalen (Fase 0 / 0.8)

```cpp
u16 GetCurrentRetailTurnipPrice(bool& isSunday) {
    ACNL_TownData* town = Town::GetSaveData();
    int weekday;  // 0=Mon .. 5=Sat, 6=Sun   <- uit town->CurrentTime
    bool pm;      // >= 12:00                 <- uit town->CurrentTime
    DeriveWeekdayAndHalf(town->CurrentTime, weekday, pm);
    if (weekday == 6) { isSunday = true; return 0; }
    isSunday = false;
    int idx = PriceIndex(weekday, pm);        // layout A of B (live te bevestigen)
    return (u16)Game::DecryptValue(&town->TurnipPrices[idx]);
}
```
- **Decode bewezen** op een echte save (6/6 geld-velden valid). De *plugin* gebruikt de game-functie
  `Game::DecryptValue` (geen eigen crypto nodig); het Python-algoritme is alleen voor offline-analyse.
- **`PriceIndex` layout (A vs B)** en **`DeriveWeekdayAndHalf`** uit `CurrentTime` = de open live-checks (§10).
  Beide lezingen lezen dezelfde 12 waarden; alleen de dag/AM-PM-toewijzing verschilt.

---

## 8. Regio & speler (Fase 0 / 0.4, 0.5)

- Werk consequent met de **actieve speler** (`Player::GetSaveData()`) voor bank + inventory, en
  `Town::GetSaveData()` voor prijzen. Storage gekeyed op `TitleID + TID + PID` zodat speler 1–4 en
  regio's niet door elkaar lopen.
- Geen losse hardcoded adressen: bank/inventory via structs (regio-onafhankelijk), eventuele
  functie-adressen via de `Address`-laag (`ADDRESSES[][8]`).

---

## 9. Veiligheid

- Vóór elke schrijf-actie op de save: leun op de bestaande auto-backup (`SaveBackupManager`, 0.12),
  of trigger expliciet een backup vóór de eerste verkoop.
- Bank uitsluitend via `Encrypt/DecryptValue`. Berekening in u64. Turnips pas aftrekken na succes.
- Item-writes alleen op slot 0..15 met `Item::isValid()`; lock-byte resetten bij leegmaken.

---

## 10. Afhankelijkheid: live-checks (1 sessie, 3DS of emulator)

Het plan is bouwbaar; deze punten bepalen alleen exacte constanten/gedrag:
1. **0.8a** — dag-index layout A (`[0-5]=AM,[6-11]=PM`) vs B (interleaved). → `PriceIndex()`.
2. **0.8b** — weekday + AM/PM-grens afleiden uit `CurrentTime`. → `DeriveWeekdayAndHalf()`.
3. **0.7** — bevestigen dat turnip-`Flags`=0 en ID = bundle-grootte.
4. **0.9** — `BankAmount` blijft persistent na save + reboot.

Aanrader: bouw eerst de **read-only diagnostics** (§11, milestone M1) zodat deze 4 in één keer afvinkt.

---

## 11. Implementatie-milestones

| Milestone | Inhoud | Live nodig? |
|---|---|---|
| **M1 — Scaffold + diagnostics** | Eigen menu-folder; storage `.dat` lezen/schrijven; **View Turnip Bank** (read-only: toont pockets-turnips, opgeslagen totaal, ruwe + gedecodeerde prijzen, afgeleide weekday/AM-PM) | nee (draaien wel) |
| **M2 — Deposit** | Pockets scannen, optellen bij storage, slots leegmaken (`0x7FFE`) | nee |
| **M3 — Sell** | Prijs bepalen, **Sunday-check**, **bevestigingsmelding**, anti-overflow, bank-update, storage-aftrek; Sell All + Sell 1,000 | nee |
| **M4 — Robuustheid** | Regio/speler-keying, `.bak`-fallback, edge cases, Engelse copy finaliseren | nee |
| **M5 — Validatie** | De 4 live-checks (§10) met M1-diagnostics afvinken; constanten vastzetten | **ja** |

M1–M4 zijn nu te bouwen zonder hardware (en te compileren met de werkende toolchain). M5 vinkt de
laatste onzekerheden af. Daarna is v1 production-ready.

---

## 12. Open productbeslissingen
- Eigen plugin (gestripte build, eigen menu-hotkey/branding) **of** folder binnen Vapecord? (v1: folder.)
- Extra batch-groottes naast 1.000 (bijv. 100 / 10.000)?
- Rotte turnips (`0x228D`): negeren bij deposit, of apart melden ("These turnips have spoiled")?
