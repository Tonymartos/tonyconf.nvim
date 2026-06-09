#!/usr/bin/env bash
set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Flags ────────────────────────────────────────────────────────────────────
INSTALL_NVIM=false
UPDATE_NVIM=false
WITH_AI=false
WITH_FONTS=""
DRY_RUN=false
CONFIG_REPO="https://forge.tonymartos.com/tonymartos/tonyconf.nvim.git"

# ── Help ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}tonyconf.nvim - Instalador${NC}

Uso: ./install.sh [flags]

${BOLD}Flags:${NC}
  --install-nvim    Fuerza instalacion de Neovim via curl desde GitHub
  --update-nvim     Actualiza Neovim (solo si se instalo via curl)
  --with-ai         Instala OpenCode y Claude Code
  --with-fonts      Elige una Nerd Font para instalar (por defecto JetBrains Mono)
  --with-fonts=<F>  Instala una Nerd Font especifica (JetBrainsMono, CascadiaCode,
                    FiraCode, Hack, SourceCodePro, UbuntuMono, DejaVuSansMono, Noto, Iosevka)
  --all             Equivale a --with-ai --with-fonts
  --dry-run         Muestra que haria sin ejecutar nada
  -h, --help        Muestra esta ayuda

${BOLD}Ejemplos:${NC}
  ./install.sh                        # Instalacion base minima
  ./install.sh --install-nvim         # Si tu distro no tiene nvim >= 0.10
  ./install.sh --all                  # Instalacion completa para dev
  ./install.sh --update-nvim          # Actualizar nvim instalado via curl
EOF
  exit 0
}

# ── Parsear flags ────────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --install-nvim) INSTALL_NVIM=true ;;
    --update-nvim)  UPDATE_NVIM=true ;;
    --with-ai)      WITH_AI=true ;;
    --with-fonts=*) WITH_FONTS="${arg#*=}" ;;
    --with-fonts)   WITH_FONTS="default" ;;
    --all)          WITH_AI=true; WITH_FONTS="default" ;;
    --dry-run)      DRY_RUN=true ;;
    -h|--help)      usage ;;
    *)
      echo -e "${RED}Flag desconocida: $arg${NC}"
      echo "Usa -h para ver las opciones."
      exit 1
      ;;
  esac
done

# ── Log helpers ──────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }
step()    { echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$*${NC}"; }
run()     { if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${NC} $*"; else "$@"; fi; }

# ── Detectar OS ──────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Linux)
      if command -v pacman &>/dev/null; then
        echo "arch"
      elif command -v apt &>/dev/null; then
        echo "debian"
      elif command -v dnf &>/dev/null; then
        echo "fedora"
      else
        echo "linux-unknown"
      fi
      ;;
    Darwin)
      echo "macos"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

OS_TYPE=$(detect_os)

# ── Instalar dependencias base ───────────────────────────────────────────────
install_deps() {
  step "Instalando dependencias base (git, curl, ripgrep, fd, nodejs, unzip)"

  case "$OS_TYPE" in
    arch)
      run sudo pacman -S --needed --noconfirm git curl ripgrep fd nodejs unzip
      ;;
    debian)
      run sudo apt update -y
      run sudo apt install -y git curl ripgrep fd-find nodejs unzip
      # fd-find binary is called fdfind on Debian
      if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        run mkdir -p ~/.local/bin
        run ln -sf "$(command -v fdfind)" ~/.local/bin/fd
        success "Symlink fd → fdfind creado en ~/.local/bin"
      fi
      ;;
    fedora)
      run sudo dnf install -y git curl ripgrep fd-find nodejs unzip
      ;;
    macos)
      info "Instalando via Homebrew. Si no tienes brew: https://brew.sh"
      if ! command -v brew &>/dev/null; then
        error "Homebrew no encontrado. Instalalo desde https://brew.sh"
        exit 1
      fi
      run brew install git curl ripgrep fd node
      ;;    
    *)
      echo -e "${RED}[ERROR]${NC} SO no soportado: $OS_TYPE."
      echo "  Linux: Arch (pacman), Debian/Ubuntu (apt), Fedora (dnf)"
      echo "  macOS: Homebrew (brew)"
      echo "  Instala manualmente: git, curl, ripgrep, fd, node, unzip"
      exit 1
      ;;
  esac

  success "Dependencias base instaladas"

  # Asegurar ~/.local/bin en PATH
  mkdir -p ~/.local/bin
  # macOS usa .zshrc como shell por defecto
  local shellrc="$HOME/.zshrc"
  if [ ! -f "$shellrc" ] && [ -f "$HOME/.bashrc" ]; then
    shellrc="$HOME/.bashrc"
  fi
  if [ -f "$shellrc" ] && ! grep -q '\.local/bin' "$shellrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shellrc"
    info "Añadido ~/.local/bin a PATH en $shellrc"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

