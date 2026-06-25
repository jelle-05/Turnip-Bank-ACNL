# Prompt voor Claude Code — project voortzetten

Open Claude Code in de **`Turnip-Bank-ACNL`**-map (binnen de Vapecord-clone) en plak het blok hieronder
als eerste bericht. Het oriënteert Claude en laat het direct verder werken.

> Tip: zorg dat de drie repos gecloned zijn volgens `HANDOFF.md §2-3` vóór je begint
> (Claude kan dit ook voor je doen als ze ontbreken).

---

```text
Je pakt een bestaand project op: een Animal Crossing: New Leaf (3DS) CTRPluginFramework-plugin
genaamd "Turnip Bank". De research- en planningsfase is af; jouw taak is de plugin bouwen.

LEES EERST DEZE DOCS (in deze repo), in volgorde:
1. HANDOFF.md            — omgeving opzetten + repo-layout
2. research/README.md    — status van alle Fase 0-research + technische ankers
3. fase1-conceptplan.md  — het ontwikkelplan met milestones M1–M5 en de exacte Engelse meldingen

PROJECT IN HET KORT:
De speler stort turnips uit de pockets in een eigen SD-storage (.dat), de plugin leest de actuele
Re-Tail-prijs, en verkoopt opgeslagen turnips (alles of per 1000) met een Engelse bevestigingsmelding
("Sell N turnips at X bells each? ... Sell now?"). De opbrengst gaat veilig naar de bank (ABD) met
anti-overflow. Nette Engelse melding als het zondag is (geen verkoop). Regio- en speler-bewust.

HUIDIGE STATUS:
- Build WERKT: build-setup.sh bouwt de custom LibCTRPF + de plugin tot Vapecord_Public.3gx.
  Toolchain = devkitPro (3ds-dev) + 3gxtool (pacman, thepixellizeross) + custom libctrpf
  (branch 'develop', met -Werror -> -Wno-error in Library/Makefile). Details in HANDOFF.md.
- Fase 0-research is 100% af. EncVal secure-value decode is BEWEZEN op een echte save.
- Plugincode is NOG NIET geschreven. Volgende stap = Milestone M1.

REPO-LAYOUT (deze repo zit IN de Vapecord-clone):
  <root>/Vapecord-ACNL-Plugin/            <- RedShyGuy clone @ v3.3.1 (DE PLUGINCODE / build target)
  <root>/Vapecord-ACNL-Plugin/Turnip-Bank-ACNL/  <- DEZE repo (plan/research/scripts)
  <root>/libctrpfforvapecord/            <- custom CTRPF-lib (develop + -Werror fix)
Nieuwe plugincode komt in Vapecord-ACNL-Plugin/src/features/TurnipBank/ + registratie in
src/platform/ctrpf/MenuCreate.cpp (zie conceptplan §2).

JOUW TAAK:
1. Verifieer de build-omgeving (HANDOFF.md). Clone ontbrekende repos. Draai build-setup.sh en
   bevestig dat .3gx bouwt VOORDAT je code toevoegt.
2. Implementeer daarna Milestone M1: eigen MenuFolder "Turnip Bank" + storage .dat lezen/schrijven
   + read-only "View Turnip Bank" (toont pockets-turnips, opgeslagen totaal, ruwe + gedecodeerde
   prijzen, afgeleide weekday/AM-PM).
3. Bouw na elke milestone opnieuw. M1–M4 hebben GEEN 3DS nodig (compileren prima). M5 = live-checks
   op 3DS/emulator (zie conceptplan §10).

TECHNISCHE ANKERS (snel):
- Bank lezen/schrijven: Game::DecryptValue/EncryptValue (secure value u64 — NOOIT direct schrijven).
- Turnip-prijzen: ACNL_TownData::TurnipPrices[12] @0x6ADE0 (versleuteld). Town::GetSaveData().
- Turnip-aantal zit in het ITEM-ID: 0x2283=10 .. 0x228C=100; 0x228D=rot. Flags telt NIET mee.
- Lege inventory-slot = Item{0x7FFE, 0}. 16 pocket-slots. Inventory::ReadSlot/WriteSlot/GetNextItem.
- Actieve speler: Player::GetSaveData(). Bank+inventory per speler; prijzen per town.
- Regio: Address::LoadRegion() + ADDRESSES[][8]. Max bank = 999.999.999 bells.
- SD-I/O: CTRPF File/Directory (binaire struct-I/O, voorbeeld in Plugin_Color.cpp).

GUARDRAILS:
- Geld is versleuteld -> altijd via Game::Encrypt/DecryptValue.
- Twee onbekenden GEGUARD/CONFIGUREERBAAR houden (niet hardcoden): de turnip-prijs-index-layout
  (A: [0-5]=AM,[6-11]=PM  vs  B: interleaved) en de weekday/AM-PM-afleiding uit CurrentTime.
  Bouw ze achter PriceIndex() / DeriveWeekdayAndHalf(). Definitief vastzetten pas na de live-check.
- Alle gebruiker-gerichte meldingen in het ENGELS (exacte copy staat in conceptplan §6).
- garden_plus.dat NOOIT committen (privacy; staat in .gitignore).
- Vraag bevestiging vóór committen/pushen.

Begin met de docs lezen + de build bevestigen, en stel dan je M1-plan voor.
```

---

## Bij twijfel / problemen
- Build faalt op `-Werror`? → `libctrpfforvapecord/Library/Makefile` regel ~80: `-Werror` → `-Wno-error`.
- `3gxtool` ontbreekt? → `pacman -S 3gxtool` na de thepixellizeross-db toe te voegen (HANDOFF.md §4).
- `.3gx` op de 3DS plaatsen → `sd:/luma/plugins/<TitleID>/Vapecord_Public.3gx` + Plugin Loader aan in Rosalina.
