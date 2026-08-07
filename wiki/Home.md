# tonyconf.nvim

Configuracion personal de Neovim basada en [LazyVim](https://github.com/LazyVim/LazyVim), optimizada para el stack **Rust + C#/.NET + Godot/GDScript + Python + TypeScript**.

Incluye integracion completa con **WezTerm** (tabline, smart-splits, tema kanagawa) y configuracion de **ZSH** (starship, autosuggestions, fzf, zoxide).

## Tabla de contenidos

1. [Instalacion rapida](#instalacion-rapida)
2. [Terminal (WezTerm + ZSH)](#terminal-wezterm--zsh)
3. [Estructura del repositorio](#estructura-del-repositorio)
4. [Guia de uso de IA](AI-Agents) - OpenCode, Claude Code, Avante
5. [Guia de Debugging](Debugging) - DAP para todos los lenguajes
6. [Rust Development](Rust-Development) - rustaceanvim + codelldb
7. [C# Development](CSharp-Development) - omnisharp + netcoredbg
8. [Godot/GDScript](Godot-GDScript) - LSP integrado
9. [Troubleshooting](Troubleshooting)

## Instalacion rapida

```bash
# Clona y ejecuta el instalador automatico
git clone https://github.com/Tonymartos/tonyconf.nvim.git /tmp/tonyconf
cd /tmp/tonyconf
./install.sh
```

El instalador (`install.sh`) se encarga de todo:

| Paso | Que instala |
|------|-------------|
| 1 | Dependencias base (git, curl, ripgrep, fd, node, python, gcc, lazygit, lazydocker) |
| 2 | Neovim >= 0.12 (desde GitHub releases si no existe o es muy antiguo) |
| 3 | Nerd Font (CaskaydiaCove por defecto, 8 alternativas disponibles) |
| 4 | Config de Neovim (~/.config/nvim) |
| 5 | Plugins (lazy.nvim), parsers de treesitter, paquetes Mason |
| 6 | Herramientas de IA (OpenCode + Claude Code) |
| 7 | Config de WezTerm (tema kanagawa + tabline + smart-splits + terminfo) |
| 8 | Config de ZSH (starship + autosuggestions + syntax-hl + fzf + zoxide) |

```bash
# Opciones
./install.sh --base                 # Minima: sin IA ni terminal
./install.sh --base --with-ai       # Minima + herramientas de IA
./install.sh --with-fonts=FiraCode  # Cambia la Nerd Font
./install.sh --install-nvim         # Fuerza reinstalar Neovim
./install.sh --update-nvim          # Comprueba y actualiza Neovim
./install.sh --dry-run              # Muestra que haria sin ejecutar
```

### Instalacion manual

```bash
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/Tonymartos/tonyconf.nvim.git ~/.config/nvim
nvim  # Instala plugins al arrancar
```

Despues, abre `:Mason` y presiona `i` en los servidores LSP, debuggers y formateadores que necesites.

## Terminal (WezTerm + ZSH)

`install.sh` configura el ecosistema de terminal completo:

### WezTerm

- **Tema**: Kanagawa Wave (oscuro, azul profundo, cero rosa)
- **Tabline**: `tabline.wez` con CPU, RAM, reloj, workspace, hostname, domain (SSH/WSL/Docker)
- **Smart-splits**: `Ctrl+h/j/k/l` navega entre panes de WezTerm y splits de Neovim sin friccion
- **Fuente**: CaskaydiaCove Nerd Font (seleccionable en instalacion)
- **Terminfo**: registrada automaticamente para `$TERM=wezterm`

### ZSH

- **Prompt**: Starship con git branch, status, duracion de comandos
- **Autosuggestions**: sugerencias grises tipo fish (→ para aceptar)
- **Syntax highlighting**: comandos validos en verde, invalidos en rojo
- **FZF**: `Ctrl+R` busca historial, `Ctrl+T` busca archivos
- **Zoxide**: `z` en vez de `cd`, aprende tus rutas frecuentes

```bash
# Despues de instalar, cambia tu shell por defecto:
chsh -s /usr/bin/zsh
```

## Estructura del repositorio

```
tonyconf.nvim/
├── init.lua                        # Punto de entrada
├── install.sh                      # Instalador automatico
├── README.md
├── extras/                         # Configs de terminal
│   ├── wezterm.lua                 # WezTerm: kanagawa + tabline + smart-splits
│   ├── wezterm.terminfo            # Terminfo de WezTerm
│   ├── zshrc                       # ZSH: starship + plugins
│   ├── starship.toml               # Starship prompt customizado
│   └── alacritty.toml              # Alacritty (legacy)
├── wiki/                           # Documentacion
└── lua/
    ├── config/                     # Configuraciones base
    └── plugins/                    # Plugins organizados por categoria
        ├── ai/                     # IA: opencode, claude-code, avante
        ├── editor/                 # Edicion: autosave, dash, toggleterm, smart-splits
        ├── lang/                   # Lenguajes: rust, csharp, godot
        ├── dap/                    # Debugging: C#, Rust, JS/TS, Go
        ├── tools/                  # Herramientas: grug-far, remote-vim
        └── ui/                     # Interfaz: heirline, neo-tree, telescope, kanagawa
```

## Atajos principales

### Navegacion de panes (smart-splits)

| Atajo | Accion |
|-------|--------|
| `Ctrl+h/j/k/l` | Mover entre splits Neovim ↔ panes WezTerm |
| `Alt+h/j/k/l` | Redimensionar split/pane |

### Neovim

| Prefijo | Herramienta |
|---------|-------------|
| `<leader>a` | OpenCode |
| `<leader>c` | Claude Code |
| `<leader>ai` | Avante |
| `<leader>h` | Git (gitsigns) |
| `<leader>f` | Busqueda (telescope) |
| `<F1>-<F5>` | Debugging (DAP) |
| `<F4>` | Terminal flotante |

`<leader>` = `Space`
