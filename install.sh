#!/usr/bin/env bash
set -euo pipefail

# ── Reconectar stdin a la terminal para prompts interactivos ──────────────────
# Cuando se ejecuta via curl | bash, stdin es el pipe (no TTY).
# Redirigimos a /dev/tty para que los read funcionen correctamente.
if [ ! -t 0 ] && [ -e /dev/tty ]; then
  exec < /dev/tty
fi

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
  if command -v opencode &>/dev/null || [ -x "$HOME/.opencode/bin/opencode" ]; then
    success "OpenCode ya instalado ($(opencode --version 2>/dev/null || echo '?'))"
  else
    info "Instalando OpenCode..."
    if $DRY_RUN; then
      echo -e "  ${YELLOW}[dry-run]${NC} curl -fsSL https://opencode.ai/install | bash"
    else
      if curl -fsSL https://opencode.ai/install | bash; then
        success "OpenCode instalado"
      else
        warn "No se pudo instalar OpenCode. Instalalo manualmente: https://opencode.ai"
        error_track "Instalacion de OpenCode fallida"
      fi
    fi
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

# ── Mapear font_key -> familia de WezTerm ────────────────────────────────────
get_wezterm_font() {
  case "$1" in
    JetBrainsMono)   echo "JetBrainsMono Nerd Font" ;;
    CascadiaCode)    echo "CaskaydiaCove Nerd Font" ;;
    FiraCode)        echo "FiraCode Nerd Font" ;;
    Hack)            echo "Hack Nerd Font" ;;
    SourceCodePro)   echo "SauceCodePro Nerd Font" ;;
    UbuntuMono)      echo "UbuntuMono Nerd Font" ;;
    DejaVuSansMono)  echo "DejaVuSansMono Nerd Font" ;;
    Noto)            echo "NotoSansMono Nerd Font" ;;
    Iosevka)         echo "Iosevka Nerd Font" ;;
    *)               echo "JetBrainsMono Nerd Font" ;;
  esac
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

  WEZTERM_FONT_FAMILY=$(get_wezterm_font "$font_key")

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
    # El 2>/dev/null va dentro del comando para no silenciar el spinner (stderr del shell)
    run_with_spinner "Instalando plugins" bash -c 'exec "$0" --headless -c "lua vim.cmd(\"quit\")" 2>/dev/null' "$nvim_bin" || {
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
    # El filtrado va dentro del hijo para no robar el stderr del spinner
    run_with_spinner "Compilando parsers de treesitter" bash -c \
      'exec "$0" --headless -c "lua require(\"nvim-treesitter\").install({$1}):wait(300000)" -c "qa!" 2>&1 | grep -viE "^(Downloading|Unpacking|Wrote|Installing|Initialized)" || true' \
      "$nvim_bin" "$parsers_lua" || true
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
  # El filtrado va dentro del hijo para no robar el stderr del spinner
  run_with_spinner "Instalando paquetes Mason" bash -c \
    'exec "$0" --headless -c "luafile $1" 2>&1 | grep -E "^\[(OK|FAIL)\]|^RESUMEN|^Paquetes encolados" || true' \
    "$nvim_bin" "$lua_script"
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

# ── Instalar config de WezTerm (opcional) ─────────────────────────────────────
install_wezterm() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [ ! -f "$script_dir/extras/wezterm.lua" ]; then
    return
  fi

  local wezterm_dir="$HOME/.config/wezterm"
  local wezterm_installed=false
  if command -v wezterm &>/dev/null; then
    wezterm_installed=true
  fi

  if [ -f "$wezterm_dir/wezterm.lua" ]; then
    echo ""
    echo "  Ya tienes una config de WezTerm en ~/.config/wezterm/wezterm.lua."
    echo -n "  ¿Reemplazarla con la de tonyconf? (se respaldara la actual) [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Conservando tu config de WezTerm actual."
      return
    fi
    run cp "$wezterm_dir/wezterm.lua" "$wezterm_dir/wezterm.lua.bak.$(date +%Y%m%d-%H%M%S)"
    info "Config existente respaldada"
  elif $wezterm_installed; then
    echo ""
    echo "  WezTerm detectado. tonyconf incluye un tema kanagawa para el."
    echo -n "  ¿Instalar config de WezTerm en ~/.config/wezterm/? [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando config de WezTerm."
      return
    fi
  else
    echo ""
    echo "  WezTerm no esta instalado. tonyconf incluye un tema kanagawa"
    echo "  y configuracion completa (tabline, smart-splits) para el."
    echo -n "  ¿Instalar WezTerm + su config? [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando WezTerm."
      return
    fi
    step "Instalando WezTerm"
    case "$OS_TYPE" in
      arch) run sudo pacman -S --needed --noconfirm wezterm ;;
      fedora) run sudo dnf install -y wezterm ;;
      debian)
        warn "WezTerm no esta en los repos de Debian/Ubuntu. Instalalo manualmente: https://wezterm.org"
        return
        ;;
      macos) run brew install --cask wezterm ;;
      *) warn "SO no soportado. Instala WezTerm manualmente: https://wezterm.org"; return ;;
    esac
    success "WezTerm instalado"
  fi

  step "Instalando config de WezTerm"
  run mkdir -p "$wezterm_dir"
  if $DRY_RUN; then
    echo -e "  ${YELLOW}[dry-run]${NC} sed ... extras/wezterm.lua > $wezterm_dir/wezterm.lua (fuente: ${WEZTERM_FONT_FAMILY:-CaskaydiaCove Nerd Font})"
  else
    sed "s/\"CaskaydiaCove Nerd Font\"/\"${WEZTERM_FONT_FAMILY:-CaskaydiaCove Nerd Font}\"/" \
      "$script_dir/extras/wezterm.lua" > "$wezterm_dir/wezterm.lua"
  fi
  success "Config de WezTerm instalada en $wezterm_dir"
}

