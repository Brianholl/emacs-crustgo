#!/usr/bin/env bash
#
# install-esp32.sh — deja listo el desarrollo ESP32 para crustgo en
# Arch Linux / CachyOS (pacman). Tres cadenas:
#
#   C/C++  → ESP-IDF v5            (idf.py)
#   Rust   → espup + espflash      (toolchain 'esp' para Xtensa)
#   Go     → TinyGo + esptool      (solo ESP32 clásico)
#
# Uso:
#   ./install-esp32.sh            # instala las tres
#   ./install-esp32.sh c rust     # solo las que listes (c | rust | go)
#
# Variables:
#   IDF_BRANCH   rama de ESP-IDF a clonar   (def: release/v5.3)
#   IDF_TARGETS  chips a instalar           (def: esp32,esp32s3)
#
set -euo pipefail

IDF_BRANCH="${IDF_BRANCH:-release/v5.3}"
IDF_TARGETS="${IDF_TARGETS:-esp32,esp32s3}"
ESP_DIR="$HOME/esp"
IDF_DIR="$ESP_DIR/esp-idf"

# ── Qué componentes instalar ──────────────────────────────────
do_c=0; do_rust=0; do_go=0
if [ "$#" -eq 0 ]; then
    do_c=1; do_rust=1; do_go=1
else
    for a in "$@"; do
        case "$a" in
            c|cpp|c++|idf) do_c=1 ;;
            rust|rs)       do_rust=1 ;;
            go|tinygo)     do_go=1 ;;
            *) echo "!! componente desconocido: $a (usá: c | rust | go)"; exit 1 ;;
        esac
    done
fi

echo "==> install-esp32  (C=$do_c  Rust=$do_rust  Go=$do_go)"
echo "    IDF_BRANCH=$IDF_BRANCH  IDF_TARGETS=$IDF_TARGETS"
echo

if ! command -v pacman >/dev/null 2>&1; then
    echo "!! Este script es para Arch/CachyOS (pacman). Salgo."
    exit 1
fi

have() { command -v "$1" >/dev/null 2>&1; }

# ── 1. Prerrequisitos del sistema (un solo pacman) ────────────
PKGS=(git wget flex bison gperf python cmake ninja ccache dfu-util libusb)
# Rust necesita rustup; si no hay ni rustup ni cargo, lo sumamos.
if [ "$do_rust" -eq 1 ] && ! have rustup && ! have cargo; then
    PKGS+=(rustup)
fi
echo "==> Instalando prerrequisitos con pacman: ${PKGS[*]}"
echo "    (te va a pedir la contraseña de sudo)"
sudo pacman -S --needed "${PKGS[@]}"

# ── 2. Acceso al puerto serie (grupo uucp en Arch) ────────────
if ! id -nG "$USER" | grep -qw uucp; then
    echo "==> Agregando $USER al grupo 'uucp' (acceso a /dev/ttyUSB* y /dev/ttyACM*)"
    sudo usermod -aG uucp "$USER"
    echo "    ⚠️  Cerrá sesión y volvé a entrar para que tome efecto."
fi

mkdir -p ~/.config/fish/functions

# Helper: agrega un alias a bash/zsh si no está
add_alias() {  # $1=nombre  $2=comando
    local cmd="alias $1=\"$2\""
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        [ -f "$rc" ] && { grep -q "alias $1=" "$rc" || echo "$cmd" >> "$rc"; }
    done
}

# ──────────────────────────────────────────────────────────────
# 3. C / C++ — ESP-IDF
# ──────────────────────────────────────────────────────────────
if [ "$do_c" -eq 1 ]; then
    echo
    echo "==> [C] ESP-IDF ($IDF_BRANCH)"
    mkdir -p "$ESP_DIR"
    if [ -d "$IDF_DIR/.git" ]; then
        echo "    Ya existe $IDF_DIR — no lo toco (para actualizar: cd ahí y git pull)."
    else
        git clone -b "$IDF_BRANCH" --depth 1 --shallow-submodules --recursive \
            https://github.com/espressif/esp-idf.git "$IDF_DIR"
    fi
    echo "==> [C] Instalando toolchains de IDF para: $IDF_TARGETS"
    ( cd "$IDF_DIR" && ./install.sh "$IDF_TARGETS" )

    # Atajo para cargar el entorno en cada terminal
    add_alias get_idf ". $IDF_DIR/export.sh"
    if [ -f "$IDF_DIR/export.fish" ]; then
        cat > ~/.config/fish/functions/get_idf.fish <<EOF
function get_idf --description 'cargar entorno ESP-IDF'
    source $IDF_DIR/export.fish
end
EOF
    fi
    echo "    ✓ Atajo 'get_idf' instalado (carga el entorno de ESP-IDF)."
fi

