#!/usr/bin/env bash
set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Flags ────────────────────────────────────────────────────────────────────
INSTALL_NVIM=false
UPDATE_NVIM=false
WITH_AI=true
WITH_FONTS="default"
DRY_RUN=false

# ── Help ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}tonyconf.nvim - Instalador${NC}

Uso: ./install.sh [flags]

${BOLD}Flags:${NC}
  --install-nvim    Fuerza re-descarga de Neovim desde GitHub (ultima version)
  --update-nvim     Comprueba y actualiza Neovim a la ultima version
  --base            Instalacion minima: deps, Nerd Font, config, plugins,
                    treesitter y Mason (sin herramientas de IA)
  --with-ai         Instala OpenCode y Claude Code (por defecto, salvo con --base)
  --with-fonts=<F>  Elige una Nerd Font (por defecto JetBrains Mono):
                    JetBrainsMono, CascadiaCode, FiraCode, Hack, SourceCodePro,
                    UbuntuMono, DejaVuSansMono, Noto, Iosevka
  --all             Equivale a instalacion completa (por defecto sin flags)
  --dry-run         Muestra que haria sin ejecutar nada
  -h, --help        Muestra esta ayuda

${BOLD}Requisitos minimos:${NC}
  - Nerd Font (siempre se instala: la UI de Neovim necesita iconos)
  - Neovim >= 0.12 (se instala automaticamente la ultima version desde GitHub)
  - git, curl, ripgrep, fd, nodejs, npm, python3, unzip
  - gcc + make (para compilar parsers de treesitter)
  - lazygit y lazydocker (integrados en la config)

${BOLD}Ejemplos:${NC}
  ./install.sh                        # Instalacion completa (incluye IA y Nerd Font)
  ./install.sh --base                 # Minima (sin herramientas de IA)
  ./install.sh --base --with-ai       # Minima + herramientas de IA
  ./install.sh --base --with-fonts=FiraCode
  ./install.sh --install-nvim         # Forzar Neovim ultima version desde GitHub
  ./install.sh --update-nvim          # Actualizar Neovim a la ultima version
EOF
  exit 0
}

# ── Parsear flags ────────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --install-nvim) INSTALL_NVIM=true ;;
    --update-nvim)  UPDATE_NVIM=true ;;
    --base)         WITH_AI=false ;;
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
run()     { if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${NC} $*"; else "$@"; fi; }

# ── Progreso: contador de pasos, timer y spinner ─────────────────────────────
TOTAL_STEPS=0
CURRENT_STEP=0
STEP_START=0

format_elapsed() {
  local secs=${1:-0}
  if [ "$secs" -lt 1 ]; then
    echo "<1s"
  elif [ "$secs" -lt 60 ]; then
    echo "${secs}s"
  else
    echo "$((secs / 60))m $((secs % 60))s"
  fi
}

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  STEP_START=$(date +%s)
  echo -e "\n${CYAN}${BOLD}[$CURRENT_STEP/$TOTAL_STEPS] ==>${NC} ${BOLD}$*${NC}"
}

step_done() {
  local elapsed
  elapsed=$(format_elapsed "$(( $(date +%s) - STEP_START ))")
  echo -e "  ${GREEN}✓${NC} Paso $CURRENT_STEP completado ${BLUE}($elapsed)${NC}"
}