# ── Instalar Neovim desde gestor de paquetes ─────────────────────────────────
install_nvim_pkg() {
  step "Instalando Neovim desde gestor de paquetes ($OS_TYPE)"

  case "$OS_TYPE" in
    arch)
      run sudo pacman -S --needed --noconfirm neovim
      ;;
    debian)
      run sudo apt install -y neovim
      ;;
    fedora)
      run sudo dnf install -y neovim
      ;;
    macos)
      run brew install neovim
      ;;
  esac
}

# ── Instalar Neovim desde GitHub releases (fallback) ─────────────────────────
install_nvim_curl() {
  step "Descargando Neovim desde GitHub releases"

  local os_arch
  case "$(uname -s)" in
    Darwin)
      os_arch="macos-$(uname -m)"
      # macOS uses arm64 or x86_64
      ;;
    Linux)
      os_arch="linux64"
      ;;
    *)
      error "SO no soportado para instalacion via curl."
      exit 1
      ;;
  esac

  local pattern="nvim-${os_arch}.tar.gz"
  local latest_url
  latest_url=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest 2>/dev/null \
    | grep browser_download_url \
    | grep "$pattern" \
    | grep -v 'sha256sum' \
    | head -1 \
    | cut -d '"' -f4)

  if [ -z "$latest_url" ]; then
    error "No se pudo obtener la URL de descarga de GitHub."
    exit 1
  fi

  local version
  version=$(echo "$latest_url" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "desconocida")
  info "Ultima version: v$version"

  run mkdir -p ~/.local

  local nvim_dir
  nvim_dir=$(basename "$latest_url" .tar.gz)
  run rm -rf ~/.local/"$nvim_dir" ~/.local/nvim.tar.gz

  run curl -fSL "$latest_url" -o ~/.local/nvim.tar.gz
  run tar xzf ~/.local/nvim.tar.gz -C ~/.local/
  run rm ~/.local/nvim.tar.gz

  # Crear symlink
  run mkdir -p ~/.local/bin
  run ln -sf ~/.local/"$nvim_dir"/bin/nvim ~/.local/bin/nvim

  success "Neovim v$version instalado en ~/.local/$nvim_dir/"

  local nvim_bin
  if [ -x ~/.local/bin/nvim ]; then
    nvim_bin=~/.local/bin/nvim
  elif [ -x ~/.local/"$nvim_dir"/bin/nvim ]; then
    nvim_bin=~/.local/"$nvim_dir"/bin/nvim
  else
    error "No se encuentra el binario de nvim tras la instalacion."
    exit 1
  fi

  echo "$nvim_bin"
}

