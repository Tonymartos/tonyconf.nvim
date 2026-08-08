# Primeros pasos con Neovim

Guia interactiva desde cero para aprender Neovim con tonyconf. Cada seccion incluye ejercicios practicos que puedes probar mientras lees.

> **Abre el tutorial interactivo integrado:** `:Tutor` (en español). Este documento complementa el tutor oficial con las cosas especificas de tonyconf y LazyVim.

## 📖 Seccion 1 — Básico: Sobrevivir en Neovim

### 1.1 Los modos

Neovim tiene **modos**. No es como un editor normal donde siempre escribes. Esto es lo mas importante que debes entender:

| Modo | Como entrar | Que hace |
|------|------------|----------|
| **NORMAL** | `Esc` | Navegar, ejecutar comandos. Es el modo por defecto |
| **INSERT** | `i`, `a`, `o` | Escribir texto |
| **VISUAL** | `v` | Seleccionar texto |
| **VISUAL LINE** | `V` | Seleccionar lineas enteras |
| **COMMAND** | `:` | Ejecutar comandos (guardar, salir, buscar) |

> **Regla de oro:** cuando no sepas que esta pasando, pulsa `Esc` dos veces. Vuelves al modo NORMAL.

**Prueba ahora:**
1. Pulsa `i` → ves `-- INSERT --` abajo → estas en modo INSERT. Escribe algo.
2. Pulsa `Esc` → vuelves a NORMAL.
3. Pulsa `v` → ves `-- VISUAL --` → muevete con las flechas para seleccionar.
4. Pulsa `Esc` dos veces → vuelves a NORMAL.

### 1.2 Moverse por el texto

En modo NORMAL (pulsa `Esc` primero):

| Tecla | Accion | Truco mnemotecnico |
|-------|--------|-------------------|
| `h` | Izquierda | (la mas a la izquierda de hjkl) |
| `j` | Abajo | (parece una flecha hacia abajo) |
| `l` | Derecha | (la mas a la derecha de hjkl) |
| `k` | Arriba | (parece una flecha hacia arriba) |
| `w` | Siguiente **W**ord (palabra) | `w` = word |
| `b` | **B**ack (palabra anterior) | `b` = back |
| `e` | **E**nd de palabra | `e` = end |
| `0` | Inicio de linea | |
| `$` | Final de linea | (como regex) |
| `gg` | Inicio del archivo | |
| `G` | Final del archivo | |
| `Ctrl+d` | Media pagina abajo | |
| `Ctrl+u` | Media pagina arriba | |

**Prueba ahora:**
1. Abre este mismo archivo y practica moverte solo con `hjkl` (sin flechas).
2. Navega palabra por palabra con `w` y `b`. Nota como `w` salta al inicio de la siguiente palabra.
3. Salta al inicio del archivo con `gg`, al final con `G`.
4. Vuelve a tu posicion anterior con `Ctrl+o`.

### 1.3 Editar texto

En modo NORMAL:

| Tecla | Accion |
|-------|--------|
| `i` | **I**nsert antes del cursor |
| `a` | **A**ppend (insert despues del cursor) |
| `o` | Nueva linea debajo y entrar en INSERT |
| `O` | Nueva linea arriba y entrar en INSERT |
| `x` | Borrar caracter bajo el cursor |
| `dd` | Borrar linea entera |
| `yy` | Copiar (yank) linea entera |
| `p` | **P**egar despues del cursor |
| `u` | **U**ndo (deshacer) |
| `Ctrl+r` | **R**edo (rehacer) |
| `.` | Repetir el ultimo cambio |

**Prueba ahora:**
1. Pulsa `dd` para borrar una linea. Pulsa `u` para deshacer.
2. Pulsa `yy` para copiar una linea. Pulsa `p` para pegarla abajo.
3. Pulsa `x` para borrar un caracter. Pulsa `p` para "pegarlo" (intercambiar).
4. Escribe algo, sal a NORMAL con `Esc`, pulsa `u`. Ves como se deshace.

### 1.4 Guardar, salir, buscar

En modo NORMAL, pulsa `:` para entrar en modo COMMAND:

| Comando | Accion |
|---------|--------|
| `:w` | **W**rite (guardar) |
| `:q` | **Q**uit (salir) |
| `:wq` | Guardar y salir |
| `:q!` | Salir sin guardar |
| `/texto` | Buscar "texto" hacia adelante |
| `?texto` | Buscar "texto" hacia atras |
| `n` | Siguiente resultado de busqueda |
| `N` | Resultado anterior de busqueda |
| `:%s/viejo/nuevo/g` | Reemplazar "viejo" por "nuevo" en todo el archivo |

**Prueba ahora:**
1. Busca "Neovim" con `/Neovim` y navega con `n` / `N`.
2. Para quitar el resaltado: `:noh` (no highlight).

### 1.5 Lo minimo para trabajar

Ya sabes suficiente para editar archivos. Resumen minimo:

```
Esc        → modo NORMAL (tu casa)
i          → INSERT (escribes)
Esc        → vuelves a NORMAL
:w         → guardas
:q         → sales
hjkl       → te mueves
w b        → saltas palabras
dd         → borras linea
yy p       → copias y pegas
u Ctrl+r   → deshaces y rehaces
```

---

## 🚀 Seccion 2 — Intermedio: Potencia LazyVim

### 2.1 El leader key

En tonyconf, la tecla **leader** es `Space`. No hace nada por si sola: es un prefijo para atajos.

Pulsa `<Space>` y **espera medio segundo**: aparece el menu de **which-key** con todos los atajos disponibles.

```
   a  +AI        c  +Claude      f  +Find
   g  +Git       h  +Hunks       s  +Search
   u  +UI        x  +Diagnostics
```

**Prueba ahora:**
1. Pulsa `<Space>` y espera. Navega por los grupos con el raton o tecleando la letra.
2. Busca atajos: `<Space>sk` (search keymaps) y escribe "format".

### 2.2 Buscar archivos y texto

| Atajo | Accion |
|-------|--------|
| `<Space>f` | Buscar archivos (fuzzy) |
| `<Space>F` | Buscar archivos desde la raiz git |
| `<Space>/` | Buscar texto en el proyecto (grep) |
| `<Space>fr` | Archivos recientes |
| `<Space>fb` | Buscar en buffers abiertos |
| `<Space>fh` | Buscar en el historial de busquedas |

> El buscador fuzzy te permite escribir partes del nombre. Por ejemplo `mod/us` encuentra `models/user.rb`.

**Prueba ahora:**
1. `<Space>f` y escribe `init.lua` — se abre al instante.
2. `<Space>/` y busca "tonymartos" en el proyecto.

### 2.3 Ventanas y pestañas (splits y tabs)

| Atajo | Accion |
|-------|--------|
| `<C-h/j/k/l>` | Moverte entre splits (y cruzar a panes de WezTerm) |
| `<leader>\|` | Split vertical |
| `<leader>-` | Split horizontal |
| `<leader>wd` | Cerrar split actual |
| `<leader>wq` | Cerrar todos menos el actual |
| `Ctrl+Shift+T` | Nueva pestaña (tab) |
| `Ctrl+Shift+W` | Cerrar pestaña actual |
| `Ctrl+Tab` | Siguiente pestaña |

**Prueba ahora:**
1. Abre dos archivos con `<Space>f`.
2. Divide la pantalla: `<leader>\|` para split vertical.
3. Navega entre ellos con `Ctrl+h` y `Ctrl+l`.

### 2.4 Explorador de archivos

| Atajo | Accion |
|-------|--------|
| `<Space>e` | Abrir/cerrar explorador (neo-tree) |
| `<Space>E` | Abrir explorador alternativo |

Dentro del explorador:
- `a` = crear archivo, `d` = borrar, `r` = renombrar
- `m` = mover, `c` = copiar
- `Enter` = abrir archivo
- `H` = mostrar/ocultar archivos ocultos

### 2.5 Git integrado

| Atajo | Accion |
|-------|--------|
| `<leader>gg` | Abrir Lazygit (interfaz grafica de git) |
| `<leader>gb` | Git blame (quien escribio cada linea) |
| `<leader>hs` | Stage hunk (añadir cambios al commit) |
| `<leader>hr` | Reset hunk (descartar cambios) |
| `<leader>hp` | Previsualizar cambios del hunk |