# Spinner: muestra animacion mientras un proceso corre (solo con TTY)
# Escribe a stderr para que funcione incluso si stdout va por pipe
# Uso: cmd & spinner $! "Mensaje" ; wait $!
spinner() {
  local pid=$1
  local msg=${2:-""}
  local chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  local i=0
  local start
  start=$(date +%s)

  # Sin TTY (pipe/redireccion): solo espera sin animar
  if [ ! -t 2 ] || $DRY_RUN; then
    wait "$pid" 2>/dev/null
    return $?
  fi

  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}%s${NC} %s... %s" "${chars[$i]}" "$msg" "$(format_elapsed "$(( $(date +%s) - start ))")" >&2
    i=$(((i + 1) % ${#chars[@]}))
    sleep 0.1
  done
  wait "$pid" 2>/dev/null
  local rc=$?
  printf "\r  ${GREEN}✓${NC} %s ${BLUE}(%s)${NC}\n" "$msg" "$(format_elapsed "$(( $(date +%s) - start ))")" >&2
  return $rc
}

# Ejecuta un comando largo con spinner y devuelve su codigo de salida
run_with_spinner() {
  local label=$1
  shift
  if [ ! -t 2 ] || $DRY_RUN; then
    "$@"
    return $?
  fi
  "$@" &
  local pid=$!
  spinner "$pid" "$label"
  return $?
}

# ── Error tracking ───────────────────────────────────────────────────────────
ERRORS=()
error_track() { ERRORS+=("$*"); }

report() {
  echo ""
  echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
  if [ ${#ERRORS[@]} -eq 0 ]; then
    echo -e "${BOLD}${GREEN}  Instalacion completada sin errores!${NC}"
  else
    echo -e "${BOLD}${YELLOW}  Se produjeron errores durante la instalacion (${#ERRORS[@]}):${NC}"
    for e in "${ERRORS[@]}"; do
      echo -e "    ${RED}✗${NC} $e"
    done
    echo ""
    echo -e "  ${YELLOW}Revisa los mensajes anteriores para mas detalles.${NC}"
    echo -e "  ${YELLOW}Puedes reintentar los pasos fallidos o resolverlos manualmente.${NC}"
  fi
}

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

# ── Instalar lazygit desde binario ──────────────────────────────────────────
CURL_OPTS="-fsSL --connect-timeout 10 --max-time 60"

install_lazygit() {
  if command -v lazygit &>/dev/null; then
    return 0
  fi
  info "Descargando lazygit..."
  local lg_url
  lg_url=$(curl $CURL_OPTS https://api.github.com/repos/jesseduffield/lazygit/releases/latest 2>/dev/null \
    | grep browser_download_url | grep linux_x86_64 | head -1 | cut -d '"' -f4 || true)
  if [ -n "$lg_url" ]; then
    run curl $CURL_OPTS "$lg_url" -o /tmp/lazygit.tar.gz
    run tar xzf /tmp/lazygit.tar.gz -C /tmp
    run mkdir -p ~/.local/bin
    run install /tmp/lazygit ~/.local/bin/lazygit
    run rm /tmp/lazygit.tar.gz /tmp/lazygit
    success "lazygit instalado"
  else
    warn "No se pudo descargar lazygit. Instalalo manualmente: https://github.com/jesseduffield/lazygit/releases"
  fi
}

# ── Instalar dependencias base ───────────────────────────────────────────────
install_deps() {
  step "Instalando dependencias base (git, curl, ripgrep, fd, nodejs, npm, python3, unzip, gcc, make, lazygit, lazydocker)"

  case "$OS_TYPE" in
    arch)
      run sudo pacman -S --needed --noconfirm git curl ripgrep fd nodejs npm python python-pip unzip base-devel lazygit lazydocker
      ;;
    debian)
      run sudo apt update -y
      run sudo apt install -y git curl ripgrep fd-find nodejs npm python3 python3-pip python3-venv unzip gcc make
      install_lazygit
      if ! command -v lazydocker &>/dev/null; then
        curl $CURL_OPTS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
      fi
      # fd-find binary is called fdfind on Debian
      if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        run mkdir -p ~/.local/bin
        run ln -sf "$(command -v fdfind)" ~/.local/bin/fd
        success "Symlink fd → fdfind creado en ~/.local/bin"
      fi
      ;;
    fedora)
      run sudo dnf install -y git curl ripgrep fd-find nodejs npm python3 python3-pip unzip gcc make
      install_lazygit
      if ! command -v lazydocker &>/dev/null; then
        curl $CURL_OPTS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
      fi
      if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        run mkdir -p ~/.local/bin
        run ln -sf "$(command -v fdfind)" ~/.local/bin/fd
        success "Symlink fd → fdfind creado en ~/.local/bin"
      fi
      ;;
    macos)
      if ! command -v brew &>/dev/null; then
        warn "Homebrew no encontrado (necesario para instalar dependencias)."
        echo -n "  ¿Instalar Homebrew automaticamente? [Y/n] "
        read -r answer
        if [ "${answer:-y}" != "n" ] && [ "${answer:-y}" != "N" ]; then
          /bin/bash -c "$(curl $CURL_OPTS https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          # Añadir brew al PATH en esta sesion
          if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
          fi
        else
          info "Instalacion de Homebrew rechazada. Instala manualmente: https://brew.sh"
          info "Luego instala las dependencias: brew install git curl ripgrep fd node npm python3 lazygit jesseduffield/lazydocker/lazydocker"
          return
        fi
      fi
      run brew install git curl ripgrep fd node npm python3 lazygit jesseduffield/lazydocker/lazydocker
      ;;    
    *)
      echo -e "${RED}[ERROR]${NC} SO no soportado: $OS_TYPE."
      echo "  Linux: Arch (pacman), Debian/Ubuntu (apt), Fedora (dnf)"
      echo "  macOS: Homebrew (brew)"
      echo "  Instala manualmente: git, curl, ripgrep, fd, node, npm, python3, unzip, lazygit, lazydocker"
      exit 1
      ;;
  esac

  # Configurar npm con prefix de usuario (para que Mason no necesite sudo)
  if command -v npm &>/dev/null; then
    local npm_prefix
    npm_prefix=$(npm config get prefix 2>/dev/null || echo "/usr")
    if echo "$npm_prefix" | grep -qE '^/usr'; then
      run mkdir -p ~/.local
      run npm config set prefix ~/.local
      info "npm prefix configurado a ~/.local (instalaciones globales sin sudo)"
    fi
  else
    warn "npm no encontrado. Instala nodejs/npm manualmente para los paquetes de Mason."
  fi

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

