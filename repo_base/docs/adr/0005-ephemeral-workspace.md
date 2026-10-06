---
id: adr_01m49ns45df1g9rbh34aee0jzc
name: 0005_ephemeral_workspace
title: "Trabajo efímero aislado y promoción explícita"
file_path: docs/adr/0005-ephemeral-workspace.md
category: architecture
tags: [adr, sandbox, git, limpieza, agentes]
description: "Aísla temporales de agentes, impide su entrada al índice y define limpieza segura, promoción, exclusiones y evidencia durable."
status: accepted
updated_at: 2026-10-06T22:36:35Z
---

# 0005 — Trabajo efímero aislado y promoción explícita

## Contexto y planteamiento del problema

Borradores, reproducciones y salidas de agentes se mezclaban con entregables. Se requiere un área eliminable, sin dependencias del proyecto y con protección frente a adiciones forzadas. La guía externa orienta el ciclo de vida, pero no se adopta su SCRATCHPAD versionado ni un archivo histórico: solo hay dos controles permanentes.

Esta plantilla también vive dentro de un Git contenedor. Su raíz operativa es la carpeta que contiene AGENTS.md y scripts; los comandos Git desde allí limitan sus rutas a la plantilla. La limpieza rechaza cualquier otra carpeta actual. No se modifica la configuración Git del contenedor.

## Opciones consideradas

- Temporales dispersos o memoria de trabajo versionada: contaminan el resultado y la evidencia.
- Exclusión Git sin verificación: `git add -f` la elude.
- Área por tarea, índice verificado y promoción explícita: elegida.

## Resultado de la decisión

- Cada tarea usa `sandbox/AAAAMMDD-tarea/` solo si necesita archivos. Preferir pipes, variables y un borrador por documento o registro por ejecución. El destino normal es borrar, no archivar.
- Git solo admite `sandbox/README.md` y `sandbox/.gitkeep`. El verificador revisa el índice completo, incluso archivos forzados, y referencias operativas tanto preparadas como en la copia de trabajo. El hook llama al mismo verificador.
- Antes de promover, ejecutar `sh scripts/check.sh RUTA` sobre la ruta temporal; mover a la ubicación final, ajustar metadatos y volver a validar. Los linters reutilizan su configuración: solo cambia la selección explícita.
- Los temporales que necesitan los scripts usan `mktemp -d` del sistema y `trap` para salida y señales. Nunca usan el área de trabajo del agente ni dejan archivos en el repo.
- La evidencia de memoria apunta exclusivamente a entregables versionados o commits. Su protocolo y el chequeo rechazan evidencia efímera; no se crea una entrada de memoria por esta decisión.
- Avisos, nunca fallos: cualquier nodo efímero con más de 7 periodos completos de 24 h (`find -mtime +7`), aunque su unidad tenga actividad reciente, y espacio ocupado mayor que 20 MB decimales (20 000 000 bytes, medido con `du -sk`). Los controles y la raíz no generan aviso de edad. Son umbrales iniciales conservadores, no conservación automática.
- La antigüedad selecciona unidades inmediatas completas solo si todos sus nodos son antiguos; un descendiente o directorio reciente conserva la unidad. README.md y .gitkeep nunca se borran. `--older-than 0` exige al menos un periodo completo de 24 h; sin el filtro se selecciona todo el trabajo.
- Limpieza POSIX `sh`: dry-run por defecto; `--yes` borra. No acepta rutas, rechaza `..`, enlaces simbólicos en cualquier nivel, una raíz distinta y resoluciones fuera del área. Revalida antes de borrar cada unidad; no debe haber escritores concurrentes (POSIX no permite eliminar la carrera entre inspección y borrado).
- Se permite `command -p find` con predicados POSIX para limpieza y selección explícita: evita el `find.exe` de Windows. No se usan `-maxdepth`, `-delete` ni `sort`. Esto amplía las reglas de shell; los mtimes solo se usan para higiene efímera, no para decisiones durables.

