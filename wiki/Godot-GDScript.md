# Godot / GDScript Development

Soporte para desarrollo de juegos en Godot Engine con GDScript.

## Configuracion incluida

- **GDScript LSP**: usa el binario `godot --headless --editor` como servidor de lenguaje
- **Treesitter**: parsers para `gdscript` y `gdshader`

## Requisitos

Godot 4.x instalado y accesible en PATH:

```bash
# Arch Linux
sudo pacman -S godot

# Debian/Ubuntu
flatpak install flathub org.godotengine.Godot

# Fedora
sudo dnf install godot

# Verifica
godot --version
```

## Configuracion LSP

El LSP de GDScript esta integrado en Godot 4. No necesita instalacion adicional. Neovim se conecta automaticamente al abrir archivos `.gd`.

### Como funciona

1. Abres cualquier archivo `.gd` en Neovim
2. El LSP lanza `godot --headless --editor` en segundo plano
3. Godot analiza el proyecto y proporciona:
   - Autocompletado
   - Diagnostico de errores
   - Ir a definicion (`gd`)
   - Referencias (`gr`)
   - Documentacion en hover (`K`)

### Deteccion de proyecto

El LSP busca `project.godot` hacia arriba desde el archivo actual. Si no lo encuentra, usa `.git` como fallback.

## Atajos utiles

| Atajo | Accion |
|-------|--------|
| `K` | Documentacion del simbolo GDScript |
| `gd` | Ir a definicion de funcion/variable |
| `gr` | Buscar referencias |
| `<leader>ca` | Code actions |
| `<leader>rn` | Renombrar simbolo |

## Limitaciones conocidas

- El LSP de GDScript es mas lento que otros LSPs (Godot necesita parsear todo el proyecto)
- No soporta debugging DAP (nvim-dap no tiene adapter para GDScript)
- Para debugging de GDScript, usa el editor integrado de Godot o `--debug` en terminal

## Trabajando con C# en Godot

Si tu proyecto Godot usa C#, consulta la [guia de C#](CSharp-Development). El LSP de C# funciona independientemente del de GDScript.

### Configuracion recomendada para proyectos mixtos

1. Abre Neovim en la raiz del proyecto Godot
2. Los archivos `.gd` usaran el LSP de GDScript
3. Los archivos `.cs` usaran omnisharp
4. Ambos LSPs funcionan simultaneamente

### Generar solucion C#

Si Godot no genera automaticamente la solucion C#:
```
# En el editor Godot
Project > Tools > C# > Create C# solution
```

## Consejos

- Usa `gdformat` para formatear GDScript (instalar via pip: `pip install gdtoolkit`)
- Para proyectos grandes, el LSP de GDScript puede tardar en inicializarse. Se paciente.
- Si el LSP no responde, cierra Neovim, abre Godot Editor normalmente para que compile los scripts, luego vuelve a Neovim.