Dentro de Lazygit:
- `Tab` = cambiar entre paneles
- `h`/`l` = colapsar/expandir
- `a` = stage all, `c` = commit
- `P` = push, `p` = pull
- `q` = salir

**Prueba ahora:**
1. Abre un archivo en un repo git, modifica algo y guarda.
2. Pulsa `<leader>hp` para ver el diff del cambio.
3. Pulsa `<leader>gg` para abrir Lazygit y commitear.

### 2.6 LSP: autocompletado y ayuda

| Atajo | Accion |
|-------|--------|
| `<leader>K` | Mostrar documentacion del simbolo bajo el cursor |
| `gd` | **G**o to **D**efinition (ir a la definicion) |
| `gr` | **G**o to **R**eferences (ver referencias) |
| `gD` | Ir a la declaracion |
| `gi` | Ir a la implementacion |
| `[d` / `]d` | Anterior / siguiente diagnostico (error/aviso) |
| `<leader>ca` | **C**ode **A**ction (acciones disponibles: renombrar, importar...) |
| `<leader>rn` | **R**e**n**ame (renombrar simbolo en todo el proyecto) |
| `Ctrl+k` | Mostrar firma de la funcion (signature help) |

**Prueba ahora:**
1. Abre un archivo de Rust, C#, o TypeScript. Pon el cursor sobre una funcion.
2. Pulsa `<Space>K` para ver la documentacion.
3. Pulsa `gd` para saltar a la definicion.
4. Vuelve con `Ctrl+o`.

### 2.7 Formateo

| Atajo | Accion |
|-------|--------|
| `<leader>cf` | Formatear archivo o seleccion |
| `<leader>cF` | Formatear archivo completo |

