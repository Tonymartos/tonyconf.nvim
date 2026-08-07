#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh — Instala tonyconf.nvim via descarga directa del repo
#
# Uso rapido:
#   curl -fsSL https://raw.githubusercontent.com/Tonymartos/tonyconf.nvim/main/bootstrap.sh | bash
#
# Con flags:
#   curl -fsSL https://raw.githubusercontent.com/Tonymartos/tonyconf.nvim/main/bootstrap.sh | bash -s -- --base --with-fonts=FiraCode
#
# Alternativa manual si el pipe falla:
#   curl -L -o /tmp/tonyconf.tar.gz https://github.com/Tonymartos/tonyconf.nvim/archive/refs/heads/main.tar.gz
#   tar xzf /tmp/tonyconf.tar.gz -C /tmp
#   /tmp/tonyconf.nvim-main/install.sh

TMP_DIR="/tmp/tonyconf_$$"
TAR_URL="https://github.com/Tonymartos/tonyconf.nvim/archive/refs/heads/main.tar.gz"

echo ""
echo "  tonyconf.nvim - Bootstrap"
echo "  ========================="
echo ""

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "  Descargando repo..."
curl -fsSL --progress-bar -o "$TMP_DIR/tonyconf.tar.gz" "$TAR_URL" || {
  echo "  ERROR: No se pudo descargar el repo. Prueba la alternativa manual."
  exit 1
}

tar xzf "$TMP_DIR/tonyconf.tar.gz" --strip-components=1 -C "$TMP_DIR"
rm -f "$TMP_DIR/tonyconf.tar.gz"

if [ -r /dev/tty ]; then
  exec < /dev/tty
fi

"$TMP_DIR/install.sh" "$@"
rm -rf "$TMP_DIR"
