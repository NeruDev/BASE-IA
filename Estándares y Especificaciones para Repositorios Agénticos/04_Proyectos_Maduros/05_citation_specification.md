---
id: spec_5fba4j4atxb5x9n0j3xxvdckds
name: 05_citation_specification
title: "Especificación y Plantilla Maestra de CITATION.cff"
file_path: Estándares y Especificaciones para Repositorios Agénticos/04_Proyectos_Maduros/05_citation_specification.md
version: 1.0.0
category: templates
tags: [citation, cff, academic, research, attribution]
description: "Especificación y plantilla de CITATION.cff (citación académica y bibliográfica)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 05 - Especificación y Plantilla Maestra de CITATION.cff

## 1. Definición y Propósito del Archivo

### ¿Qué es CITATION.cff?

CITATION.cff (Citation File Format) es un archivo YAML estructurado estandarizado internacionalmente para que software académico y librerías técnicas puedan ser citados con precisión bibliográfica en publicaciones y papers.

### ¿Por qué existe y qué problemas resuelve?

- **Atribución Académica y Profesional:** Facilita la generación automática de citas en formatos BibTeX, APA e IEEE desde GitHub.

- **Para Agentes de IA:** Permite extraer metadatos de autoría y versión para generación automática de referencias.

## 2. Plantilla Maestra Canónica de CITATION.cff

```yaml
cff-version: 1.2.0
message: "If you use this software in your research or project, please cite it as below."
authors:
  - family-names: "García"
    given-names: "Neru"
    orcid: "https://orcid.org/0000-0000-0000-0000"
title: "Framework de Repositorios Agénticos y Estándares de Software para IA"
version: 1.0.0
date-released: 2026-08-26
url: "https://github.com/usuario/repositorio-agentico"
license: MIT
```