El formateo usa el formateador configurado para cada lenguaje (`stylua` para Lua, `csharpier` para C#, `prettier` para JS/TS...).

### 2.8 Terminal integrada

| Atajo | Accion |
|-------|--------|
| `<F4>` | Terminal flotante (toggle) |
| `<leader>tt` | Terminal flotante |

Dentro de la terminal:
- Pulsa `<F4>` de nuevo para ocultarla
- `Ctrl+\` para alternar entre terminal normal y modo NORMAL
- En modo NORMAL dentro de la terminal puedes usar `hjkl`, copiar con `y`, etc.

### 2.9 Comentarios

| Atajo | Accion |
|-------|--------|
| `gc` | Toggle comentario (linea actual o seleccion) |
| `gcc` | Toggle comentario en la linea actual |
| `gc` + movimiento | Comentar desde el cursor hasta donde te muevas |

**Prueba ahora:**
1. Selecciona 3 lineas con `V` + `j` + `j`.
2. Pulsa `gc`. Las 3 lineas se comentan.
3. Pulsa `gcc` en una linea suelta para comentar/descomentar.

---

## ⚡ Seccion 3 — Avanzado: IA, debugging y mas

### 3.1 Copilot / OpenCode / Claude Code

| Atajo | Accion |
|-------|--------|
| `<leader>an` | OpenCode: nueva sesion |
| `<leader>ac` | OpenCode: continuar sesion |
| `<leader>aa` | OpenCode: enviar seleccion al prompt |
| `<leader>ab` | OpenCode: enviar buffer completo |
| `<leader>ad` | OpenCode: enviar diagnosticos LSP |
| `<leader>Cc` | Claude Code: toggle ventana |
| `<leader>Cn` | Claude Code: nueva sesion |
| `<leader>Cv` | Claude Code: abrir en vsplit |
| `<leader>Cs` | Claude Code: enviar seleccion |
| `<leader>CS` | Claude Code: guardar sesion |
| `<leader>Cb` | Claude Code: ver sesiones guardadas |
| `<leader>aia` | Avante: preguntar con diff view |
| `<leader>air` | Avante: refrescar respuesta |
| `<leader>aie` | Avante: editar seleccion |

**Prueba ahora:**
1. Abre un archivo de codigo.
2. Selecciona una funcion con `v` + movimiento.
3. Pulsa `<Space>aa` para preguntarle a OpenCode sobre esa seleccion.
4. Pulsa `<Space>Cc` para abrir Claude Code.

### 3.2 Debugging (DAP)

| Atajo | Accion |
|-------|--------|
| `<F1>` | Iniciar / continuar debug |
| `<F2>` | Step into (entrar en la funcion) |
| `<F3>` | Step over (siguiente linea) |
| `<F4>` | Step out (salir de la funcion) |
| `<F5>` | Step back (paso atras) |
| `<Space>b` | Toggle breakpoint |
| `<Space>gb` | Run to cursor (ejecutar hasta donde esta el cursor) |
| `<Space>?` | Evaluar variable bajo cursor |

### 3.3 Buscar y reemplazar avanzado

| Atajo | Accion |
|-------|--------|
| `<leader>r` | Buscar y reemplazar en el proyecto (grug-far) |
| `<leader>R` | Buscar y reemplazar en archivos abiertos |

Dentro de grug-far:
- Escribes el patron a buscar y el reemplazo
- `Tab` para cambiar entre campos
- `Enter` sobre un resultado para ver el diff
- `Ctrl+s` para aplicar todos los cambios

### 3.4 Tema y apariencia

| Atajo | Accion |
|-------|--------|
| `<leader>ut` | Rotar tema (kanagawa → catppuccin → onedark...) |
| `<leader>ug` | Toggle transparencia |
| `<leader>uf` | Elegir fuente (si esta configurado) |

### 3.5 Plugins y configuracion

| Comando | Accion |
|---------|--------|
| `:Lazy` | Abrir gestor de plugins (instalar, actualizar, limpiar) |
| `:LazyExtras` | Ver extras de LazyVim disponibles |
| `:Mason` | Instalar/actualizar LSP, debuggers, formateadores |
| `:checkhealth` | Diagnosticar problemas de configuracion |

Dentro de `:Lazy`:
- `U` = actualizar todos los plugins
- `S` = sincronizar (instalar faltantes, limpiar huerfanos)
- `C` = limpiar plugins no usados
- `d` = mostrar diff del ultimo update de un plugin

### 3.6 Codificacion avanzada

| Atajo | Accion |
|-------|--------|
| `Alt+h/j/k/l` | Redimensionar split/pane |
| `<leader>hm` | Stage hunk modificado |
| `<leader>hR` | Reset buffer completo |
| `<leader>gf` | Abrir archivo bajo cursor (go to file) |
| `Ctrl+o` | Volver a posicion anterior en el historial de saltos |
| `Ctrl+i` | Avanzar en el historial de saltos |
| `%` | Saltar al par de parentesis/llave/corchete |

---

## 🛠️ Seccion 4 — Solucion de problemas frecuentes

### No se instalan los plugins

```bash
rm -rf ~/.local/share/nvim/lazy
nvim
```

### Los iconos se ven como cuadrados

Significa que la Nerd Font no esta instalada o no esta seleccionada en WezTerm. Ejecuta `./install.sh` de nuevo (instala `CaskaydiaCove Nerd Font` automaticamente).

### El LSP no arranca

1. Abre `:Mason` y verifica que el servidor LSP este instalado (icono verde)
2. Abre `:Lazy` y verifica que `nvim-lspconfig` y `mason.nvim` esten cargados
3. `:LspInfo` para ver que servidores estan activos

### OpenCode no funciona

```bash
# Verifica que esta instalado
opencode --version

# Si falla, reinstala desde install.sh:
./install.sh --install-nvim
```

### No puedo salir de Neovim

> `Esc` + `Esc` + `:q!` + `Enter`

Si todo falla: cierra la terminal. No pasa nada, Neovim guarda los archivos modificados como swap files.

---

## 📚 Recursos adicionales

- **Tutorial interactivo:** `:Tutor` (en español)
- **Ayuda integrada:** `:help lazyvim` o `:help vim-modes`
- **[LazyVim docs](https://lazyvim.org)** — documentacion oficial
- **[Neovim docs](https://neovim.io/doc/user/)** — manual completo
- **Atajos de este documento:** pulsa `<Space>` y espera para verlos todos

---

> **Siguiente paso:** [Guia de IA](AI-Agents) — aprende a usar OpenCode, Claude Code y Avante dentro de Neovim.
