# Troubleshooting

Soluciones a problemas comunes con tonyconf.nvim.

## Instalacion y arranque

### Los plugins no se instalan / errores al arrancar

```bash
# Limpia el cache de lazy.nvim y reinstala
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy
nvim
```

### Error "Failed to clone lazy.nvim"

```bash
# Verifica conexion a GitHub y git
git --version
git clone https://github.com/folke/lazy.nvim.git /tmp/test-lazy

# Si falla, prueba con SSH
# Edita lua/config/tonyconf.lua y cambia la URL a:
# "git@github.com:folke/lazy.nvim.git"
```

### Neovim muy antiguo

```bash
# Se requiere Neovim >= 0.12
nvim --version

# La forma recomendada: descargar la ultima version desde los releases oficiales de GitHub
./install.sh --install-nvim
# (descarga a ~/.local/bin/nvim, sin sudo)

# Alternativa: actualizar con el instalador
./install.sh --update-nvim

# En macOS se actualiza con:
brew upgrade neovim
```

> Nota: los gestores de paquetes (apt/dnf/pacman) suelen traer versiones antiguas
> de Neovim. Esta configuracion siempre se instala desde los
> [releases oficiales](https://github.com/neovim/neovim/releases) de GitHub.

## LSP / Mason

### Un LSP no se instala o no funciona

```bash
# Ver logs de mason
:MasonLog

# Reinstalar un paquete especifico
:MasonUninstall omnisharp
:MasonInstall omnisharp
```

### No hay autocompletado

1. Verifica que el LSP esta corriendo: `:LspInfo`
2. Si no aparece, instalalo: `:MasonInstall <servidor>`
3. Reinicia el LSP: `:LspRestart`

### Error "command not found" con algun LSP

Algunos LSPs requieren dependencias del sistema:

```bash
# omnisharp necesita .NET SDK
# Arch
dotnet --version || sudo pacman -S dotnet-sdk
# Debian/Ubuntu y Fedora
dotnet --version || curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin

# pyright necesita Node
# Arch
node --version || sudo pacman -S nodejs
# Debian/Ubuntu
node --version || sudo apt install nodejs
# Fedora
node --version || sudo dnf install nodejs
```

## Debugging (DAP)

### Error "netcoredbg not found"

```bash
:MasonInstall netcoredbg
```

El binario se instala en `~/.local/share/nvim/mason/packages/netcoredbg/`.

### Error "codelldb not found"

```bash
:MasonInstall codelldb
```

### El debugger arranca pero no para en breakpoints

- Verifica que compilaste en modo debug (sin `--release`)
- Para Rust: añade `[profile.dev] opt-level = 0` en Cargo.toml
- Para C#: compila con `dotnet build` (no `dotnet publish`)

### nvim-dap-ui no se abre

El panel se abre automaticamente al iniciar una sesion de debug. Si no aparece:
```vim
:DapUiOpen
```

## IA

### OpenCode no arranca en Neovim

```bash
# Verifica que esta instalado
opencode --version

# Ejecutalo en terminal normal primero (para login)
opencode
```

Si el servidor local no responde (error de conexion a 127.0.0.1:4096):
```bash
# Mata procesos huerfanos
pkill -f opencode
# Vuelve a intentar en Neovim
```

### Claude Code no arranca

```bash
# Verifica instalacion
claude --version

# Necesitas autenticacion via OAuth (solo primera vez)
claude
```

### Avante muestra error de API key

```bash
# Asegurate de que la variable existe
echo $ANTHROPIC_API_KEY

# Si no, configurala
export ANTHROPIC_API_KEY="sk-ant-api03-..."
# Añade a ~/.zshrc para que persista
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-..."' >> ~/.zshrc
```

## Git

### gitsigns no muestra indicadores

```bash
# Verifica que estas en un repo git
git status

# Si es un repo grande, gitsigns se desactiva en archivos >40000 lineas
```

### No puedo usar ]c / [c para navegar cambios

El conflicto de keymaps se maneja automaticamente: en modo diff usa los nativos de Vim, fuera de diff usa gitsigns.

## Rendimiento

### Neovim lento al arrancar

```bash
# Ver que plugins tardan mas
:Lazy profile

# Desactiva plugins que no uses
# Crea lua/plugins/disabled.lua:
return {
  { "plugin/lento", enabled = false }
}
```

### Mucho uso de CPU

- Verifica que no tengas multiples LSPs compitiendo: `:LspInfo`
- `rust-analyzer` puede usar mucha CPU en proyectos grandes. Ajusta:
  ```lua
  -- En lua/plugins/lang/rust.lua
  ["rust-analyzer"] = {
    checkOnSave = { command = "check" }, -- en vez de "clippy"
  }
  ```

## Restaurar configuracion limpia

```bash
# Backup de la actual
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d)
mv ~/.local/share/nvim ~/.local/share/nvim.bak.$(date +%Y%m%d)
mv ~/.local/state/nvim ~/.local/state/nvim.bak.$(date +%Y%m%d)

# Reinstalar
git clone https://github.com/Tonymartos/tonyconf.nvim.git ~/.config/nvim
nvim
```