# ── Instalar terminfo de WezTerm ──────────────────────────────────────────────
install_wezterm_terminfo() {
  if infocmp wezterm &>/dev/null; then
    return
  fi

  if ! command -v tic &>/dev/null; then
    warn "tic (ncurses) no encontrado. La terminfo 'wezterm' no se instalara."
    warn "Puedes instalar ncurses con tu gestor de paquetes y reintentar."
    return
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local terminfo_src="$script_dir/extras/wezterm.terminfo"

  if [ ! -f "$terminfo_src" ]; then
    warn "No se encontro extras/wezterm.terminfo. Saltando instalacion de terminfo."
    return
  fi

  if $DRY_RUN; then
    echo -e "  ${YELLOW}[dry-run]${NC} tic -x extras/wezterm.terminfo"
    return
  fi

  tic -x "$terminfo_src" 2>/dev/null || {
    warn "No se pudo instalar la terminfo de WezTerm."
    return
  }

  if infocmp wezterm &>/dev/null; then
    success "Terminfo de WezTerm instalada"
  fi
}

# ── Instalar config de ZSH (opcional) ────────────────────────────────────────
install_zsh() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [ ! -f "$script_dir/extras/zshrc" ]; then
    return
  fi

  local zsh_was_installed=false
  if command -v zsh &>/dev/null; then
    zsh_was_installed=true
  fi

  if $zsh_was_installed; then
    echo ""
    echo "  ZSH detectado. tonyconf incluye config con plugins y starship."
    echo -n "  ¿Instalar/actualizar la config de ZSH? [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando config de ZSH."
      return
    fi
  else
    echo ""
    echo "  ZSH no esta instalado. tonyconf incluye un entorno ZSH completo:"
    echo "  autosuggestions, syntax-highlighting, fzf, zoxide y starship."
    echo -n "  ¿Instalar ZSH + plugins + config? [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando ZSH."
      return
    fi
  fi

  step "Instalando ZSH y plugins"

  # ── Instalar ZSH (si no existe) ──────────────────────────────────
  if ! $zsh_was_installed; then
    case "$OS_TYPE" in
      arch) run sudo pacman -S --needed --noconfirm zsh ;;
      fedora) run sudo dnf install -y zsh ;;
      debian) run sudo apt install -y zsh ;;
      macos) run brew install zsh ;;
      *) warn "SO no soportado. Instala ZSH manualmente."; return ;;
    esac
    success "ZSH instalado"
  else
    success "ZSH ya instalado ($(zsh --version 2>/dev/null | head -1))"
  fi

  # ── Instalar plugins y herramientas ZSH ─────────────────────────
  if $zsh_was_installed; then
    echo ""
    echo "  ZSH ya estaba instalado. ¿Instalar tambien los plugins de ZSH?"
    echo "  (autosuggestions, syntax-highlighting, fzf, zoxide)"
    echo -n "  [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Saltando instalacion de plugins ZSH."
      _skip_zsh_plugins=true
    fi
  fi
  # Definir antes de usar (Debian necesita el binario de zoxide)
  install_zoxide_deb() {
    if command -v zoxide &>/dev/null; then
      return
    fi
    info "Descargando zoxide..."
    local zo_url
    zo_url=$(curl $CURL_OPTS https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest 2>/dev/null \
      | grep browser_download_url | grep x86_64-unknown-linux-musl | head -1 | cut -d '"' -f4 || true)
    if [ -n "$zo_url" ]; then
      run curl $CURL_OPTS "$zo_url" -o /tmp/zoxide.tar.gz
      run tar xzf /tmp/zoxide.tar.gz -C /tmp
      run install /tmp/zoxide ~/.local/bin/zoxide
      run rm /tmp/zoxide.tar.gz /tmp/zoxide
      success "zoxide instalado"
    fi
  }

  if [ "${_skip_zsh_plugins:-false}" != true ]; then
    info "Instalando plugins: autosuggestions, syntax-highlighting, fzf, zoxide..."
    case "$OS_TYPE" in
      arch)      run sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting fzf zoxide ;;
      fedora)    run sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting fzf zoxide ;;
      debian)    run sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting fzf; install_zoxide_deb ;;
      macos)     run brew install zsh-autosuggestions zsh-syntax-highlighting fzf zoxide ;;
      *)         warn "SO no soportado. Instala manualmente: zsh-autosuggestions, zsh-syntax-highlighting, fzf, zoxide" ;;
    esac
  fi

  # ── Instalar Starship ────────────────────────────────────────────
  if command -v starship &>/dev/null; then
    success "Starship ya instalado ($(starship --version 2>/dev/null))"
  else
    info "Instalando Starship prompt..."
    if $DRY_RUN; then
      echo -e "  ${YELLOW}[dry-run]${NC} curl -sS https://starship.rs/install.sh | sh -s -- -y"
    else
      if ! curl --proto '=https' --tlsv1.2 -sS https://starship.rs/install.sh | sh -s -- -y; then
        warn "No se pudo instalar Starship. Instalalo manualmente: https://starship.rs"
      else
        success "Starship instalado en $HOME/.local/bin"
      fi
    fi
  fi

  # ── Copiar .zshrc ────────────────────────────────────────────────
  if [ -f "$HOME/.zshrc" ]; then
    echo ""
    echo "  Ya tienes un ~/.zshrc configurado."
    echo -n "  ¿Reemplazarlo con la config de tonyconf? (se respaldara el actual) [y/N] "
    read -r answer
    if [ "${answer,,}" != "y" ]; then
      info "Conservando tu ~/.zshrc actual."
    else
      run mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d-%H%M%S)"
      info ".zshrc anterior respaldado"
      _copy_zshrc=true
    fi
  else
    _copy_zshrc=true
  fi

  # Adaptar rutas de plugins segun distro
  local autosuggestions_path syntax_hl_path fzf_keybindings
  case "$OS_TYPE" in
    arch)
      autosuggestions_path="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
      syntax_hl_path="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fzf_keybindings="/usr/share/fzf/key-bindings.zsh"
      ;;
    debian)
      autosuggestions_path="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      syntax_hl_path="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fzf_keybindings="/usr/share/doc/fzf/examples/key-bindings.zsh"
      ;;
    fedora)
      autosuggestions_path="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      syntax_hl_path="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fzf_keybindings="/usr/share/fzf/shell/key-bindings.zsh"
      ;;
    macos)
      autosuggestions_path="$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      syntax_hl_path="$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fzf_keybindings="$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh"
      ;;
    *)
      autosuggestions_path="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      syntax_hl_path="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fzf_keybindings="/usr/share/fzf/shell/key-bindings.zsh"
      ;;
  esac

  if [ "${_copy_zshrc:-false}" = true ]; then
    if $DRY_RUN; then
      echo -e "  ${YELLOW}[dry-run]${NC} sed ... extras/zshrc > ~/.zshrc (plugins adaptados a $OS_TYPE)"
    else
      sed -e "s|/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh|$autosuggestions_path|g" \
          -e "s|/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|$syntax_hl_path|g" \
          -e "s|/usr/share/fzf/shell/key-bindings.zsh|$fzf_keybindings|g" \
          "$script_dir/extras/zshrc" > "$HOME/.zshrc"
    fi
    success ".zshrc instalado"
  fi

  # ── Copiar starship.toml ────────────────────────────────────────
  if [ "${_copy_zshrc:-false}" = true ] && [ -f "$script_dir/extras/starship.toml" ]; then
    local starship_dir="$HOME/.config"
    run mkdir -p "$starship_dir"
    if [ -f "$starship_dir/starship.toml" ]; then
      run mv "$starship_dir/starship.toml" "$starship_dir/starship.toml.bak.$(date +%Y%m%d-%H%M%S)"
      info "starship.toml anterior respaldado"
    fi
    run cp "$script_dir/extras/starship.toml" "$starship_dir/starship.toml"
    success "starship.toml instalado en $starship_dir"
  fi

  # ── Cambiar shell por defecto ────────────────────────────────────
  echo ""
  echo -e "  ${YELLOW}🔒${NC} El comando \`chsh\` necesita tu contraseña de usuario"
  echo "  para cambiar el shell por defecto a ZSH."
  echo -n "  ¿Establecer ZSH como shell por defecto? [y/N] "
  read -r answer
  if [ "${answer,,}" = "y" ]; then
    if $DRY_RUN; then
      echo -e "  ${YELLOW}[dry-run]${NC} chsh -s $(which zsh)"
    else
      echo ""
      info "Ejecutando chsh (introduce tu contraseña cuando aparezca el candado)..."
      if chsh -s "$(command -v zsh)" 2>/dev/null; then
        success "ZSH establecido como shell por defecto"
      else
        warn "No se pudo cambiar el shell por defecto."
        if [ "$OS_TYPE" = "fedora" ]; then
          warn "En Fedora con autenticacion por huella, prueba:"
          info "  sudo chsh -s $(command -v zsh) $USER"
        else
          info "  Ejecuta manualmente: chsh -s $(command -v zsh)"
        fi
      fi
    fi
  fi
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

# ── Config de WezTerm (opcional) ──────────────────────────────────────────────
install_wezterm
install_wezterm_terminfo

# ── Config de ZSH (opcional) ──────────────────────────────────────────────────
install_zsh

# ── Resumen ──────────────────────────────────────────────────────────────────
report

echo ""
echo "  Abre Neovim con: ${BOLD}nvim${NC}"
echo "  Gestiona plugins con: ${BOLD}:Lazy${NC}"
echo "  Instala LSPs/debuggers con: ${BOLD}:Mason${NC}"
echo ""
echo "  Documentacion completa en la wiki del repositorio."
echo ""
