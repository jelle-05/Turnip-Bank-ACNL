# Handoff — ACNL Turnip Bank oppakken op een andere computer

Dit document laat je het project op een verse machine reproduceren en verder werken.
Alles is getest op **Windows 10** met de devkitPro MSYS2-shell.

---

## 1. Wat is dit project?

Een eigen Animal Crossing: New Leaf (3DS) plugin, geïnspireerd op Vapecord, die turnips uit de
inventory haalt, opslaat op de SD-kaart, de actuele Re-Tail-prijs leest en de opbrengst veilig naar
de bank (ABD) schrijft.

- **Deze repo** (`jelle-05/Turnip-Bank-ACNL`) = **plan + research + build-scripts**. Géén plugincode.
- De **plugincode** wordt gebouwd in een aparte clone van de Vapecord-repo (zie §3).
- Status: **Fase 0 (research) compleet**, **Fase 1 (conceptplan) geschreven**. Volgende stap = M1 bouwen.

Lees in volgorde:
1. [`fases.md`](fases.md) — het oorspronkelijke researchplan (Fase 0).
2. [`research/README.md`](research/README.md) — status + kernconclusies van alle 13 onderzoeksstappen.
3. [`fase1-conceptplan.md`](fase1-conceptplan.md) — het ontwikkelplan + milestones (M1–M5).

> **Met Claude Code verdergaan?** Open Claude Code in deze map en plak de prompt uit
> [`claude-continue-prompt.md`](claude-continue-prompt.md) — die oriënteert Claude en start M1.

---

## 2. Verwachte mappenstructuur

```
<root>/
├── Vapecord-ACNL-Plugin/            # RedShyGuy clone (de plugincode, build target)
│   └── Turnip-Bank-ACNL/            # DEZE repo (plan/research/scripts)
└── libctrpfforvapecord/             # custom CTRPF-lib (develop-branch + -Werror fix)
```
`build-setup.sh` leidt deze paden automatisch af t.o.v. zichzelf (of via env-vars `VAPE` / `LIB`).

---

## 3. Repos clonen

```bash
cd <root>
# 1) Plugincode (PIN op de geteste versie)
git clone https://github.com/RedShyGuy/Vapecord-ACNL-Plugin.git
cd Vapecord-ACNL-Plugin && git checkout v3.3.1 && cd ..
#    commit: eed9d59 (tag v3.3.1)

# 2) Deze repo (plan/research) — IN de Vapecord-map
cd Vapecord-ACNL-Plugin
git clone https://github.com/jelle-05/Turnip-Bank-ACNL.git
cd ..

# 3) Custom CTRPF-library (let op: branch heet 'develop', niet 'dev')
git clone --branch develop https://gitlab.com/RedShyGuy/ctr-plugin-framework-for-vapecord.git libctrpfforvapecord
```

---

## 4. Toolchain installeren (geen 3DS nodig)

1. **devkitPro** — installer: https://github.com/devkitPro/installer/releases (getest: v3.0.3).
   Dubbelklik en laat **"3DS Development"** aangevinkt. Installeert standaard naar `C:\devkitPro`.

2. **3gxtool** (zit NIET standaard in devkitPro). Open `C:\devkitPro\msys2\msys2_shell.bat` en:
   ```sh
   # ThePixellizerOSS pacman-database toevoegen (eenmalig):
   printf '\n[thepixellizeross-lib]\nServer = https://thepixellizeross.gitlab.io/packages/any\nSigLevel = Optional\n' >> /etc/pacman.conf
   printf '\n[thepixellizeross-win]\nServer = https://thepixellizeross.gitlab.io/packages/x86_64/win\nSigLevel = Optional\n' >> /etc/pacman.conf
   pacman -Sy
   pacman -S --noconfirm 3gxtool
   ```

3. **Custom-lib build-fix** (nieuwere gcc is strenger met `-Werror`):
   in `libctrpfforvapecord/Library/Makefile`, regel ~80, zet `-Werror` → `-Wno-error`.
   ```
   CFLAGS := -Wall -Wno-error -Wno-psabi -mword-relocations \
   ```
   > Dit raakt alleen de dependency-build, niet de Vapecord-plugincode.

---

## 5. Bouwen

In de **devkitPro MSYS2-shell** (`C:\devkitPro\msys2\msys2_shell.bat`):
```sh
bash <root>/Vapecord-ACNL-Plugin/Turnip-Bank-ACNL/build-setup.sh
```
Dit bouwt de lib (→ `$DEVKITPRO/libctrpfforvapecord`) en daarna de plugin
(→ `Vapecord-ACNL-Plugin/Vapecord_Public.3gx`, ~926 KB).

> Draait de shell niet als devkitPro-omgeving? Check `echo $DEVKITPRO` (moet `/opt/devkitpro` zijn).
> Vanuit gewone Git Bash kun je ook: `MSYSTEM=MSYS /c/devkitPro/msys2/usr/bin/bash.exe -lc 'bash .../build-setup.sh'`.

---

## 6. Offline save-analyse (optioneel)

`research/tools/decode_save.py` decodeert geld/bank/turnip-prijzen statisch uit een `garden_plus.dat`
(EncVal secure-value algoritme, bevestigd). Python 3 vereist.

> **Let op:** `garden_plus.dat` wordt **bewust NIET meegecommit** (`.gitignore`) — het kan andermans
> town-data bevatten. Voor analyse zet je zelf een save in deze map en past het pad in het script aan.
> Voor M1–M4 is een save **niet** nodig.

---

## 7. Volgende stap: Milestone M1

Uit [`fase1-conceptplan.md`](fase1-conceptplan.md) §11:
- Eigen `MenuFolder "Turnip Bank"` in `Vapecord-ACNL-Plugin/src/platform/ctrpf/MenuCreate.cpp`.
- Storage `.dat` lezen/schrijven (CTRPF `File`/`Directory`).
- **View Turnip Bank** (read-only diagnostics): toont pockets-turnips, opgeslagen totaal,
  ruwe + gedecodeerde prijzen, en de afgeleide weekday/AM-PM.

M1–M4 zijn bouwbaar **zonder hardware**. M5 = de 4 live-checks (zie conceptplan §10) op 3DS/emulator.

---

## 8. Belangrijkste technische ankers (snelle referentie)

| Onderwerp | Waar |
|---|---|
| Bank lezen/schrijven | `Game::DecryptValue/EncryptValue` (secure value, u64) |
| Turnip-prijzen | `ACNL_TownData::TurnipPrices[12]` @0x6ADE0 (versleuteld) |
| Turnip-aantal | zit in **item-ID** 0x2283(=10)..0x228C(=100); 0x228D = rot |
| Lege inventory-slot | `Item{0x7FFE, 0}` |
| Actieve speler / town | `Player::GetSaveData()` / `Town::GetSaveData()` |
| Regio | `Address::LoadRegion()` + `ADDRESSES[][8]` |
| Max bankwaarde | 999.999.999 bells |
