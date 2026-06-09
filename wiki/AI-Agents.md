# Guia de IA: OpenCode, Claude Code y Avante

Esta configuracion incluye tres herramientas de IA con diferentes propositos. Aprende a usarlas eficientemente.

## OpenCode (`<leader>a`)

**Proposito:** Agente autonomo de codigo. Ideal para tareas rapidas, revision de codigo, y envio de diagnosticos de compilacion.

**Integracion:** Se ejecuta dentro de Neovim como una terminal embebida (split lateral derecho). Usa el plugin `krmcbride/opencode.nvim`.

### Instalacion del CLI

```bash
# Arch Linux
sudo pacman -S opencode

# Debian/Ubuntu y Fedora
npm i -g @opencode/cli
# o descarga el binario desde https://github.com/anomalyco/opencode/releases
```

La primera vez, lanza `opencode` en tu terminal normal para hacer login.

### Atajos

| Atajo | Modo | Accion |
|-------|------|--------|
| `<leader>an` | Normal/Terminal | Nueva sesion de OpenCode |
| `<leader>ac` | Normal/Terminal | Continuar sesion existente |
| `<leader>aa` | Normal/Visual | Enviar seleccion al prompt |
| `<leader>aA` | Normal/Visual | Añadir @this al prompt |
| `<leader>ab` | Normal | Enviar buffer completo |
| `<leader>ad` | Normal | Enviar diagnosticos LSP |
| `<leader>av` | Visual | Revisar seleccion |

### Flujo de trabajo tipico

1. Escribe codigo normalmente.
2. `<leader>an` para abrir OpenCode en el panel derecho.
3. Escribe lo que necesites ("arregla este bug", "añade tests", etc.).
4. OpenCode trabaja en su TUI: lee archivos, escribe cambios, ejecuta comandos.
5. Los cambios se aplican al disco automaticamente. Neovim recarga los buffers modificados.

### Consejos

- Usa `<leader>aa` para enviar la funcion actual al contexto de OpenCode.
- Usa `<leader>ad` para que OpenCode vea los errores/warnings del LSP.
- Si OpenCode esta en modo `attach`, `<leader>ac` lo recupera.
- `CTRL-w h` para volver a tu codigo; `CTRL-w l` para volver a OpenCode.

## Claude Code (`<leader>c`)

**Proposito:** Sesiones largas de planificacion, refactorizacion multi-archivo, y debugging complejo. Usa el modelo Claude de Anthropic.

**Integracion:** Se ejecuta en un split vertical. Usa el plugin `carlos-rodrigo/claude-code.nvim`.

### Instalacion del CLI

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Verifica con `claude --version`. La primera ejecucion abre el navegador para OAuth (requiere cuenta Pro/Max o API key con billing).

### Atajos

| Atajo | Modo | Accion |
|-------|------|--------|
| `<leader>cc` | Normal | Toggle: abrir/cerrar Claude Code |
| `<leader>cn` | Normal | Nueva sesion |
| `<leader>cv` | Normal | Abrir en vsplit |
| `<leader>cs` | Visual | Enviar seleccion a Claude |
| `<leader>cS` | Normal | Guardar sesion actual |
| `<leader>cb` | Normal | Ver sesiones guardadas |

### Flujo de trabajo tipico

1. Antes de una tarea grande, haz commit: `git add -A && git commit -m "checkpoint"`
2. `<leader>cc` para abrir Claude Code en el panel derecho.
3. Describe la tarea en detalle.
4. Claude Code mostrara diffs de sus cambios propuestos. Puedes aceptar/rechazar.
5. `<leader>cS` para guardar la sesion si no has terminado.

### Gestion de sesiones

- Las sesiones se guardan automaticamente en `~/.local/share/claude-code-nvim/`
- `<leader>cb` abre un menu para cargar sesiones anteriores
- `<leader>cS` fuerza guardado manual

## Avante (`<leader>ai`)

**Proposito:** Experiencia estilo Cursor/VS Code con diff view lateral. Muestra los cambios sugeridos como diff y permite aceptar (keep) o rechazar (undo) por bloques.

**Integracion:** Panel de diff lateral dentro de Neovim. Usa la API de Claude directamente. Plugin `yetone/avante.nvim`.

### Requisito

Necesitas una API key de Anthropic:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

Añade esta linea a tu `~/.zshrc` o `~/.bashrc` para que persista.

### Atajos

| Atajo | Modo | Accion |
|-------|------|--------|
| `<leader>aia` | Normal/Visual | Preguntar a Avante (abre diff view) |
| `<leader>air` | Normal | Refrescar respuesta |
| `<leader>aie` | Normal/Visual | Editar seleccion |

### Flujo de trabajo tipico

1. Selecciona el codigo que quieres modificar, o situa el cursor.
2. `<leader>aia` y escribe tu pregunta ("optimiza esta funcion", "convierte a async", etc.).
3. Avante muestra el diff en un panel lateral (rojo = elimina, verde = añade).
4. Usa `]c` / `[c` para navegar entre bloques de cambio.
5. `ga` para aceptar un bloque (keep), `gr` para rechazarlo (undo).
6. Los cambios se aplican solo en los bloques que aceptes.

### Navegacion de diff

| Tecla | Accion |
|-------|--------|
| `]c` | Siguiente cambio |
| `[c` | Cambio anterior |
| `ga` | Aceptar cambio (keep) |
| `gr` | Rechazar cambio (undo) |

## Comparativa: cual usar cuando

| Herramienta | Mejor para | No tan buena para |
|-------------|------------|-------------------|
| **OpenCode** | Tareas rapidas, diagnosticos, bash | Cambios multi-archivo complejos |
| **Claude Code** | Planificacion, refactors grandes, sesiones largas | Cambios rapidos de una linea |
| **Avante** | Edicion asistida con control granular (keep/undo) | Tareas que requieren ejecutar comandos |

**Consejo:** Usa Avante para el dia a dia de codificacion, OpenCode para revisiones rapidas, y Claude Code para planificar features grandes o sesiones de debugging complejo.
