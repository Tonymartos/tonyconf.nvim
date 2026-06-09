```
████████╗ ██████╗ ███╗   ██╗██╗   ██╗██╗   ██╗██╗███╗   ███╗
╚══██╔══╝██╔═══██╗████╗  ██║╚██╗ ██╔╝██║   ██║██║████╗ ████║
   ██║   ██║   ██║██╔██╗ ██║ ╚████╔╝ ██║   ██║██║██╔████╔██║
   ██║   ██║   ██║██║╚██╗██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
   ██║   ╚██████╔╝██║ ╚████║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
```

Configuracion de Neovim basada en [LazyVim](https://github.com/LazyVim/LazyVim), optimizada para desarrollo en **Rust**, **C# (.NET)**, **Godot/GDScript**, **Python**, **TypeScript** y multiples herramientas de IA.

## Requisitos

- Neovim >= 0.10
- [git](https://git-scm.com)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
  - Arch: `sudo pacman -S ripgrep`
  - Debian/Ubuntu: `sudo apt install ripgrep`
  - Fedora: `sudo dnf install ripgrep`
  - macOS: `brew install ripgrep`
- [fd](https://github.com/sharkdp/fd)
  - Arch: `sudo pacman -S fd`
  - Debian/Ubuntu: `sudo apt install fd-find`
  - Fedora: `sudo dnf install fd-find`
  - macOS: `brew install fd`
- Nerd Font — necesaria para que se vean los iconos en el dashboard y la statusline.
  **No cambia la fuente de Neovim por si sola.** Para cambiar la fuente en Neovim
  debes configurar tu terminal. Si usas Alacritty, copia el archivo de ejemplo mas abajo.

  Antes de elegir una fuente, puedes previsualizar los iconos y estilos en
  [nerdfonts.com](https://www.nerdfonts.com/font-downloads).

  ```bash
  # Elige una Nerd Font de entre 9 opciones:
  ./install.sh --with-fonts
  # (JetBrains Mono por defecto si ejecutas sin interaccion)

  # O especifica una directamente:
  ./install.sh --with-fonts=CascadiaCode
  ./install.sh --with-fonts=FiraCode
  # Opciones: JetBrainsMono, CascadiaCode, FiraCode, Hack, SourceCodePro,
  #            UbuntuMono, DejaVuSansMono, Noto, Iosevka
  ```

  > **Para aplicar la fuente en Neovim:** copia [`extras/alacritty.toml`](extras/alacritty.toml)
  > en `~/.config/alacritty/alacritty.toml` y reinicia Alacritty. Si usas otro terminal
  > (kitty, wezterm, etc.), configura la fuente en su archivo de configuracion.

### Herramientas de IA (opcionales)

- **[OpenCode](https://github.com/anomalyco/opencode)**
  - Arch: `sudo pacman -S opencode`
  - Debian/Fedora: descarga el binario desde [releases](https://github.com/anomalyco/opencode/releases) o `npm i -g @opencode/cli`
- **[Claude Code](https://claude.ai)**: `curl -fsSL https://claude.ai/install.sh | bash`
- **Avante**: requiere `ANTHROPIC_API_KEY` en entorno

## Instalacion

### Automatica (recomendada)

```bash
# Descarga el script y ejecutalo
curl -fsSL https://forge.tonymartos.com/tonymartos/tonyconf.nvim/raw/branch/main/install.sh -o install.sh
chmod +x install.sh

# Instalacion minima (dependencias + neovim + config + plugins)
./install.sh

# Instalacion completa para desarrollador (con IA y fonts)
./install.sh --all

# Si tu distro tiene nvim < 0.10, fuerza instalacion via GitHub:
./install.sh --install-nvim

# Actualizar neovim (solo si se instalo via --install-nvim):
./install.sh --update-nvim
```

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
| `node-debug2-adapter` | JavaScript / TypeScript |
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
~/.config/nvim/
├── init.lua                        # Punto de entrada
├── stylua.toml                     # Formateador Lua
├── lua/
│   ├── config/
│   │   ├── tonyconf.lua            # Bootstrap lazy.nvim + LazyVim
│   │   ├── options.lua             # Opciones globales de Vim
│   │   ├── keymaps.lua             # Atajos adicionales
│   │   ├── autocmds.lua            # Autocomandos adicionales
│   │   └── grug-file-options.lua   # Config de grug-far
│   └── plugins/
│       ├── ai/                     # Plugins de IA
│       │   ├── opencode.lua        # OpenCode integrado en terminal
│       │   ├── claude-code.lua     # Claude Code integrado en terminal
│       │   └── avante.lua          # Asistente con diff/keep/undo
│       ├── editor/                 # Plugins de edicion
│       │   ├── autosave.lua        # Auto-guardado
│       │   ├── dash.lua            # Dashboard de inicio
│       │   ├── minidiff.lua        # Visualizacion de diffs
│       │   └── toggleterm.lua      # Terminal flotante
│       ├── lang/                   # Soporte de lenguajes
│       │   ├── rust.lua            # Rust (rustaceanvim)
│       │   ├── csharp.lua          # C#/.NET (omnisharp + netcoredbg)
│       │   └── godot.lua           # Godot/GDScript
│       ├── dap/                    # Debugging
│       │   └── nvim-dap.lua        # DAP: C#, Rust, JS/TS, Go
│       ├── tools/                  # Herramientas
│       │   ├── grug-far.lua        # Busqueda y reemplazo
│       │   ├── remote-vim.lua      # Edicion remota via SSH
│       │   └── imgclip.lua         # Pegar imagenes
│       └── ui/                     # Interfaz
│           ├── init.lua            # Plugins core: neo-tree, telescope, etc
│           ├── dressing.lua        # UI para inputs/selects
│           └── gitsigns.lua        # Indicadores git en gutter
```

## Plugins incluidos

### IA / Asistentes

| Plugin | Atajo | Descripcion |
|--------|-------|-------------|
| `opencode.nvim` | `<leader>a` | OpenCode embebido en terminal lateral |
| `claude-code.nvim` | `<leader>c` | Claude Code en split vertical |
| `avante.nvim` | `<leader>ai` | Asistente con diff view (keep/undo) |

### Editor

| Plugin | Descripcion |
|--------|-------------|
| `auto-save` | Guarda automaticamente al salir de Insert |
| `snacks.nvim` | Dashboard con accesos rapidos |
| `mini.diff` | Visualizacion de diffs |
| `toggleterm` | Terminal flotante con `<F4>` |

### UI y navegacion

| Plugin | Descripcion |
|--------|-------------|
| `neo-tree` | Explorador de archivos lateral |
| `telescope` | Busqueda fuzzy de archivos/texto (`<leader>f`) |
| `barbar` | Pestañas/tabs en la parte superior |
| `lualine` | Barra de estado |
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

### Lider

`<leader>` = `Space`

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
| `<leader>cc` | n | Claude Code: toggle ventana |
| `<leader>cn` | n | Claude Code: nueva sesion |
| `<leader>cv` | n | Claude Code: abrir en vsplit |
| `<leader>cs` | v | Claude Code: enviar seleccion |
| `<leader>cS` | n | Claude Code: guardar sesion |
| `<leader>cb` | n | Claude Code: ver sesiones guardadas |
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

### Git (gitsigns)

| Atajo | Descripcion |
|-------|-------------|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer completo |
| `<leader>hR` | Reset buffer completo |
| `<leader>hp` | Previsualizar hunk |
| `<leader>hb` | Blame de linea |
| `<leader>hd` | Diff this |
| `<leader>tb` | Toggle blame inline |

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

### Temas

| Atajo | Descripcion |
|-------|-------------|
| `<leader>ut` | Rotar tema (mocha → macchiato → frappé → latte → onedark → mocha...) |
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
- Debugger: `node-debug2-adapter` (instalar via `:Mason`)

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

### Avante no funciona

Asegurate de tener la variable de entorno `ANTHROPIC_API_KEY` configurada:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Documentacion completa

Guia de uso, primeros pasos con Neovim, y mas en la **[Wiki](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki)**:

- [Primeros pasos con Neovim](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/Primeros-pasos-con-Neovim) - Si nunca has usado Neovim
- [Guia de LazyVim](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/Guia-de-LazyVim) - Atajos, Mason, extras, personalizacion
- [AI Agents](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/AI-Agents) - OpenCode, Claude Code, Avante
- [Debugging](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/Debugging) - DAP para C#, Rust, JS/TS, Go
- [Rust](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/Rust-Development) / [C#](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/CSharp-Development) / [Godot](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/Godot-GDScript)
- [Troubleshooting](https://forge.tonymartos.com/tonymartos/tonyconf.nvim/wiki/Troubleshooting)

---

Basado en [LazyVim](https://github.com/LazyVim/LazyVim). Template original: [LazyVim/starter](https://github.com/LazyVim/starter).
