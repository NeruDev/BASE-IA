---
description: "Reglas para crear y editar documentos Markdown: frontmatter, enlaces, idioma y ADR."
applyTo: "**/*.md"
---

# Reglas para Markdown

- Escribir en español con tono técnico y conciso: imperativo para instrucciones, tercera persona para descripciones.
- Empezar cada documento con el frontmatter de [ADR-0002](../../docs/adr/0002-frontmatter-schema.md): una clave por línea, listas en línea `[a, b]` y comillas dobles si el valor contiene `:`.
- Generar el `id` con el procedimiento de [CONTRIBUTING.md](../../CONTRIBUTING.md). Nunca inventarlo, copiarlo ni cambiar uno existente.
- Mantener `name` igual al nombre del archivo en snake_case y `file_path` igual a la ruta desde la raíz.
- Actualizar `updated_at` (UTC) al cambiar el contenido.
- Un único título H1 después del frontmatter y niveles de título sin saltos.
- Enlaces internos relativos con `/`. Nunca rutas absolutas ni anclas hacia otros archivos, porque no se validan.
- No duplicar información: si otro documento ya responde la pregunta, enlazarlo.
- En `docs/adr/`: seguir la plantilla de [docs/adr/README.md](../../docs/adr/README.md), añadir el ADR al índice y no cambiar el fondo de un ADR aceptado.
- Validar con `sh scripts/check.sh`.
