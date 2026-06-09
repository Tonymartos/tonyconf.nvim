# C# (.NET) Development

Configuracion para desarrollo C# con omnisharp, netcoredbg y csharpier.

## Configuracion incluida

- **omnisharp**: LSP para C# (Roslyn-based)
- **netcoredbg**: Debugger nativo para .NET en Linux
- **csharpier**: Formateador opinionado para C#
- **Treesitter**: Parsers `c_sharp`, `xml`, `csproj`
- **Conform**: Formateo automatico al guardar

## Requisitos

```bash
# .NET SDK

# Arch Linux
sudo pacman -S dotnet-sdk

# Debian/Ubuntu y Fedora
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin
```

Los LSP y debuggers se instalan via `:Mason` en Neovim:
```
:MasonInstall omnisharp netcoredbg csharpier
```

## Configuracion LSP

omnisharp esta configurado con:

- **Import completion**: activado
- **Organize imports on format**: activado (ordena `using` al formatear)
- **Roslyn analyzers**: activados (analisis completo)
- **Analiza todo el workspace**: `analyze_open_documents_only = false`

## Formateo

`csharpier` se ejecuta automaticamente al guardar el archivo.

Para formatear manualmente:
```vim
:Format   " o <leader>cf
```

## Debugging

Ver guia completa en [Debugging](Debugging#c-net-debugging).

Resumen rapido:
1. `dotnet build`
2. `<Space>b` coloca breakpoints
3. `<F1>` → "Launch .NET (netcoredbg)"
4. Introduce ruta: `bin/Debug/net9.0/tu-proyecto.dll`

## Atajos especificos de C#

| Atajo | Accion |
|-------|--------|
| `K` | Documentacion del simbolo |
| `gd` | Ir a definicion |
| `gr` | Ir a referencias |
| `<leader>ca` | Code actions (quick fix) |
| `<leader>rn` | Renombrar simbolo |

## Proyectos Godot + C#

Si estas usando Godot con C#:

1. Asegurate de que el proyecto Godot tenga un `.csproj` valido
2. Abre la solucion desde la raiz del proyecto Godot
3. omnisharp detectara automaticamente los paquetes NuGet y referencias de Godot
4. El formateo con `csharpier` funciona sobre cualquier archivo `.cs`

## Troubleshooting

### omnisharp no arranca

```bash
# Verifica que .NET SDK esta instalado
dotnet --version

# Si omnisharp falla, prueba instalar la version mono
:MasonInstall omnisharp-mono
```

### netcoredbg no encuentra el dll

- Compila con `dotnet build` primero
- La ruta por defecto asume `bin/Debug/`. No incluye `netX.Y/`.
- Para Godot, el dll suele estar en `.godot/mono/temp/bin/Debug/`

### Formateo no funciona

```bash
# Instala csharpier si no esta
:MasonInstall csharpier

# Verifica que conform esta activo
:ConformInfo
```