# ── Instalar Neovim desde GitHub releases (Linux) ────────────────────────────
install_nvim_curl() {
  step "Descargando Neovim desde GitHub releases"

  local os_arch
  case "$(uname -s)" in
    Linux)
      case "$(uname -m)" in
        x86_64) os_arch="linux-x86_64" ;;
        aarch64|arm64) os_arch="linux-arm64" ;;
        *)
          error "Arquitectura no soportada: $(uname -m)."
          exit 1
          ;;
      esac
      ;;
    *)
      error "SO no soportado para instalacion via curl."
      exit 1
      ;;
  esac

  local pattern="nvim-${os_arch}.tar.gz"
  local latest_url
  latest_url=$(curl $CURL_OPTS https://api.github.com/repos/neovim/neovim/releases/latest 2>/dev/null \
    | grep browser_download_url \
    | grep "$pattern" \
    | grep -v 'sha256sum' \
    | head -1 \
    | cut -d '"' -f4 || true)

  if [ -z "$latest_url" ]; then
    error "No se pudo obtener la URL de descarga de GitHub."
    exit 1
  fi

  local version
  version=$(echo "$latest_url" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "desconocida")
  info "Descargando Neovim v$version ($os_arch)..."

  run mkdir -p ~/.local

  local nvim_dir
  nvim_dir=$(basename "$latest_url" .tar.gz)

  # Limpiar instalaciones previas de nvim en ~/.local
  for old in ~/.local/nvim-linux-*; do
    [ -e "$old" ] && run rm -rf "$old"
  done
  run rm -f ~/.local/nvim.tar.gz ~/.local/bin/nvim

  run curl $CURL_OPTS "$latest_url" -o ~/.local/nvim.tar.gz
  run tar xzf ~/.local/nvim.tar.gz -C ~/.local/
  run rm ~/.local/nvim.tar.gz

  # Crear symlink
  run mkdir -p ~/.local/bin
  run ln -sf ~/.local/"$nvim_dir"/bin/nvim ~/.local/bin/nvim

  success "Neovim v$version instalado en ~/.local/$nvim_dir/"
  echo ~/.local/bin/nvim
}

# ── Instalar Neovim desde Homebrew (macOS) ───────────────────────────────────
install_nvim_brew() {
  step "Instalando Neovim desde Homebrew (macOS)"

  if ! command -v brew &>/dev/null; then
    error "Homebrew no encontrado. Instalalo desde https://brew.sh"
    exit 1
  fi

  run brew install neovim
  success "Neovim instalado via brew ($(nvim --version | head -1))"
  command -v nvim
}

