# ACNL Turnip Bank — Research (Fase 0)

Resultaten van het onderzoeksplan in [`../fases.md`](../fases.md).
Basis: clone van `RedShyGuy/Vapecord-ACNL-Plugin` @ `v3.3.1` (`eed9d59`) in `D:\jelle\Vapecord-ACNL-Plugin`.

## Status per stap

| Stap | Onderwerp | Status | Document |
|---|---|---|---|
| 0.1 | Buildomgeving | ✅ klaar — `.3gx` gebouwd (2026-06-25) | [0.1-build-setup.md](0.1-build-setup.md) |
| 0.2 | Projectstructuur | ✅ klaar | [0.2-projectstructuur.md](0.2-projectstructuur.md) |
| 0.3 | Menu/hotkey | ✅ klaar | [0.3-menu-hotkey.md](0.3-menu-hotkey.md) |
| 0.4 | Region/version | ✅ klaar | [0.4-region-version.md](0.4-region-version.md) |
| 0.5 | Current player | ✅ klaar | [0.5-current-player.md](0.5-current-player.md) |
| 0.6 | Inventory/pockets | ✅ klaar (1 hardware-detail open) | [0.6-inventory-pockets.md](0.6-inventory-pockets.md) |
| 0.7 | Turnip item-ID/stack | ✅ klaar (aantal=ID; 1 live-check) | [0.7-turnip-item-data.md](0.7-turnip-item-data.md) |
| 0.8 | Re-Tail price table | ✅ decode bewezen op echte save (dag-label = 1 live-check) | [0.8-retail-price-table.md](0.8-retail-price-table.md) |
| 0.9 | Bank/ABD balance | ✅ mechanisme klaar (reboot-test open) | [0.9-bank-abd-balance.md](0.9-bank-abd-balance.md) |
| 0.10 | Anti-overflow | ✅ klaar | [0.10-anti-overflow.md](0.10-anti-overflow.md) |
| 0.11 | Plugin storage (SD) | ✅ klaar | [0.11-plugin-storage.md](0.11-plugin-storage.md) |
| 0.12 | Backup/testprotocol | ✅ code-deel klaar (testmatrix op hardware) | [0.12-backup-testprotocol.md](0.12-backup-testprotocol.md) |
| 0.13 | Samenvoegen | 🟡 doorlopend (deze index) | dit bestand |

## Kernconclusie

De Vapecord-codebase bevat **nagenoeg alle bouwstenen** voor de Turnip Bank als herbruikbare API:

- **Bank/geld:** `ACNL_Player::BankAmount` (versleutelde `EncVal`), lezen/schrijven via
  `Game::Decrypt/EncryptValue`. Max **999.999.999** bells.
- **Turnip-prijzen:** `ACNL_TownData::TurnipPrices[12]` @0x6ADE0, versleutelde `EncVal`; decode bewezen
  op echte save (6/6 geld-velden valid). Turnip-aantal zit in het **item-ID** (0x2283=10 .. 0x228C=100).
- **Inventory:** `Inventory::ReadSlot/WriteSlot/GetNextItem`, 16 pocket-slots, `Item = {u16 ID, u16 Flags}`,
  turnip-ID-range `0x2283–0x228C` (+ spoiled `0x228D`).
- **Regio-laag:** `Address::LoadRegion()` (TitleID) + `ADDRESSES[][8]`, 8 regio's incl. Welcome amiibo + romhack.
- **Speler:** `Player::GetSaveData()` (actief) / `(0..3)`; bank + inventory per speler, turnip-prijs per town.
- **SD-I/O:** CTRPF `File`/`Directory` (bewezen binaire struct-I/O in `Plugin_Color.cpp`).
- **Backup:** `SaveBackupManager` (Checkpoint), auto-backup al actief.

## Belangrijkste vondst / risico
Geldwaarden zijn **secure values** (u64, versleuteld). Direct schrijven corrumpeert; altijd via de
encrypt/decrypt-helpers. Dit was een open vraag in het plan en is nu opgelost.

## Resterend werk — alles samengebald tot ÉÉN korte live-sessie (3DS of emulator)
Geen van deze blokkeert het Fase 1-conceptplan; het zijn finale bevestigingen:
1. ~~**0.1** Build~~ ✅ klaar · ~~**0.7** turnip-codering~~ ✅ (aantal=ID) · ~~**0.8** prijs-decode~~ ✅ bewezen.
2. **0.7 live** — turnips in pockets leggen, checken dat `Flags` 0 blijft en ID = bundle-grootte.
3. **0.8 live** — dag/AM-PM-index (layout A vs B) + weekday/uur uit `CurrentTime`, matchen met Reese.
4. **0.9 live** — reboot-persistentie van `BankAmount` na save.
5. **0.12 live** — testmatrix over regio's + spelers.

> Deze 4 live-checks kunnen in één sessie, eventueel met een vooraf ingebouwde read-only diagnostics-feature.

## Klaar voor Fase 1 (ontwikkelplan)?
- [x] **Klaar voor een Fase 1-conceptplan.** Build werkt, volledige API + offsets + decode bekend en
      grotendeels op een echte save bevestigd. Geen open *research*-blokkades meer.
- [ ] Volledig "production-ready" pas na de bovenstaande 4 live-checks (labeling/persistentie/regio-matrix).
