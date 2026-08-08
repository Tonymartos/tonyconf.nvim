```
████████╗ ██████╗ ███╗   ██╗██╗   ██╗██╗   ██╗██╗███╗   ███╗
╚══██╔══╝██╔═══██╗████╗  ██║╚██╗ ██╔╝██║   ██║██║████╗ ████║
   ██║   ██║   ██║██╔██╗ ██║ ╚████╔╝ ██║   ██║██║██╔████╔██║
   ██║   ██║   ██║██║╚██╗██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
   ██║   ╚██████╔╝██║ ╚████║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
```

Configuracion de Neovim basada en [LazyVim](https://github.com/LazyVim/LazyVim), optimizada para desarrollo en **Rust**, **C# (.NET)**, **Godot/GDScript**, **Python**, **TypeScript** y multiples herramientas de IA.

Incluye integracion completa con **WezTerm** (tabline, smart-splits, tema kanagawa) y configuracion de **ZSH** (starship, autosuggestions, fzf, zoxide).

## Requisitos

### Minimos (se instalan automaticamente con `install.sh`)

- **Neovim >= 0.12** — `install.sh` detecta la version instalada y, si es menor,
  descarga automaticamente la ultima version estable desde los
  [releases oficiales](https://github.com/neovim/neovim/releases) de Neovim a
  `~/.local/bin/nvim` (sin sudo). En macOS se instala/actualiza via Homebrew.
- [git](https://git-scm.com), [curl](https://curl.se)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd) (en Debian/Fedora se crea el symlink `fd` automaticamente)
- [nodejs](https://nodejs.org) + [npm](https://www.npmjs.com) — necesarios para los LSP de JS/TS y paquetes npm de Mason
- [python3](https://www.python.org) + pip — necesarios para los paquetes Python de Mason (`pyright`, `black`, `isort`, `debugpy`, ...)
- [gcc](https://gcc.gnu.org) + [make](https://www.gnu.org/software/make/) — necesarios para compilar los parsers de **treesitter**
- [unzip](https://www.info-zip.org/) — para extraer la Nerd Font
- [lazygit](https://github.com/jesseduffield/lazygit) — gestion visual de Git desde Neovim (`<leader>gg`)
- [lazydocker](https://github.com/jesseduffield/lazydocker) — gestion visual de Docker desde terminal
- **Nerd Font** — **requisito minimo**: sin ella los iconos del dashboard, statusline
  (heirline), explorador (neo-tree), pestañas (barbar) y completado (blink.cmp) se ven
  como cuadrados rotos. `install.sh` la instala siempre (por defecto CaskaydiaCove).

  > **Para aplicar la fuente en Neovim:** instalar la fuente no la activa por si sola.
  > Debes seleccionarla en tu terminal. Si usas WezTerm, `install.sh` copia automaticamente
  > [`extras/wezterm.lua`](extras/wezterm.lua) en `~/.config/wezterm/wezterm.lua`
  > con la fuente seleccionada. Si usas Alacritty, copia [`extras/alacritty.toml`](extras/alacritty.toml).
  >
  > Puedes previsualizar los iconos y estilos en [nerdfonts.com](https://www.nerdfonts.com/font-downloads).

### Herramientas de IA (opcionales, incluidas por defecto salvo con `--base`)

- **[OpenCode](https://github.com/anomalyco/opencode)**
  - Arch: `sudo pacman -S opencode`
  - Debian/Fedora: descarga el binario desde [releases](https://github.com/anomalyco/opencode/releases) o `npm i -g @opencode/cli`
- **[Claude Code](https://claude.ai)**: `curl -fsSL https://claude.ai/install.sh | bash`
- **Avante**: requiere `ANTHROPIC_API_KEY` en entorno

## Instalacion

## Instalacion

### Via curl + tar (GitHub)

```bash
curl -L -o /tmp/tonyconf.tar.gz https://github.com/Tonymartos/tonyconf.nvim/archive/refs/heads/main.tar.gz
tar xzf /tmp/tonyconf.tar.gz -C /tmp
/tmp/tonyconf.nvim-main/install.sh
# Con flags:
/tmp/tonyconf.nvim-main/install.sh --base --with-fonts=FiraCode
```

### Via git clone (GitHub)

```bash
git clone https://github.com/Tonymartos/tonyconf.nvim.git /tmp/tonyconf && /tmp/tonyconf/install.sh
```

### Via SSH (Forge privada)

```bash
git clone ssh://git@git.forge.tonymartos.com:2222/tonymartos/tonyconf.nvim.git /tmp/tonyconf && /tmp/tonyconf/install.sh
```

### Manual (si ya tienes los archivos)

```bash
./install.sh                        # Instalacion completa (IA + Nerd Font + WezTerm + ZSH + todo)
./install.sh --base                 # Minima: deps + Nerd Font + config + plugins + treesitter + Mason (sin IA)
./install.sh --base --with-ai       # Minima + herramientas de IA
./install.sh --base --with-fonts=FiraCode   # Minima + fuente especifica
./install.sh --install-nvim         # Forzar descarga de la ultima version de Neovim desde GitHub
./install.sh --update-nvim          # Comprobar y actualizar Neovim a la ultima version
./install.sh --dry-run              # Muestra lo que haria sin ejecutar nada
```

> **Neovim**: si el sistema tiene nvim < 0.12 (p.ej. Ubuntu apt trae 0.11.x),
> el instalador descarga automaticamente la ultima version estable desde los
> [releases de Neovim](https://github.com/neovim/neovim/releases) a `~/.local/bin/nvim`,
> sin necesidad de sudo. `~/.local/bin` se añade a tu PATH automaticamente.
> Usa `./install.sh --update-nvim` en cualquier momento para actualizarlo.

Opciones de Nerd Font: `CaskaydiaCove` (por defecto), `JetBrainsMono`, `FiraCode`,
`Hack`, `SourceCodePro`, `UbuntuMono`, `DejaVuSansMono`, `Noto`, `Iosevka`.

> **macOS**: si no tienes Homebrew, el script te pregunta y lo instala automaticamente.
>
> **Errores**: si algun paso falla (ej. un paquete de Mason que requiere `dotnet` o
> `go` sin instalar), el script continua y al final muestra un resumen
> "Se produjeron errores durante la instalacion" con la lista de lo que fallo.

### Manual

```bash
# Respalda tu config actual si tienes una
mv ~/.config/nvim ~/.config/nvim.bak

# Clona este repo
git clone https://github.com/Tonymartos/tonyconf.nvim.git ~/.config/nvim

# Abre Neovim (instala los plugins automaticamente)
nvim
```

Al primer arranque, Lazy.nvim instalara todos los plugins. Espera a que termine (veras el progreso en pantalla).

Despues, instala los LSPs, debuggers y herramientas:

```
:Mason
```

Navega con `j/k` e instala con `i` sobre cada paquete.

### Terminal (WezTerm + ZSH)

`install.sh` configura automaticamente:

- **WezTerm** con tema kanagawa, tabline completa (CPU, RAM, reloj, domain), smart-splits integrado con Neovim, y terminfo
- **ZSH** con starship prompt, autosuggestions, syntax-highlighting, fzf (Ctrl+R fuzzy search), y zoxide (smart cd con `z`)

```bash
# Despues de instalar, cambia tu shell por defecto:
chsh -s /usr/bin/zsh
```

### LSP (Language Server Protocol)

| Paquete | Lenguaje |
|---------|----------|
| `omnisharp` | C#/.NET |
| `rust-analyzer` | Rust |
| `pyright` | Python |
| `typescript-language-server` | TypeScript / JavaScript |
| `lua-language-server` | Lua |
| `bash-language-server` | Bash |
| `json-lsp` | JSON / JSONC |
| `yaml-language-server` | YAML |
| `marksman` | Markdown |
| `html-lsp` | HTML |
| `css-lsp` | CSS |
| `dockerfile-language-server` | Docker |
| `gopls` | Go |

### Debuggers (DAP)

| Paquete | Lenguaje |
|---------|----------|
| `netcoredbg` | C#/.NET |
| `codelldb` | Rust, C, C++ |
| `js-debug-adapter` | JavaScript / TypeScript |
| `debugpy` | Python |
| `delve` | Go |

### Formateadores

| Paquete | Lenguaje |
|---------|----------|
| `csharpier` | C# |
| `stylua` | Lua |
| `shfmt` | Bash/Shell |
| `prettier` | JS, TS, JSON, CSS, MD, YAML |
| `black` | Python |
| `isort` | Python (imports) |
| `gofumpt` | Go |

### Linters

| Paquete | Lenguaje |
|---------|----------|
| `shellcheck` | Bash/Shell |
| `ruff` | Python |
| `eslint_d` | JavaScript / TypeScript |
| `markdownlint` | Markdown |
| `hadolint` | Docker |

## Estructura del repo

```
tonyconf.nvim/
├── init.lua                        # Punto de entrada
├── stylua.toml                     # Formateador Lua
├── install.sh                      # Instalador automatico
├── README.md
├── extras/                         # Configs de terminal
│   ├── wezterm.lua                 # WezTerm: kanagawa + tabline + smart-splits
│   ├── wezterm.terminfo            # Terminfo de WezTerm
│   ├── zshrc                       # ZSH: starship + autosuggestions + fzf + zoxide
│   ├── starship.toml               # Starship prompt customizado
│   └── alacritty.toml              # Alacritty (legacy)
├── wiki/                           # Documentacion
└── lua/
    ├── config/
    │   ├── tonyconf.lua            # Bootstrap lazy.nvim + LazyVim
    │   ├── options.lua             # Opciones globales de Vim
    │   ├── keymaps.lua             # Atajos adicionales
    │   ├── autocmds.lua            # Autocomandos adicionales
    │   └── grug-file-options.lua   # Config de grug-far
    └── plugins/
        ├── ai/                     # Plugins de IA
        │   ├── opencode.lua        # OpenCode integrado en terminal
        │   ├── claude-code.lua     # Claude Code integrado en terminal
        │   └── avante.lua          # Asistente con diff/keep/undo
        ├── editor/                 # Plugins de edicion
        │   ├── autosave.lua        # Auto-guardado
        │   ├── dash.lua            # Dashboard de inicio
        │   ├── minidiff.lua        # Visualizacion de diffs
        │   ├── toggleterm.lua      # Terminal flotante
        │   └── smart-splits.lua    # Navegacion Neovim ↔ WezTerm panes
        ├── lang/                   # Soporte de lenguajes
        │   ├── rust.lua            # Rust (rustaceanvim)
        │   ├── csharp.lua          # C#/.NET (omnisharp + netcoredbg)
        │   └── godot.lua           # Godot/GDScript
        ├── dap/                    # Debugging
        │   └── nvim-dap.lua        # DAP: C#, Rust, JS/TS, Go
        ├── tools/                  # Herramientas
        │   ├── grug-far.lua        # Busqueda y reemplazo
        │   ├── remote-vim.lua      # Edicion remota via SSH
        │   └── imgclip.lua         # Pegar imagenes
        └── ui/                     # Interfaz
            ├── init.lua            # Plugins core: neo-tree, telescope, kanagawa, etc
            ├── heirline.lua        # Statusline + Winbar con colores kanagawa
            ├── dressing.lua        # UI para inputs/selects
            ├── gitsigns.lua        # Indicadores git en gutter
            └── which-key.lua       # Menu de atajos
```

## Plugins incluidos

### IA / Asistentes

| Plugin | Atajo | Descripcion |
|--------|-------|-------------|
| `opencode.nvim` | `<leader>a` | OpenCode embebido en terminal lateral |
| `claude-code.nvim` | `<leader>C` | Claude Code en split vertical |
| `avante.nvim` | `<leader>ai` | Asistente con diff view (keep/undo) |

### Editor

| Plugin | Descripcion |
|--------|-------------|
| `auto-save` | Guarda automaticamente al salir de Insert |
| `snacks.nvim` | Dashboard con accesos rapidos |
| `mini.diff` | Visualizacion de diffs |
| `toggleterm` | Terminal flotante con `<F4>` |
| `smart-splits.nvim` | Navegacion seamless entre splits de Neovim y panes de WezTerm |

### UI y navegacion

| Plugin | Descripcion |
|--------|-------------|
| `neo-tree` | Explorador de archivos lateral |
| `telescope` | Busqueda fuzzy de archivos/texto (`<leader>f`) |
| `barbar` | Pestañas/tabs en la parte superior |
| `heirline.nvim` | Barra de estado con colores kanagawa + winbar con breadcrumbs |
| `indent-blankline` | Guias de indentacion |
| `dressing` | UI mejorada para inputs y selects |

### LSP y formateo

| Plugin | Descripcion |
|--------|-------------|
| `nvim-lspconfig` + `mason` | LSP automatico con instalacion de servidores |
| `rustaceanvim` | LSP Rust extendido |
| `nvim-treesitter` | Syntax highlighting moderno |
| `conform` | Formateo automatico |

### Git

| Plugin | Atajo | Descripcion |
|--------|-------|-------------|
| `gitsigns` | `<leader>h` | Indicadores git, blame, stage/reset hunks |
| `mini.diff` | - | Resaltado de cambios en buffer |

### Debugging (DAP)

| Plugin | Atajo | Descripcion |
|--------|-------|-------------|
| `nvim-dap` | `<F1>`-`<F5>` | Debug Adapter Protocol |
| `nvim-dap-ui` | Auto | Panel lateral de debug |
| `nvim-dap-virtual-text` | Auto | Valores inline durante debug |
| `nvim-dap-go` | Auto | Configuracion Go predefinida |

## Atajos de teclado

> Presiona `<leader>` (Space) y espera: **which-key** mostrara todos los grupos disponibles.

### Navegacion de panes (smart-splits)

| Atajo | Contexto | Descripcion |
|-------|----------|-------------|
| `Ctrl+h/j/k/l` | Neovim | Mover entre splits. Al borde → cruza al pane de WezTerm |
| `Ctrl+h/j/k/l` | WezTerm | Mover entre panes. Si es Neovim → navega splits internos |
| `Alt+h/j/k/l` | Ambos | Redimensionar split/pane actual |

### IA

| Atajo | Modo | Descripcion |
|-------|------|-------------|
| `<leader>an` | n, t | OpenCode: nueva sesion |
| `<leader>ac` | n, t | OpenCode: continuar sesion |
| `<leader>aa` | n, x | OpenCode: enviar seleccion al prompt |
| `<leader>aA` | n, x | OpenCode: añadir @this al prompt |
| `<leader>ab` | n | OpenCode: enviar buffer completo |
| `<leader>ad` | n | OpenCode: enviar diagnosticos LSP |
| `<leader>av` | x | OpenCode: revisar seleccion |
| `<leader>cc` | n | LSP: Run Codelens |
| `<leader>ca` | n | LSP: Code Action |
| `<leader>cr` | n | LSP: Rename |
| `<leader>Cc` | n | Claude Code: toggle ventana |
| `<leader>Cn` | n | Claude Code: nueva sesion |
| `<leader>Cv` | n | Claude Code: abrir en vsplit |
| `<leader>Cs` | v | Claude Code: enviar seleccion |
| `<leader>CS` | n | Claude Code: guardar sesion |
| `<leader>Cb` | n | Claude Code: ver sesiones guardadas |
| `<leader>aia` | n, v | Avante: preguntar (con diff view) |
| `<leader>air` | n | Avante: refrescar respuesta |
| `<leader>aie` | n, v | Avante: editar seleccion |

### Debugging

| Atajo | Descripcion |
|-------|-------------|
| `<F1>` | Continuar / Iniciar debug |
| `<F2>` | Step into |
| `<F3>` | Step over |
| `<F4>` | Step out |
| `<F5>` | Step back |
| `<F13>` | Reiniciar debug |
| `<Space>b` | Toggle breakpoint |
| `<Space>gb` | Run to cursor |
| `<Space>?` | Evaluar variable bajo cursor |

### Git

| Atajo | Descripcion |
|-------|-------------|
| `<leader>gg` | Abrir Lazygit |
| `<leader>gb` | Git blame |
| `<leader>hs` | Stage hunk (gitsigns) |
| `<leader>hr` | Reset hunk (gitsigns) |
| `<leader>hS` | Stage buffer completo |
| `<leader>hR` | Reset buffer completo |
| `<leader>hp` | Previsualizar hunk |
| `<leader>hb` | Blame de linea |
| `<leader>hd` | Diff this |

### Navegacion

| Atajo | Descripcion |
|-------|-------------|
| `]c` | Siguiente cambio git |
| `[c` | Cambio git anterior |

### Terminal

| Atajo | Descripcion |
|-------|-------------|
| `<leader>tt` | Toggle terminal flotante |
| `<C-\>` | Toggle terminal (dentro de terminal) |

### Remote SSH

| Atajo | Descripcion |
|-------|-------------|
| `<leader>Rs` | Conectar / selector de hosts SSH |
| `<leader>Rx` | Desconectar sesion remota |
| `<leader>Rc` | Editar config de remote-nvim |
| `<leader>Ri` | Info de la conexion actual |

### Temas

| Atajo | Descripcion |
|-------|-------------|
| `<leader>ut` | Rotar tema (kanagawa → catppuccin-mocha → macchiato → frappé → latte → onedark...) |
| `<leader>ug` | Toggle transparencia ON/OFF |

## Guia rapida por lenguaje

### Rust

```bash
# Instalar rust-analyzer (via rustup o Mason)
rustup component add rust-analyzer
```

- LSP: `rustaceanvim` (mas completo que rust-analyzer standalone)
- Debugger: `codelldb` (instalar via `:Mason`)
- Formateador: `rustfmt` (incluido en rustup)

Para debuggear: coloca un breakpoint (`<Space>b`), presiona `<F1>` y selecciona "Launch Rust (codelldb)". Introduce la ruta al ejecutable (normalmente `./target/debug/nombre-proyecto`).

### C# / .NET

- LSP: `omnisharp` (instalar via `:Mason`)
- Debugger: `netcoredbg` (instalar via `:Mason`)
- Formateador: `csharpier` (instalar via `:Mason`)

Para debuggear: compila con `dotnet build`, coloca breakpoints (`<Space>b`), presiona `<F1>` y selecciona "Launch .NET (netcoredbg)". Introduce la ruta al .dll.

### Godot / GDScript

- LSP: integrado en Godot 4. Asegurate de que `godot` este en tu PATH.
- Treesitter: parsers `gdscript` y `gdshader` instalados automaticamente.

Para usar el LSP: abre cualquier archivo `.gd` y el LSP se conectara automaticamente al ejecutable `godot --headless --editor`. Requiere Godot 4+.

### Python

- LSP: `pyright` (instalado automaticamente via Mason)
- Linter: `flake8` (instalado via Mason)

### TypeScript / JavaScript

- LSP: `tsserver` (via LazyVim extras)
- Debugger: `js-debug-adapter` (instalar via `:Mason`)

## Personalizacion

Para añadir tus propios plugins:

1. Crea un archivo `.lua` en `lua/plugins/` (se carga automaticamente)
2. O modifica `lua/config/options.lua`, `keymaps.lua` o `autocmds.lua`

Para desactivar un plugin incluido:

```lua
-- En lua/plugins/disabled.lua
return {
  { "nombre/plugin", enabled = false }
}
```

## Troubleshooting

### Los plugins no se instalan

```bash
# Limpia el cache de lazy.nvim
rm -rf ~/.local/share/nvim/lazy
nvim
```

### El LSP no funciona en C#/Rust

Abre `:Mason` y verifica que el servidor este instalado. Si no, instalalo manualmente con `i` sobre el paquete.

### OpenCode no arranca

```bash
# Verifica que opencode este instalado
opencode --version

# Si falla la autenticacion, lanza opencode en terminal normal primero
# para hacer login
opencode
```

### Claude Code no arranca

```bash
# Verifica instalacion
claude --version

# Primera ejecucion requiere OAuth (abre navegador)
claude
```

### WezTerm: no se ven iconos en la tabline

Asegurate de que la Nerd Font este instalada y seleccionada en WezTerm. `install.sh` configura `CaskaydiaCove Nerd Font` automaticamente.

### WezTerm: error `'wezterm': unknown terminal type`

Ejecuta `./install.sh` — el instalador registra la terminfo de WezTerm automaticamente via `tic`.

### Avante no funciona

Asegurate de tener la variable de entorno `ANTHROPIC_API_KEY` configurada:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Documentacion completa

Guia de uso, primeros pasos con Neovim, y mas en la **wiki** del repositorio:

- Primeros pasos con Neovim — Si nunca has usado Neovim
- Guia de LazyVim — Atajos, Mason, extras, personalizacion
- AI Agents — OpenCode, Claude Code, Avante
- Debugging — DAP para C#, Rust, JS/TS, Go
- Rust / C# / Godot — Guias por lenguaje
- Troubleshooting — Solucion de problemas comunes

---

Basado en [LazyVim](https://github.com/LazyVim/LazyVim). Template original: [LazyVim/starter](https://github.com/LazyVim/starter).