# ── Garantizar Neovim >= 0.12 ────────────────────────────────────────────────
ensure_nvim() {
  step "Comprobando Neovim (requiere >= 0.12)"

  # --install-nvim fuerza re-descarga
  if $INSTALL_NVIM; then
    info "Forzando instalacion de la ultima version desde GitHub..."
    install_nvim_curl
    return 0
  fi

  local nvim_bin
  nvim_bin=$(command -v nvim 2>/dev/null || echo "")

  if [ -n "$nvim_bin" ]; then
    local version
    version=$("$nvim_bin" --version | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "0.0.0")
    local major minor
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    if [ "$major" -ge 1 ] || { [ "$major" -eq 0 ] && [ "$minor" -ge 12 ]; }; then
      success "Neovim v$version detectado (>= 0.12)"
      return 0
    fi
    warn "Neovim v$version detectado. Se necesita >= 0.12 para los plugins actuales."
  else
    warn "Neovim no encontrado."
  fi

  info "Instalando la ultima version estable de Neovim..."
  if [ "$OS_TYPE" = "macos" ]; then
    install_nvim_brew
  else
    install_nvim_curl
  fi
}

# ── Actualizar Neovim (modo independiente) ───────────────────────────────────
update_nvim() {
  step "Comprobando actualizacion de Neovim"

  local nvim_bin
  nvim_bin=$(command -v nvim 2>/dev/null || echo "")

  if [ -z "$nvim_bin" ]; then
    info "Neovim no instalado. Instalando ultima version..."
    ensure_nvim
    exit 0
  fi

  local current_version latest_version
  current_version=$("$nvim_bin" --version | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "0.0.0")
  latest_version=$(curl $CURL_OPTS https://api.github.com/repos/neovim/neovim/releases/latest 2>/dev/null \
    | grep '"tag_name"' | head -1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "")

  if [ -z "$latest_version" ]; then
    error "No se pudo consultar la ultima version de Neovim."
    exit 1
  fi

  if [ "$current_version" = "$latest_version" ]; then
    success "Neovim ya esta en la ultima version (v$current_version)."
    exit 0
  fi

  info "Actualizando v$current_version → v$latest_version"
  if [ "$OS_TYPE" = "macos" ]; then
    run brew upgrade neovim
    success "Neovim actualizado via brew"
  else
    install_nvim_curl
    success "Neovim actualizado a v$latest_version"
  fi
  exit 0
}

# ── Instalar herramientas de IA ──────────────────────────────────────────────
install_ai() {
  if ! $WITH_AI; then
    info "Herramientas de IA no incluidas (instalacion --base). Usa --with-ai para incluirlas."
    return
  fi

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
      url=$(curl $CURL_OPTS https://api.github.com/repos/anomalyco/opencode/releases/latest 2>/dev/null \
        | grep browser_download_url \
        | grep "$os_pattern" \
        | head -1 \
        | cut -d '"' -f4 || true)
      if [ -n "$url" ]; then
        run curl $CURL_OPTS "$url" -o /tmp/opencode.tar.gz
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
    run curl $CURL_OPTS https://claude.ai/install.sh | bash
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
  run curl $CURL_OPTS "$zip_url" -o "/tmp/${font_key}.zip"
  run unzip -oq "/tmp/${font_key}.zip" -d "$fonts_dir"
  run rm "/tmp/${font_key}.zip"

  if command -v fc-cache &>/dev/null; then
    run fc-cache -fv "$fonts_dir" 2>/dev/null
  fi

  success "$font_label Nerd Font instalada en $fonts_dir"
}

