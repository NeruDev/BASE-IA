---
id: bp_686f6p6z11bhhvt3xstme02g4d
name: 01_documentation_as_code
title: "Documentación como Código (Docs-as-Code)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/01_documentation_as_code.md
version: 1.1.0
category: standards
tags: [docs-as-code, documentation, markdown, git, ci-cd, universal_principles]
description: "Docs-as-Code: tratamiento de la documentación con el mismo rigor, versionado y testing que el código fuente."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:20:00Z
schema_version: 1.0.0
---

# 01 - Documentación como Código (Docs-as-Code)

## 1. Definición y Fundamento Teórico

Conceptualizada y popularizada por **Anne Gentle** en su obra de referencia *Docs Like Code* (2017), la filosofía **Docs-as-Code (Documentación como Código)** establece:

> *"La documentación técnica debe gestionarse, almacenarse, revisarse y probarse utilizando las mismas herramientas, metodologías y rigor que el código fuente de producción: archivos en texto plano (Markdown), versionados en Git, auditados mediante Pull Requests y validados automáticamente en pipelines de Integración Continua (CI)."*

Los principios operativos de Docs-as-Code incluyen:
- **Almacenamiento Colocalizado:** La documentación reside en el mismo repositorio que el código (directorio `docs/`), evolucionando en el mismo commit.
- **Validación Automatizada:** Linters de prosa y sintaxis (`markdownlint`, `vale`), validación de enlaces rotos y verificación de ejemplos de código.
- **Publicación Continua:** Generación automatizada de portales web estáticos (MkDocs, Docusaurus, Sphinx) disparada por eventos en Git.

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación del Desfase de Documentación:** Evita que las wikis externas (Confluence, Notion) queden desactualizadas respecto al código real.
- **Trazabilidad de Cambios:** Permite auditar con `git log` y `git blame` exactamente quién, cuándo y por qué modificó una instrucción o guía de arquitectura.
- **Colaboración Unificada:** Desarrolladores, redactores técnicos y agentes de IA utilizan el mismo flujo de trabajo basado en Pull Requests.

## 3. Relevancia en Sistemas con IA Agéntica

- **Acceso Nativo para Agentes de Código:** Los LLMs pueden leer, indexar y actualizar archivos Markdown dentro del repositorio directamente mediante sus herramientas de sistema de archivos sin requerir conectores a intranets externas.
- **Sincronización Obligatoria en PRs Agénticas:** Los agentes pueden actualizar la documentación técnica y las guías de uso en el mismo Pull Request en el que introducen una nueva funcionalidad.
- **Auditoría Automatizada de Enlaces y Sintaxis:** Asegura que los agentes no generen referencias rotas ni formatos Markdown inválidos.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Wiki Externa Desconectada y Desincronizada)

```text
# Antipatrón: La arquitectura se documenta en una wiki externa privada
- La wiki describe un endpoint POST /api/v1/checkout con parámetros { "card_num", "cvv" }
- En Git, el código fue refactorizado hace 4 meses a POST /api/v2/payments con tokens seguros.
RESULTADO: Los agentes de IA y nuevos desarrolladores leen la wiki, generan código obsoleto
y sufren errores de integración en tiempo de ejecución.
```

### ✅ Código Correcto (Conforme a Docs-as-Code: Estructura Markdown + CI Linter)

Estructura del repositorio:
```text
repo/
├── src/
│   └── billing/
├── docs/
│   ├── index.md
│   └── api/
│       └── payments.md   # Documentación técnica versionada junto al código
└── .github/workflows/docs-validation.yml
```

Documento técnico versionado (`docs/api/payments.md`):
```markdown
# Servicio de Procesamiento de Pagos

Módulo encargado del cobro de transacciones mediante pasarelas tokenizadas.

## Endpoint: `POST /api/v2/payments`

### Parámetros de Entrada (JSON)
| Campo | Tipo | Requerido | Descripción |
| :--- | :--- | :--- | :--- |
| `token_pago` | `string` | Sí | Token efímero generado por el SDK cliente. |
| `monto` | `number` | Sí | Cantidad monetaria no negativa en formato decimal. |

### Ejemplo de Petición
```bash
curl -X POST https://api.empresa.com/api/v2/payments \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"token_pago": "tok_12345", "monto": 99.50}'
```
```

Pipeline de Validación en CI (`.github/workflows/docs-validation.yml`):
```yaml
name: Docs Validation Pipeline

on:
  pull_request:
    paths:
      - 'docs/**'
      - '*.md'

jobs:
  lint-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validar Sintaxis Markdown
        uses: DavidAnson/markdownlint-cli2-action@v16
        with:
          globs: '**/*.md'
```

## 5. Descripción Didáctica de los Cambios

1. **Documentación Colocalizada:** El archivo `docs/api/payments.md` reside junto al código en Git y se actualiza en el mismo Pull Request.
2. **Validación Automatizada con Markdownlint:** El workflow de CI verifica que los encabezados, tablas y bloques de código respeten el estándar sintáctico.
3. **Legibilidad Universal:** Humanos y agentes de IA leen el mismo archivo Markdown plano con total fidelidad técnica.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Documentación Comercial para Usuarios No Técnicos:** Documentos de marketing, presentaciones ejecutivas o actas de reuniones de RRHH no encajan en el modelo Docs-as-Code de Git; pertenecen a plataformas colaborativas de oficina.
- **Barrera de Entrada en Equipos No Técnicos:** Redactores de contenido que no dominan Git o Markdown pueden requerir interfaces visuales integradas (CMS headless basados en Git como Decap CMS o Forestry).
- **Sobrecarga de Linters de Prosa:** Configurar reglas de estilo de escritura excesivamente estrictas (como prohibir la voz pasiva en Vale) puede frustrar a los autores técnicos sin mejorar la claridad real.

## 7. Checklist de Verificación

- [ ] ¿Toda la documentación técnica de arquitectura y APIs reside en el repositorio Git (`docs/`)?
- [ ] ¿Los cambios de código que modifican interfaces públicas incluyen la actualización de la documentación en el mismo PR?
- [ ] ¿Existe un workflow de CI que valida la sintaxis Markdown y detecta enlaces rotos automáticamente?
- [ ] ¿La documentación está escrita en formatos de texto plano versionables (Markdown / AsciiDoc)?