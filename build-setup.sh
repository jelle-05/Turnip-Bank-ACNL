#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Turnip-Bank-ACNL — build setup (Stap 0.1)
# Bouwt de custom LibCTRPF en daarna de Vapecord-plugin (.3gx).
#
# DRAAI DIT IN DE devkitPro MSYS2-SHELL:
#   C:/devkitPro/msys2/msys2_shell.bat
# en dan:  /d/jelle/Vapecord-ACNL-Plugin/Turnip-Bank-ACNL/build-setup.sh
# ---------------------------------------------------------------------------
set -euo pipefail

: "${DEVKITPRO:?DEVKITPRO is niet gezet — draai dit script in de devkitPro MSYS2-shell}"
: "${DEVKITARM:?DEVKITARM is niet gezet — draai dit script in de devkitPro MSYS2-shell}"

# devkitARM-compiler en devkitPro-tools (3gxtool) op PATH zetten
export PATH="$DEVKITARM/bin:$DEVKITPRO/tools/bin:$PATH"

# Paden automatisch afleiden t.o.v. dit script:
#   <root>/Vapecord-ACNL-Plugin/Turnip-Bank-ACNL/build-setup.sh  (dit script)
#   <root>/Vapecord-ACNL-Plugin/                                 -> VAPE
#   <root>/libctrpfforvapecord/                                  -> LIB
# Overschrijf desgewenst met de env-vars VAPE / LIB.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAPE="${VAPE:-$(dirname "$SCRIPT_DIR")}"
LIB="${LIB:-$(dirname "$VAPE")/libctrpfforvapecord}"
[ -d "$LIB" ]  || { echo "FOUT: LibCTRPF niet gevonden op $LIB (zet env-var LIB)"; exit 1; }
[ -f "$VAPE/Makefile" ] || { echo "FOUT: Vapecord-repo niet gevonden op $VAPE (zet env-var VAPE)"; exit 1; }

echo "== Omgeving =="
echo "DEVKITPRO = $DEVKITPRO"
echo "DEVKITARM = $DEVKITARM"
command -v make                >/dev/null || { echo "FOUT: 'make' ontbreekt"; exit 1; }
[ -x "$DEVKITARM/bin/arm-none-eabi-gcc" ] || { echo "FOUT: devkitARM gcc ontbreekt (3ds-dev geïnstalleerd?)"; exit 1; }
command -v 3gxtool             >/dev/null || { echo "FOUT: 3gxtool ontbreekt"; exit 1; }

echo
echo "== Stap 1/2: LibCTRPF bouwen + installeren naar \$DEVKITPRO/libctrpfforvapecord =="
# De root-Makefile doet: cd Library && make install  (bouwt libctrpf.a/libctrpfd.a en kopieert include+lib)
make -C "$LIB"

echo
echo "== Verificatie lib-installatie =="
ls -lh "$DEVKITPRO/libctrpfforvapecord/lib/"libctrpf*.a
ls -d  "$DEVKITPRO/libctrpfforvapecord/include/CTRPluginFramework" >/dev/null && echo "include OK"

echo
echo "== Stap 2/2: Vapecord-plugin bouwen (DEVMODE=1) =="
make -C "$VAPE" DEVMODE=1 -j"$(nproc)"

echo
echo "== Resultaat =="
ls -lh "$VAPE"/*.3gx && echo "BUILD GESLAAGD ✅"