# ──────────────────────────────────────────────────────────────
# 4. Rust — espup + espflash
# ──────────────────────────────────────────────────────────────
if [ "$do_rust" -eq 1 ]; then
    echo
    echo "==> [Rust] espup / espflash / ldproxy"
    if ! have cargo; then
        # recién instalamos rustup por pacman → fijamos un toolchain base
        rustup default stable
    fi
    # Herramientas (cargo install es idempotente; saltamos si ya están)
    have espup    || cargo install espup
    have espflash || cargo install espflash
    have ldproxy  || cargo install ldproxy   # necesario para builds 'std' (esp-idf-hal)

    if [ ! -f "$HOME/export-esp.sh" ]; then
        echo "==> [Rust] espup install — instala el toolchain 'esp' (Xtensa)"
        espup install
    else
        echo "    Ya existe ~/export-esp.sh — el toolchain 'esp' ya está. (espup update para actualizar)"
    fi

    # Atajo get_esp (solo hace falta para builds 'std'/esp-idf-hal; el no_std
    # de esp-hal anda sin esto, vía rust-toolchain.toml + build-std).
    add_alias get_esp ". $HOME/export-esp.sh"
    if [ -f "$HOME/export-esp.sh" ]; then
        {
            echo "function get_esp --description 'env del toolchain esp (Rust Xtensa)'"
            # traduce 'export VAR=val' → 'set -gx VAR val' (formato simple de espup)
            sed -E 's/^export ([A-Za-z0-9_]+)="?([^"]*)"?.*/    set -gx \1 \2/' \
                "$HOME/export-esp.sh" | grep '^    set -gx'
            echo "end"
        } > ~/.config/fish/functions/get_esp.fish
    fi
    echo "    ✓ espup/espflash listos. Atajo 'get_esp' instalado."
fi

# ──────────────────────────────────────────────────────────────
# 5. Go — TinyGo (AUR) + esptool
# ──────────────────────────────────────────────────────────────
if [ "$do_go" -eq 1 ]; then
    echo
    echo "==> [Go] TinyGo + esptool"
    have go || sudo pacman -S --needed go
    # esptool: necesario para flashear ESP32 con TinyGo
    sudo pacman -S --needed esptool 2>/dev/null || \
        echo "!!  No pude instalar 'esptool' por pacman; instalalo a mano si vas a usar Go."

    if have tinygo; then
        echo "    TinyGo ya está instalado."
    else
        AUR=""
        for h in paru yay; do have "$h" && AUR="$h" && break; done
        if [ -n "$AUR" ]; then
            echo "==> [Go] Instalando tinygo-bin desde AUR con $AUR"
            "$AUR" -S --needed tinygo-bin
        else
            echo "!!  TinyGo está en AUR y no encontré paru/yay."
            echo "    Instalá un helper (p.ej. paru) y luego:  paru -S tinygo-bin"
            echo "    O bajalo manual de https://github.com/tinygo-org/tinygo/releases"
        fi
    fi
    echo "    ℹ️  Recordá: TinyGo soporta el ESP32 clásico, NO el ESP32-S3."
fi

# ──────────────────────────────────────────────────────────────
# 6. Verificación
# ──────────────────────────────────────────────────────────────
echo
echo "==> Verificación:"
check() { if command -v "$1" >/dev/null 2>&1; then printf "    ✓ %s\n" "$1"; else printf "    ✗ %s  (falta)\n" "$1"; fi; }

if [ "$do_c" -eq 1 ]; then
    if [ -f "$IDF_DIR/export.sh" ] && ( . "$IDF_DIR/export.sh" >/dev/null 2>&1 && command -v idf.py >/dev/null 2>&1 ); then
        printf "    ✓ idf.py  (cargá el entorno con 'get_idf')\n"
    else
        printf "    ✗ idf.py  (revisá la instalación de ESP-IDF)\n"
    fi
fi
if [ "$do_rust" -eq 1 ]; then check espup; check espflash; fi
if [ "$do_go" -eq 1 ]; then check tinygo; check esptool; fi
if id -nG "$USER" | grep -qw uucp; then printf "    ✓ grupo uucp (puerto serie)\n"; else printf "    ~ grupo uucp — re-logueá para activarlo\n"; fi

echo
echo "==> Listo. Para empezar:"
[ "$do_c"   -eq 1 ] && echo "    C    →  get_idf;  cd examples/esp32/c-idf-blink;  idf.py set-target esp32s3"
[ "$do_rust" -eq 1 ] && echo "    Rust →  cd examples/esp32/rust-blink;  cargo run --release   (o F6 en crustgo)"
[ "$do_go"  -eq 1 ] && echo "    Go   →  cd examples/esp32/tinygo-blink;  tinygo flash -target=esp32 -monitor ."
echo "    (en crustgo, F6 = flashear)"