# ── Instalar config desde el directorio actual ───────────────────────────────
install_config() {
  local target="$HOME/.config/nvim"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [ ! -f "$script_dir/init.lua" ] || [ ! -d "$script_dir/lua" ]; then
    error "No se encuentra la config de Neovim junto a install.sh ($script_dir)."
    exit 1
  fi

  step "Instalando configuracion de Neovim desde el directorio actual"

  if [ -d "$target/.git" ]; then
    warn "Ya existe una config de Neovim con git en $target"
    echo -n "  ¿Sobrescribir? (respalda la actual) [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando instalacion de config."
      return
    fi
  fi

  if [ -d "$target" ]; then
    run mv "$target" "${target}.bak.$(date +%Y%m%d-%H%M%S)"
    info "Config anterior respaldada"
  fi

  # Copiar solo lo necesario para Neovim (no install.sh, wiki/, bashrc, extras/)
  run mkdir -p "$target"
  run cp "$script_dir/init.lua" "$target/init.lua"
  run cp -r "$script_dir/lua" "$target/lua"
  if [ -f "$script_dir/stylua.toml" ]; then
    run cp "$script_dir/stylua.toml" "$target/stylua.toml"
  fi
  if [ -f "$script_dir/.neoconf.json" ]; then
    run cp "$script_dir/.neoconf.json" "$target/.neoconf.json"
  fi
  success "Config copiada en $target"
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
    run_with_spinner "Instalando plugins" "$nvim_bin" --headless -c 'lua vim.cmd("quit")' 2>/dev/null || {
      warn "La instalacion de plugins no finalizo correctamente."
      error_track "Instalacion de plugins de Neovim fallida"
    }
  fi

  success "Plugins instalados"
}

