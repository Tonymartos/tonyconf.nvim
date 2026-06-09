# Rust Development

Configuracion optimizada para desarrollo Rust con rustaceanvim, codelldb y treesitter.

## Configuracion incluida

- **rustaceanvim**: LSP extendido para Rust (mas features que rust-analyzer standalone)
- **codelldb**: Debugger via LLDB
- **Treesitter**: Parsers `rust` y `ron`
- **Formateador**: `rustfmt` (incluido con rustup)

## Requisitos

```bash
# rustup + toolchain
rustup default stable
rustup component add rust-analyzer rustfmt clippy

# Debugger (instalar via Mason en Neovim)
:MasonInstall codelldb
```

## Configuracion LSP

El LSP esta configurado con:

- **Cargo features**: `all` (analiza todas las features)
- **Check on save**: `clippy` (pasa clippy al guardar, mas rapido que compilar)
- **Inlay hints**: activados por defecto via rustaceanvim

### Atajos de rustaceanvim

| Atajo | Accion |
|-------|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gr` | Go to references |
| `gD` | Go to declaration |
| `<leader>ca` | Code actions |

## Formateo

Al guardar (`:w`), `rustfmt` formatea automaticamente el archivo.

## Debugging

Ver guia completa en [Debugging](Debugging#rust-debugging).

Resumen rapido:
1. `cargo build`
2. `<Space>b` coloca breakpoints
3. `<F1>` → "Launch Rust (codelldb)"
4. Introduce ruta: `target/debug/tu-proyecto`

## Estructura tipica de proyecto

```
mi-proyecto/
├── Cargo.toml
├── Cargo.lock
├── src/
│   ├── main.rs
│   └── lib.rs
└── target/
    └── debug/
        └── mi-proyecto  ← debugger apunta aqui
```

## Consejos

- Usa `cargo watch -x check` en otra terminal para comprobaciones continuas
- rustaceanvim muestra el estado de cargo check en la barra de estado
- Para tests: `:RustRunnables` muestra todos los tests del proyecto
- Para debugging de tests: añade `#[cfg(test)]` y lanza el binario de test
