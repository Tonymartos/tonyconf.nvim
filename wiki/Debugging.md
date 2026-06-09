# Guia de Debugging (DAP)

Esta configuracion incluye **nvim-dap** con soporte para C# (.NET), Rust, Go y JavaScript/TypeScript.

## Arquitectura

- **nvim-dap**: cliente DAP (Debug Adapter Protocol) para Neovim
- **nvim-dap-ui**: panel lateral con variables, call stack, breakpoints
- **nvim-dap-virtual-text**: valores de variables inline durante el debug
- **nvim-dap-go**: configuracion predefinida para Go

## Atajos globales

| Atajo | Accion |
|-------|--------|
| `<F1>` | Iniciar / Continuar debug |
| `<F2>` | Step into |
| `<F3>` | Step over |
| `<F4>` | Step out |
| `<F5>` | Step back |
| `<F13>` | Reiniciar debug |
| `<Space>b` | Toggle breakpoint |
| `<Space>gb` | Run to cursor |
| `<Space>?` | Evaluar variable bajo cursor |

## C# (.NET) Debugging

### Requisitos

Instala el debugger via Mason:

```
:MasonInstall netcoredbg
```

### Configuracion de lanzamiento

1. Compila tu proyecto: `dotnet build`
2. Coloca breakpoints con `<Space>b` en las lineas deseadas
3. Presiona `<F1>`
4. Selecciona **"Launch .NET (netcoredbg)"**
5. Introduce la ruta al `.dll` (ej: `bin/Debug/net9.0/tu-proyecto.dll`)

Tambien puedes seleccionar **"Attach .NET (netcoredbg)"** para conectar a un proceso .NET ya en ejecucion.

### Troubleshooting C#

- **Error "netcoredbg not found"**: Instala con `:MasonInstall netcoredbg`
- **El debugger no se conecta**: Asegurate de compilar con `dotnet build` antes de debuggear
- **No encuentra el dll**: La ruta por defecto es `<workspace>/bin/Debug/`. Ajustala segun tu proyecto.

## Rust Debugging

### Requisitos

Instala el debugger via Mason:

```
:MasonInstall codelldb
```

### Configuracion de lanzamiento

1. Compila tu proyecto: `cargo build`
2. Coloca breakpoints con `<Space>b`
3. Presiona `<F1>`
4. Selecciona **"Launch Rust (codelldb)"**
5. Introduce la ruta al ejecutable (ej: `target/debug/tu-proyecto`)

### Troubleshooting Rust

- **Error "codelldb not found"**: Instala con `:MasonInstall codelldb`
- **Variables no se muestran**: Compila sin optimizaciones. En `Cargo.toml`:
  ```toml
  [profile.dev]
  opt-level = 0
  ```
- **No encuentra el binario**: La ruta por defecto es `target/debug/`. Usa `cargo build` antes.

## JavaScript / TypeScript Debugging

### Requisitos

Instala el debugger via Mason:

```
:MasonInstall node-debug2-adapter
```

### Configuracion de lanzamiento

**Node (archivo actual):**
1. Abre el archivo `.js` o `.ts`
2. `<Space>b` para breakpoints
3. `<F1>` → selecciona "Launch Node (current file)"

**Attach a proceso:**
1. `<F1>` → selecciona "Attach to Node process"
2. Selecciona el PID del proceso Node

### Troubleshooting JS/TS

- **Error "node-debug2-adapter not found"**: `:MasonInstall node-debug2-adapter`
- **No para en breakpoints**: Asegurate de que `sourceMaps` este activado (lo esta por defecto)
- **TypeScript no debuggea correctamente**: Necesitas sourcemaps generados en tu config de TS

## Go Debugging

### Requisitos

Go debugging usa `dlv` (Delve). Instalalo:

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

La configuracion esta manejada por `nvim-dap-go` (preconfigurado).

### Uso

1. Coloca breakpoints con `<Space>b`
2. `<F1>` para iniciar debug
3. Sigue los mismos atajos que otros lenguajes

## Panel de Debug UI

El panel `nvim-dap-ui` se abre/cierra automaticamente al iniciar/terminar una sesion de debug.

El panel muestra:
- **Variables**: scope local y global
- **Call Stack**: pila de llamadas
- **Breakpoints**: lista de breakpoints activos
- **Watches**: expresiones vigiladas

Para evaluar una variable:
1. Situa el cursor sobre la variable
2. `<Space>?` para evaluar

## Notas de seguridad

La configuracion de `nvim-dap-virtual-text` oculta variables que contengan "secret" o "api" en su nombre o valor para evitar leaks accidentales de tokens.
