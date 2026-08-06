# tonyconf.nvim

Configuracion personal de Neovim basada en [LazyVim](https://github.com/LazyVim/LazyVim), optimizada para el stack **Rust + C#/.NET + Godot/GDScript + Python + TypeScript**.

## Tabla de contenidos

1. [Instalacion rapida](#instalacion-rapida)
2. [Estructura del repositorio](#estructura-del-repositorio)
3. [Guia de uso de IA](AI-Agents) - OpenCode, Claude Code, Avante
4. [Guia de Debugging](Debugging) - DAP para todos los lenguajes
5. [Rust Development](Rust-Development) - rustaceanvim + codelldb
6. [C# Development](CSharp-Development) - omnisharp + netcoredbg
7. [Godot/GDScript](Godot-GDScript) - LSP integrado
8. [Troubleshooting](Troubleshooting)

## Instalacion rapida

```bash
# Requisitos (instalador automatico en install.sh)

## Neovim >= 0.12 — SIEMPRE desde los releases oficiales de GitHub
# El instalador descarga la ultima version estable a ~/.local/bin/nvim (sin sudo):
#   ./install.sh --install-nvim
# (En macOS se instala/actualiza via Homebrew: brew install neovim)

## Arch (dependencias)
sudo pacman -S ripgrep fd

## Debian/Ubuntu (dependencias)
sudo apt install ripgrep fd-find

## Fedora (dependencias)
sudo dnf install ripgrep fd-find

# Herramientas de IA (opcionales)

## OpenCode
# Arch
sudo pacman -S opencode
# Debian/Fedora
npm i -g @opencode/cli
# o descarga el binario desde https://github.com/anomalyco/opencode/releases

## Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Instalacion de la config
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/Tonymartos/tonyconf.nvim.git ~/.config/nvim
nvim  # Instala plugins al arrancar
```

Despues de la instalacion, abre `:Mason` y presiona `i` en:
- `omnisharp`, `rust-analyzer` (LSP)
- `netcoredbg`, `codelldb` (Debuggers)
- `stylua`, `csharpier` (Formateadores)

## Estructura del repositorio

```
~/.config/nvim/
├── init.lua                        # Punto de entrada
├── lua/
│   ├── config/                     # Configuraciones base
│   └── plugins/                    # Plugins organizados por categoria
│       ├── ai/                     # IA: opencode, claude-code, avante
│       ├── editor/                 # Edicion: autosave, dash, toggleterm
│       ├── lang/                   # Lenguajes: rust, csharp, godot
│       ├── dap/                    # Debugging: C#, Rust, JS/TS, Go
│       ├── tools/                  # Herramientas: grug-far, remote-vim
│       └── ui/                     # Interfaz: neo-tree, telescope, lualine
```

## Atajos principales

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