# ── Actualizar Neovim via curl ───────────────────────────────────────────────
update_nvim_curl() {
  step "Comprobando actualizacion de Neovim (instalacion via curl)"

  local nvim_path
  nvim_path=$(command -v nvim 2>/dev/null || echo "")

  if [ -z "$nvim_path" ]; then
    error "Neovim no esta instalado. Usa --install-nvim para instalarlo."
    exit 1
  fi

  # Verificar que esta instalado via curl (~/.local/)
  if ! echo "$nvim_path" | grep -q '.local'; then
    warn "Neovim se instalo via gestor de paquetes ($nvim_path)."
    if [ -f ~/.local/bin/nvim ]; then
      :
    else
      if command -v brew &>/dev/null; then
        info "Actualiza con: brew upgrade neovim"
      else
        info "Actualiza con: sudo apt/dnf/pacman upgrade neovim"
      fi
      exit 0
    fi
  fi

  local current_version latest_version
  current_version=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "0.0.0")
  latest_version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest 2>/dev/null \
    | grep '"tag_name"' | head -1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "")

  if [ "$current_version" = "$latest_version" ]; then
    success "Neovim ya esta en la ultima version (v$current_version)."
    exit 0
  fi

  info "Actualizando v$current_version → v$latest_version"
  install_nvim_curl
  success "Neovim actualizado a v$latest_version"
  exit 0
}

# ── Comprobar version de Neovim ──────────────────────────────────────────────
check_nvim_version() {
  local nvim_bin="${1:-nvim}"

  if ! command -v "$nvim_bin" &>/dev/null; then
    return 1
  fi

  local version
  version=$("$nvim_bin" --version | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "0.0.0")
  local major minor
  major=$(echo "$version" | cut -d. -f1)
  minor=$(echo "$version" | cut -d. -f2)

  if [ "$major" -ge 1 ] || { [ "$major" -eq 0 ] && [ "$minor" -ge 10 ]; }; then
    success "Neovim v$version detectado (>= 0.10)"
    return 0
  else
    warn "Neovim v$version detectado. Se requiere >= 0.10."
    return 2
  fi
}

# ── Instalar herramientas de IA ──────────────────────────────────────────────
install_ai() {
  step "Instalando herramientas de IA"

  # OpenCode
  if command -v opencode &>/dev/null; then
    success "OpenCode ya instalado ($(opencode --version 2>/dev/null || echo '?'))"
  else
    info "Instalando OpenCode..."
    run npm i -g @opencode/cli 2>/dev/null || {
      warn "npm install fallo. Descargando binario..."
      local url os_pattern
      case "$(uname -s)" in
        Darwin) os_pattern="darwin" ;;
        Linux)  os_pattern="linux" ;;
      esac
      url=$(curl -s https://api.github.com/repos/anomalyco/opencode/releases/latest 2>/dev/null \
        | grep browser_download_url \
        | grep "$os_pattern" \
        | head -1 \
        | cut -d '"' -f4)
      if [ -n "$url" ]; then
        run curl -fSL "$url" -o /tmp/opencode.tar.gz
        run tar xzf /tmp/opencode.tar.gz -C ~/.local/bin/
        run rm /tmp/opencode.tar.gz
        success "OpenCode instalado via binario"
      fi
    }
  fi

  # Claude Code
  if command -v claude &>/dev/null; then
    success "Claude Code ya instalado ($(claude --version 2>/dev/null || echo '?'))"
  else
    info "Instalando Claude Code..."
    run curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code instalado"
  fi
}