### Excepciones técnicas cerradas

El usuario autorizó extender la lista inicial únicamente donde la verificación y las exclusiones necesitan conocer la ruta:

- `.gitignore`, `sandbox/README.md`, `AGENTS.md`, `scripts/sandbox-clean.sh` y `.vscode/tasks.json`.
- `scripts/check.sh`, `scripts/checks/sandbox.sh`, `scripts/lib/common.sh` y `tests/sandbox.sh` (verificación, selección y regresión).
- `.vscode/settings.json` y `.markdownlint-cli2.jsonc` (exclusiones).

Los archivos Markdown pueden describir el protocolo, sin dependencia operativa. Esta excepción documental no autoriza usar borradores como evidencia de memoria. El análisis estático de rutas literales no demuestra ausencia de dependencias construidas dinámicamente; esa prohibición sigue siendo contractual y requiere revisión.

### Editor y agentes: documentación verificada

- [Búsqueda de VS Code](https://code.visualstudio.com/docs/editing/codebasics): la opción «Use Exclude Settings and Ignore Files» decide si se aplican .gitignore y las exclusiones; se puede desactivar. Se fija `search.useIgnoreFiles: true` y una exclusión explícita de búsqueda, sin ocultar el área en Explorer.
- [Observador de VS Code](https://github.com/microsoft/vscode/wiki/File-Watcher-Issues): el observador recorre la carpeta abierta y tiene su propia configuración `files.watcherExclude`. Se configura explícitamente; ignorar en Git no implica excluirlo del observador. Las exclusiones no son controles de acceso.
- [Contexto de agentes en VS Code](https://code.visualstudio.com/docs/agents/reference/workspace-context): .gitignore excluye búsquedas e índice semántico, pero un archivo abierto o seleccionado puede entrar en contexto. `search.exclude` reduce búsqueda textual; no impide acceso explícito.
- [Exclusión de contenido de Copilot](https://docs.github.com/en/copilot/how-tos/configure-content-exclusion/exclude-content-from-copilot): Copilot CLI y el modo agente del IDE no admiten esa barrera. No se presupone que Copilot SDK ni herramientas de lectura o terminal respeten .gitignore; nunca guardar secretos aquí.
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2#configuration): `gitignore: true` usa archivos de exclusión hasta la raíz Git. Una configuración CLI externa es base, no reemplazo de la configuración local: las pruebas confirmaron que los filtros locales siguen prevaleciendo. Los documentos explícitos se validan por stdin, con las mismas reglas compartidas y sin cargar configuración de un borrador.
- [yamllint](https://yamllint.readthedocs.io/en/stable/configuration.html#ignoring-paths): `ignore-from-file` filtra archivos. El verificador selecciona rutas primero y reutiliza las reglas sin ese filtro para poder revisar una ruta explícita.

### Consecuencias y confirmación

- Se restaura `scripts/lib/common.sh`, ausente en la línea base y oculto por `lib/` del Git contenedor; la excepción local mantiene la biblioteca versionable. Sin ella, ninguno de los chequeos podía ejecutarse.
- El hook bloquea adiciones forzadas solo si está activado; no es protección frente a un usuario que lo desactive. No se cambia automáticamente la configuración Git del mantenedor.
- Abrir la plantilla como carpeta de trabajo aplica sus ajustes de VS Code; estos no se heredan al abrir solo el contenedor.
- `sh tests/sandbox.sh` crea un Git aislado en el temporal del sistema y prueba exclusión, chequeo, hook real, promoción, evidencia y limpieza. Usa symlinks reales en POSIX; en Windows sin ese privilegio, junctions reales reconocidas como enlaces por MSYS. No toca el índice original.
- Confirmación: `sh scripts/check.sh`, shellcheck en modo `sh`, pruebas negativas y estado limpio al crear temporales; después de limpiar solo quedan los dos controles.