# ── Compilar parsers de treesitter ───────────────────────────────────────────
install_treesitter_parsers() {
  step "Compilando parsers de treesitter (requiere gcc/make)"

  local nvim_bin
  nvim_bin=$(command -v nvim 2>/dev/null || echo "")

  if [ -z "$nvim_bin" ]; then
    warn "Neovim no encontrado. Omite parsers de treesitter."
    return
  fi

  # Parsers del runtime de nvim (siempre usados) + lenguajes de la config
  local parsers_lua="'lua','vim','vimdoc','query','markdown','markdown_inline','json','yaml','bash','html','css','javascript','typescript','python','rust','go','c','cpp','c_sharp'"
  info "Instalando parsers: lua, vim, vimdoc, query, markdown, json, yaml, bash, html, css, js, ts, python, rust, go, c, cpp, c_sharp"

  if $DRY_RUN; then
    echo "  ${YELLOW}[dry-run]${NC} nvim --headless require('nvim-treesitter').install({...}):wait(300000)"
  else
    # La API de nvim-treesitter es async: install() devuelve un Task y :wait() bloquea
    run_with_spinner "Compilando parsers de treesitter" "$nvim_bin" --headless \
      -c "lua require('nvim-treesitter').install({$parsers_lua}):wait(300000)" \
      -c "qa!" 2>&1 | grep -viE "^(Downloading|Unpacking|Wrote|Installing|Initialized)" || true
    if [ ${PIPESTATUS[0]:-0} -ne 0 ]; then
      warn "La compilacion de parsers de treesitter finalizo con errores."
      error_track "Compilacion de parsers de treesitter incompleta"
    fi
  fi

  success "Parsers de treesitter instalados"
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
    netcoredbg codelldb debugpy delve
    # Formateadores
    csharpier stylua shfmt prettier black isort gofumpt
    # Linters
    shellcheck ruff eslint_d markdownlint hadolint
  )

  # Filtrar paquetes cuyo toolchain no esta instalado (evita instaladores colgados)
  local filtered=()
  for pkg in "${packages[@]}"; do
    case "$pkg" in
      csharpier)
        if command -v dotnet &>/dev/null; then filtered+=("$pkg"); else warn "Saltando csharpier (requiere dotnet)"; fi
        ;;
      gopls|delve|gofumpt)
        if command -v go &>/dev/null; then filtered+=("$pkg"); else warn "Saltando $pkg (requiere go)"; fi
        ;;
      black|isort|debugpy)
        if command -v pip3 &>/dev/null; then filtered+=("$pkg"); else warn "Saltando $pkg (requiere python3-pip)"; fi
        ;;
      *)
        filtered+=("$pkg")
        ;;
    esac
  done
  packages=("${filtered[@]}")

  if [ ${#packages[@]} -eq 0 ]; then
    info "No hay paquetes Mason instalables (faltan toolchains)."
    return
  fi

  info "Instalando ${#packages[@]} paquetes via Mason..."
  if $DRY_RUN; then
    echo "  ${YELLOW}[dry-run]${NC} MasonInstall ${packages[*]}"
    return
  fi

  # Script Lua temporal: encola los paquetes via API y espera a que terminen
  local lua_script="/tmp/tonyconf_mason.lua"
  local errors_file="/tmp/tonyconf_mason_errors.txt"
  : > "$errors_file"

  {
    echo "local registry = require(\"mason-registry\")"
    echo "local packages = {"
    for pkg in "${packages[@]}"; do
      echo "  \"$pkg\","
    done
    echo "}"
    echo "local queued = 0"
    echo "for _, name in ipairs(packages) do"
    echo "  local okp, pkg = pcall(registry.get_package, name)"
    echo "  if okp and not pkg:is_installed() and not pkg:is_installing() then"
    echo "    local ok = pcall(function() pkg:install() end)"
    echo "    if ok then queued = queued + 1 end"
    echo "  end"
    echo "end"
    echo "print('Paquetes encolados: ' .. queued)"
    echo "local function any_installing()"
    echo "  for _, name in ipairs(packages) do"
    echo "    local ok_pkg, pkg = pcall(registry.get_package, name)"
    echo "    if ok_pkg and pkg:is_installing() then return true end"
    echo "  end"
    echo "  return false"
    echo "end"
    echo "local deadline = vim.loop.hrtime() + 600e9"
    echo "while any_installing() and vim.loop.hrtime() < deadline do"
    echo "  vim.wait(1000)"
    echo "end"
    echo "local installed, failed = 0, 0"
    echo "for _, name in ipairs(packages) do"
    echo "  local ok_pkg, pkg = pcall(registry.get_package, name)"
    echo "  if ok_pkg and pkg:is_installed() then"
    echo "    print(string.format('[OK] %s', name))"
    echo "    installed = installed + 1"
    echo "  else"
    echo "    print(string.format('[FAIL] %s', name))"
    echo "    failed = failed + 1"
    echo "    local f = io.open('$errors_file', 'a')"
    echo "    if f then f:write(name .. '\\n') f:close() end"
    echo "  end"
    echo "end"
    echo "print(string.format('RESUMEN: %d instalados, %d fallidos', installed, failed))"
    echo "vim.cmd('qa!')"
  } > "$lua_script"

  # Filtrar el ruido de Mason (descargas) pero mostrar [OK]/[FAIL]/RESUMEN
  run_with_spinner "Instalando paquetes Mason" "$nvim_bin" --headless -c "luafile $lua_script" 2>&1 \
    | grep -E '^\[(OK|FAIL)\]|^RESUMEN|^Paquetes encolados' || true
  if [ ${PIPESTATUS[0]:-0} -ne 0 ] && [ ${PIPESTATUS[0]:-0} -ne 130 ]; then
    warn "La instalacion de paquetes Mason finalizo con codigo $?."
    error_track "Instalacion de paquetes Mason finalizo con errores"
  fi

  if [ -s "$errors_file" ]; then
    while IFS= read -r pkg; do
      error_track "Paquete Mason fallido: $pkg"
    done < "$errors_file"
  fi

  rm -f "$lua_script" "$errors_file"
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
  update_nvim
  exit 0
fi

# ── 8 pasos de la instalacion ────────────────────────────────────────────────
TOTAL_STEPS=8

# ── Instalar dependencias ────────────────────────────────────────────────────
install_deps

# ── Garantizar Neovim >= 0.12 ────────────────────────────────────────────────
ensure_nvim

# ── Nerd Font (requisito minimo para la UI de Neovim) ───────────────────────
install_fonts "$WITH_FONTS"

# ── Instalar config ──────────────────────────────────────────────────────────
install_config

# ── Instalar plugins, treesitter y Mason ─────────────────────────────────────
install_plugins
install_treesitter_parsers
install_mason_packages

# ── Herramientas de IA (paso 8: informa si --base) ───────────────────────────
install_ai

# ── Resumen ──────────────────────────────────────────────────────────────────
report

echo ""
echo "  Abre Neovim con: ${BOLD}nvim${NC}"
echo "  Gestiona plugins con: ${BOLD}:Lazy${NC}"
echo "  Instala LSPs/debuggers con: ${BOLD}:Mason${NC}"
echo ""
echo "  Documentacion completa: ${CYAN}https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki${NC}"
echo ""