# ── Instalar Nerd Font ───────────────────────────────────────────────────────
install_fonts() {
  local font_name="${1:-default}"

  local fonts=(
    "JetBrainsMono:JetBrains Mono"
    "CascadiaCode:Cascadia Code"
    "FiraCode:Fira Code"
    "Hack:Hack"
    "SourceCodePro:Source Code Pro"
    "UbuntuMono:Ubuntu Mono"
    "DejaVuSansMono:DejaVu Sans Mono"
    "Noto:Noto Mono"
    "Iosevka:Iosevka"
  )

  local font_key=""
  local font_label=""

  # Interactive selection
  if [ "$font_name" = "default" ] && [ -t 0 ]; then
    echo ""
    echo -e "  ${BOLD}Elige una Nerd Font:${NC}"
    echo ""
    local i=1
    for entry in "${fonts[@]}"; do
      local key="${entry%%:*}"
      local label="${entry##*:}"
      echo -e "    ${BOLD}$i${NC}) $label Nerd Font"
      ((i++))
    done
    echo ""
    echo -n "  Opcion [1 = JetBrains Mono]: "
    read -r choice
    choice="${choice:-1}"
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#fonts[@]}" ]; then
      font_key="${fonts[$((choice-1))]%%:*}"
      font_label="${fonts[$((choice-1))]##*:}"
    else
      font_key="JetBrainsMono"
      font_label="JetBrains Mono"
    fi
  elif [ "$font_name" = "default" ] || [ -z "$font_name" ]; then
    # Non-interactive or just `--with-fonts`: default
    font_key="JetBrainsMono"
    font_label="JetBrains Mono"
  else
    # Specific font requested via --with-fonts=<name>
    for entry in "${fonts[@]}"; do
      if [ "${entry%%:*}" = "$font_name" ]; then
        font_key="${entry%%:*}"
        font_label="${entry##*:}"
        break
      fi
    done
    if [ -z "$font_key" ]; then
      warn "Fuente '$font_name' no reconocida. Usando JetBrains Mono."
      font_key="JetBrainsMono"
      font_label="JetBrains Mono"
    fi
  fi

  step "Instalando $font_label Nerd Font"

  local fonts_dir
  if [ "$(uname -s)" = "Darwin" ]; then
    fonts_dir="$HOME/Library/Fonts"
  else
    fonts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  fi
  run mkdir -p "$fonts_dir"

  # Comprobar si ya esta instalada
  if fc-list 2>/dev/null | grep -qi "${font_label}.*Nerd"; then
    success "$font_label Nerd Font ya instalada"
    return
  fi

  local zip_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_key}.zip"

  info "Descargando $font_label Nerd Font..."
  run curl -fSL "$zip_url" -o "/tmp/${font_key}.zip"
  run unzip -oq "/tmp/${font_key}.zip" -d "$fonts_dir"
  run rm "/tmp/${font_key}.zip"

  if command -v fc-cache &>/dev/null; then
    run fc-cache -fv "$fonts_dir" 2>/dev/null
  fi

  success "$font_label Nerd Font instalada en $fonts_dir"
}

# ── Clonar config ────────────────────────────────────────────────────────────
clone_config() {
  step "Clonando configuracion de Neovim"

  local target="$HOME/.config/nvim"

  if [ -d "$target/.git" ]; then
    warn "Ya existe una config de Neovim con git en $target"
    echo -n "  ¿Sobrescribir? (respalda la actual) [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando clonado de config. Puedes instalarla manualmente:"
      info "  git clone $CONFIG_REPO $target"
      return
    fi
  fi

  if [ -d "$target" ]; then
    run mv "$target" "${target}.bak.$(date +%Y%m%d-%H%M%S)"
    info "Config anterior respaldada"
  fi

  run git clone "$CONFIG_REPO" "$target"
  success "Config clonada en $target"
}

# ── Instalar plugins ─────────────────────────────────────────────────────────
install_plugins() {
  step "Instalando plugins de Neovim (esto puede tardar 1-2 minutos)"

  local nvim_bin
  nvim_bin=$(command -v nvim 2>/dev/null || echo "")

  if [ -z "$nvim_bin" ]; then
    error "Neovim no encontrado. Instalalo primero."
    return 1
  fi

  info "Ejecutando nvim --headless para que lazy.nvim instale los plugins..."
  if $DRY_RUN; then
    echo "  ${YELLOW}[dry-run]${NC} nvim --headless -c 'lua vim.cmd(\"quit\")'"
  else
    "$nvim_bin" --headless -c 'lua vim.cmd("quit")' 2>/dev/null || true
  fi

  success "Plugins instalados"
}

