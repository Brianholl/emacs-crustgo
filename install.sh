#!/usr/bin/env bash
#
# install.sh — instala todo lo que necesita emacs-crustgo.
#   1. Dependencias del sistema (emacs, gcc, g++, gdb, make, clangd,
#      rust + rust-analyzer, go + gopls)
#   2. El debugger de Go (delve / dlv) vía 'go install'
#   3. La función de fish 'crustgo' (+ alias bash/zsh)
#   4. Los paquetes de Emacs (elpa) en el directorio de crustgo
#
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> emacs-crustgo — instalación (C · C++ · Rust · Go)"
echo "    directorio: $DIR"
echo

# ── 1. Dependencias del sistema ───────────────────────────────
if command -v pacman >/dev/null 2>&1; then
    echo "==> Instalando dependencias con pacman..."
    echo "    (Se te pedirá tu contraseña de sudo para pacman)"
    #   clangd → clang · rust-analyzer viene con rustup/rust · gopls → en 'go' o aparte
    sudo pacman -S --needed emacs gcc gdb make clang rust rust-analyzer go gopls
else
    echo "!!  No se encontró pacman. Instalá a mano:"
    echo "    emacs gcc g++ gdb make clangd  rust rust-analyzer  go gopls"
fi

# ── 2. Delve (debugger de Go) ─────────────────────────────────
if command -v go >/dev/null 2>&1 && ! command -v dlv >/dev/null 2>&1; then
    echo
    echo "==> Instalando delve (dlv) — debugger de Go — con 'go install'..."
    go install github.com/go-delve/delve/cmd/dlv@latest || \
        echo "!!  No se pudo instalar dlv; instalalo a mano si vas a depurar Go."
    echo "    (asegurate de tener \$(go env GOPATH)/bin en tu PATH)"
fi

# Verificación
echo
echo "==> Verificando herramientas:"
missing=0
for b in emacs gcc g++ gdb make clangd rustc cargo rust-analyzer go gopls; do
    if command -v "$b" >/dev/null 2>&1; then
        printf "    ✓ %s\n" "$b"
    else
        printf "    ✗ %s  (FALTA)\n" "$b"
        missing=1
    fi
done
# dlv es opcional (sólo para depurar Go)
if command -v dlv >/dev/null 2>&1; then
    printf "    ✓ dlv\n"
else
    printf "    ~ dlv  (opcional — sólo para debug de Go)\n"
fi
[ "$missing" -eq 1 ] && echo "!!  Faltan herramientas; instalalas antes de seguir."

# ── 3. Función de fish y alias bash/zsh ───────────────────────
FISH_FN="$HOME/.config/fish/functions/crustgo.fish"
echo
echo "==> Instalando función de fish 'crustgo' en $FISH_FN"
mkdir -p "$(dirname "$FISH_FN")"
cat > "$FISH_FN" <<EOF
function crustgo --description 'emacs-crustgo — Emacs para C, C++, Rust y Go'
    emacs --init-directory $DIR/ \$argv
end
EOF

echo "==> Añadiendo alias 'crustgo' para Bash y Zsh..."
ALIAS_CMD="alias crustgo=\"emacs --init-directory $DIR/\""
if [ -f "$HOME/.bashrc" ]; then
    grep -q "alias crustgo=" "$HOME/.bashrc" || echo "$ALIAS_CMD" >> "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ]; then
    grep -q "alias crustgo=" "$HOME/.zshrc" || echo "$ALIAS_CMD" >> "$HOME/.zshrc"
fi

# ── 4. Paquetes de Emacs (elpa) ───────────────────────────────
echo
echo "==> Descargando paquetes de Emacs (puede tardar la primera vez)..."
emacs -Q --batch \
  --eval "(progn (setq user-emacs-directory \"$DIR/\") (setq package-user-dir (expand-file-name \"elpa\" user-emacs-directory)))" \
  -l "$DIR/init.el" \
  --eval '(message "==> %d paquetes instalados en %s" (length package-activated-list) package-user-dir)'

echo
echo "==> Listo. Abrí una terminal nueva y ejecutá:  crustgo"
echo "    (o: emacs --init-directory $DIR/)"
