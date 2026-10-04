---
id: adr_01m44m2cqwe4q8vgyvz87jyez9
name: 0004_repository_memory
title: "Memoria del repositorio: índice, entradas atómicas y presupuestos verificables"
file_path: docs/adr/0004-repository-memory.md
category: agentic
tags: [adr, memoria, lecciones, presupuestos, consolidacion]
description: "Adopta una memoria versionada en docs/memory/ con índice de una línea por entrada, esquema fijo, presupuestos duros que valida scripts/checks/memory.sh y un ciclo de vida que promueve o borra cada entrada."
status: accepted
updated_at: 2026-10-04T23:30:30Z
---

# 0004 — Memoria del repositorio: índice, entradas atómicas y presupuestos verificables

## Contexto y planteamiento del problema

Un agente empieza cada sesión sin recuerdo de las anteriores y repite errores ya resueltos. Hace falta que el repositorio acumule lecciones, pero una memoria que solo crece se convierte en un log: consume contexto y nadie la lee. La solución debe seguir siendo pequeña dentro de un año, ser legible por cualquier agente que abra el repositorio y verificarse con `scripts/check.sh`.

## Factores de decisión

- Toda la memoria vive en el repositorio y es legible por cualquier agente; no se usan memorias externas.
- Carga barata: al iniciar sesión se lee un índice corto y el detalle se abre bajo demanda.
- Tamaño acotado con límites que un script comprueba, no con buena voluntad.
- Cada entrada tiene un destino: promoverse a una regla o un chequeo, o borrarse. Git es el histórico.
- Validación en POSIX `sh`, sin intérpretes ([ADR-0003](0003-scripting-languages.md)).

## Opciones consideradas

- Memoria nativa de la herramienta (auto memory de Claude Code, Copilot Memory).
- Un `MEMORY.md` único con secciones temáticas, como en las bases teóricas externas.
- Un archivo por entrada, o entradas en JSON validadas con un esquema.
- Índice más un archivo de entradas atómicas con esquema fijo y presupuestos verificables.

## Resultado de la decisión

Opción elegida: «índice más un archivo de entradas atómicas», porque es la única que acota el tamaño de forma verificable sin dependencias y deja que el agente decida con una línea si necesita el detalle.

Estructura:

- `docs/memory/README.md`: índice con una fila por entrada (id, cuándo aplica, regla resumida y estado) y el próximo id libre.
- `docs/memory/entries.md`: entradas con el esquema documentado en [CONTRIBUTING.md](../../CONTRIBUTING.md).

Presupuestos. Las líneas se cuentan sin el frontmatter, que es obligatorio en todo documento y no forma parte de la memoria:

| Límite | Valor | Justificación |
| --- | --- | --- |
| Índice | 40 líneas | 10 filas y la cabecera ocupan unas 25; queda margen sin permitir prosa. |
| Archivo de entradas | 120 líneas | 10 entradas activas ocupan unas 90. Con 150 el límite no se alcanzaría nunca; con 120 salta si se acumulan entradas pendientes de borrar. |
| Entrada | 8 líneas | El esquema ocupa 7: encabezado, cinco campos y una línea de estado. |
| Entradas activas | 10 | Es el límite que acota de verdad el tamaño. |
| Línea | 200 bytes | Sin él, los límites de líneas se esquivan con líneas largas. Se mide en bytes para que no dependa del locale. |
| Aviso de consolidación | 80 % de cualquier límite | Obliga a consolidar antes de llegar al error. |
| Sin revisar | 30 días | Aviso para confirmar, promover o borrar. 30 y no menos para no forzar el borrado de reglas valiosas en un repositorio de uso intermitente. |

De las bases teóricas externas se adoptan: la tabla de qué va en la memoria y qué va en otro sitio, la eliminación de lo ya formalizado en otro documento, la fecha de última validación, el origen de la lección y la fecha de vencimiento opcional. Se descartan los archivos de avance y de borrador, porque su contenido es efímero o ya lo conserva git.

Cambiar un presupuesto requiere un ADR nuevo que sustituya a este.

### Consecuencias

- Positivo: el tamaño máximo es fijo y el pre-commit impide superarlo.
- Positivo: una lección repetida acaba en un chequeo o una regla y sale de la memoria.
- Negativo: un script no puede juzgar si una entrada es un avance de tarea disfrazado; eso depende de la aprobación del usuario.
- Negativo: el aviso de caducidad compara con la fecha actual, excepción documentada en [shell.instructions.md](../../.github/instructions/shell.instructions.md). Solo emite avisos y la fecha se fija con `CHECK_TODAY` en las pruebas.
- Negativo: nada detecta que un agente no consulte la memoria; solo lo mitiga la regla de lectura de [AGENTS.md](../../AGENTS.md).

### Confirmación

- `scripts/checks/memory.sh`: presupuestos, campos obligatorios y su orden, formato de id y fechas, ids únicos, coherencia entre índice y entradas, estados válidos, evidencia como ruta o commit, ausencia de rutas absolutas y tokens, y avisos de caducidad.
- `scripts/checks/headers.sh`, `internal-links.sh` y `required-files.sh` validan el frontmatter, que la evidencia enlazada exista y que los archivos estén presentes.

## Ventajas y desventajas de las opciones

- Memoria nativa: está fuera del repositorio, en la máquina o en GitHub, y otros agentes no la pueden leer. No se puede verificar ni revisar en un diff, y Copilot Memory borra lo que no se usa en 28 días.
- `MEMORY.md` único: sin esquema ni destino por entrada, se carga entero y su poda depende de la voluntad del agente. Es el camino al log.
- Un archivo por entrada: duplica en el frontmatter el id, el estado y la fecha con otros valores permitidos, y multiplica los archivos para un máximo de 10 entradas. En JSON, la validación necesitaría Python, de modo que un clon sin `.venv/` no la ejecutaría.