# ── Instalar paquetes Mason ──────────────────────────────────────────────────
install_mason_packages() {
  step "Paquetes Mason recomendados"

  echo ""
  echo "  ¿Quieres instalar los paquetes Mason recomendados automaticamente?"
  echo "  (LSPs, debuggers, formateadores y linters para C#, Rust, Python, JS/TS, Go)"
  echo -n "  [y/N] "
  read -r answer
  if [ "${answer,,}" != "y" ]; then
    info "Puedes instalarlos manualmente abriendo :Mason en Neovim"
    return
  fi

  local nvim_bin
  nvim_bin=$(command -v nvim 2>/dev/null || echo "")

  if [ -z "$nvim_bin" ]; then
    warn "Neovim no encontrado. Instala los paquetes manualmente con :Mason."
    return
  fi

  local packages=(
    # LSP
    omnisharp rust-analyzer pyright
    typescript-language-server lua-language-server
    bash-language-server json-lsp yaml-language-server
    marksman html-lsp css-lsp
    dockerfile-language-server gopls
    # Debuggers
    netcoredbg codelldb node-debug2-adapter debugpy delve
    # Formateadores
    csharpier stylua shfmt prettier black isort gofumpt
    # Linters
    shellcheck ruff eslint_d markdownlint hadolint
  )

  info "Instalando ${#packages[@]} paquetes via Mason..."
  if $DRY_RUN; then
    echo "  ${YELLOW}[dry-run]${NC} MasonInstall ${packages[*]}"
  else
    "$nvim_bin" --headless "+MasonInstall ${packages[*]}" +qa 2>/dev/null || true
  fi

  success "Paquetes Mason instalados"
}

# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${BOLD}${CYAN}  tonyconf.nvim - Instalador${NC}"
echo -e "  ${BLUE}SO detectado:${NC} ${OS_TYPE}"
echo ""

# ── Actualizar Neovim (modo independiente) ──────────────────────────────────
if $UPDATE_NVIM; then
  update_nvim_curl
  exit 0
fi

# ── Instalar dependencias ────────────────────────────────────────────────────
install_deps

# ── Instalar Neovim ──────────────────────────────────────────────────────────
if $INSTALL_NVIM; then
  # Forzar instalacion via curl desde GitHub
  install_nvim_curl
else
  # Intentar via gestor de paquetes, comprobar version
  if ! command -v nvim &>/dev/null; then
    install_nvim_pkg
  fi

  if ! check_nvim_version; then
    local ret=$?
    if [ $ret -eq 2 ]; then
      # Version < 0.10
      local pkg_version
      pkg_version=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "?")
      echo ""
      warn "Tu SO ($OS_TYPE) ofrece Neovim v$pkg_version."
      echo "  Ejecuta este script con --install-nvim para descargar la ultima version:"
      echo ""
      echo -e "    ${BOLD}./install.sh --install-nvim${NC}"
      echo ""
      if [ "$OS_TYPE" = "macos" ]; then
        echo "  O actualiza via brew: brew upgrade neovim"
      fi
      echo "  O instalalo manualmente desde https://github.com/neovim/neovim/releases"
      exit 1
    fi
  fi
fi

# ── Herramientas de IA ───────────────────────────────────────────────────────
if $WITH_AI; then
  install_ai
else
  info "Herramientas de IA no incluidas. Añade --with-ai para instalarlas."
fi

# ── Nerd Font ────────────────────────────────────────────────────────────────
if [ -n "$WITH_FONTS" ]; then
  install_fonts "$WITH_FONTS"
else
  info "Nerd Font no incluida. Añade --with-fonts para elegir una (por defecto JetBrains Mono)."
fi

# ── Clonar config e instalar plugins ─────────────────────────────────────────
clone_config
check_nvim_version && install_plugins

# ── Paquetes Mason ───────────────────────────────────────────────────────────
if check_nvim_version 2>/dev/null; then
  install_mason_packages
fi

# ── Resumen ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  Instalacion completada!${NC}"
echo ""
echo "  Abre Neovim con: ${BOLD}nvim${NC}"
echo "  Gestiona plugins con: ${BOLD}:Lazy${NC}"
echo "  Instala LSPs/debuggers con: ${BOLD}:Mason${NC}"
echo ""
echo "  Documentacion completa: ${CYAN}https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
