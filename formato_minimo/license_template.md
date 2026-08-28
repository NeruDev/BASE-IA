---
id: tmpl_01m13a4scse3evx82paz29jky9
name: license_template
title: "Plantilla Estándar y Patrón Maestro de LICENSE"
file_path: formato_minimo/license_template.md
version: 1.0.0
category: templates
tags: [license, template, master-pattern, legal, mit, apache, spdx, intellectual-property, compliance]
description: "Plantilla patrón canónica de LICENSE para repositorios de propósito general con textos legales MIT/Apache-2.0, identificadores SPDX y directivas de cumplimiento agéntico."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T22:30:00Z
updated_at: 2026-08-27T22:30:00Z
dependencies: [00_global_standards, 06_license_specification]
related_specs: [01_readme_specification, 03_agents_specification]
schema_version: 1.0.0
---

# Patrón Maestro y Plantilla de LICENSE

Este documento define la **especificación canónica del marco legal, términos de distribución, atribución y compatibilidad de licencias (SPDX)** para desarrolladores humanos, organizaciones y agentes autónomos de IA.

---

## 1. Función y Relevancia en Repositorios Agénticos

El archivo `LICENSE` (o `LICENSE.md` / `LICENSE.txt`) establece la **frontera legal vinculante** del software:

1. **Claridad Jurídica Inequívoca:** Sin un archivo `LICENSE`, el software se clasifica bajo "Todos los derechos reservados" (*All Rights Reserved*), impidiendo legalmente su uso, bifurcación o modificación por terceros.
2. **Evaluación de Compatibilidad por Agentes de IA:** Permite a los agentes validar automáticamente mediante identificadores SPDX (`MIT`, `Apache-2.0`) que ninguna librería externa incorporada al proyecto viole los términos del repositorio (ej. prevenir la introducción de dependencias GPL/AGPL virales en un proyecto comercial permisivo).
3. **Exención de Responsabilidad y Garantía (*AS IS*):** Protege a los autores y contribuidores contra responsabilidades derivadas de la ejecución del software o artefactos generados por IA.

---

## 2. Plantilla Canónica 1: Licencia MIT (Recomendada / Estándar Universal)

<!-- ======================================================================= -->
<!-- BP: bp_0113_convention_over_configuration & bp_0503_reproducible_builds -->
<!-- Licencia permisiva estándar de la industria (SPDX: MIT).                -->
<!-- ======================================================================= -->

```text
MIT License

Copyright (c) 2026 [Nombre del Titular de Derechos, Organización o Equipo]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 3. Plantilla Canónica 2: Licencia Apache 2.0 (Concesión Explícita de Patentes)

<!-- ======================================================================= -->
<!-- BP: bp_0801_operational_boundaries_and_blast_radius                     -->
<!-- Licencia permisiva corporativa con protección de patentes y marcas      -->
<!-- (SPDX: Apache-2.0).                                                     -->
<!-- ======================================================================= -->

```text
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

1. Definitions.
   "License" shall mean the terms and conditions for use, reproduction,
   and distribution as defined by Sections 1 through 9 of this document.

2. Grant of Copyright License.
   Subject to the terms and conditions of this License, each Contributor
   hereby grants to You a perpetual, worldwide, non-exclusive, no-charge,
   royalty-free, irrevocable copyright license to reproduce, prepare
   Derivative Works of, publicly display, publicly perform, sublicense,
   and distribute the Work and such Derivative Works in Source or Object form.

3. Grant of Patent License.
   Subject to the terms and conditions of this License, each Contributor
   hereby grants to You a perpetual, worldwide, non-exclusive, no-charge,
   royalty-free, irrevocable patent license to make, have made, use, offer
   to sell, sell, import, and otherwise transfer the Work.

4. Redistribution.
   You may reproduce and distribute copies of the Work or Derivative Works
   thereof in any medium, with or without modifications, and in Source or
   Object form, provided that You meet the following conditions:
   (a) You must give any other recipients of the Work or Derivative Works
       a copy of this License; and
   (b) You must cause any modified files to carry prominent notices stating
       that You changed the files; and
   (c) You must retain, in the Source form of any Derivative Works that You
       distribute, all copyright, patent, trademark, and attribution notices.

5. Disclaimer of Warranty.
   Unless required by applicable law or agreed to in writing, Licensor provides
   the Work (and each Contributor provides its Contributions) on an "AS IS"
   BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
   implied, including, without limitation, any warranties or conditions of TITLE,
   NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.

6. Limitation of Liability.
   In no event and under no legal theory, whether in tort (including negligence),
   contract, or otherwise, unless required by applicable law (such as deliberate
   and grossly negligent acts) or agreed to in writing, shall any Contributor be
   liable to You for damages.
```

---

## 4. Estandarización de Identificadores SPDX en Código Fuente

<!-- ======================================================================= -->
<!-- BP: bp_0607_facts_rules_and_procedures_separation                       -->
<!-- Cabeceras normalizadas SPDX para lectura instantánea por herramientas.  -->
<!-- ======================================================================= -->

Para evitar la redundancia de copiar el texto completo de la licencia en cada archivo de código fuente, los agentes y desarrolladores deben incluir la cabecera estándar de **SPDX** en la primera o segunda línea de cada módulo ejecutable:

### En Python (`.py`):
```python
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Equipo de Arquitectura
```

### En YAML / JSONC / Shell (`.yaml`, `.sh`):
```yaml
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Equipo de Arquitectura
```

---

## 5. Comparativa Taxonómica de Licencias para Repositorios

| **Licencia** | **Identificador SPDX** | **Tipo de Licencia** | **Uso Comercial** | **Concesión de Patentes** | **Obligación de Código Abierto Derivado** |
|:---|:---:|:---:|:---:|:---:|:---:|
| **MIT** | `MIT` | Permisiva | ✅ Permitido | ❌ Implícita | ❌ No (Puede cerrarse) |
| **Apache 2.0** | `Apache-2.0` | Permisiva | ✅ Permitido | ✅ Explícita | ❌ No (Puede cerrarse) |
| **BSD 3-Clause** | `BSD-3-Clause` | Permisiva | ✅ Permitido | ❌ No | ❌ No (Protege nombre comercial) |
| **GPL v3** | `GPL-3.0-only` | Copyleft Fuerte | ✅ Permitido | ✅ Explícita | ⚠️ **SÍ (Viral / Código abierto obligatorio)** |
| **Propietaria** | `LicenseRef-Proprietary` | Cerrada | ⚠️ Restringido | ⚠️ Restringido | ❌ Código cerrado exclusivo |

---

## 6. Guía de Límites y Fronteras Operativas de LICENSE

Para mantener el archivo `LICENSE` con estricta validez jurídica sin mezclar información ajena:

| **Contenido / Información** | **¿Debe estar en LICENSE?** | **Ubicación Correcta Designada** |
|:---|:---:|:---|
| Texto legal íntegro de la licencia elegida (MIT / Apache) | ✅ **SÍ** | `LICENSE` (en la raíz). |
| Nombre del titular del copyright y año de publicación | ✅ **SÍ** | `LICENSE` (cabecera del texto legal). |
| Mención breve del tipo de licencia y badge visual | ❌ **NO** | `README.md` (Secciones 1 y 12). |
| Metadato formal del paquete (`license = "MIT"`) | ❌ **NO** | `pyproject.toml` (`[project]`). |
| Campo `license: MIT` en metadatos YAML | ❌ **NO** | YAML Frontmatter de archivos `.md`. |
| Pautas de comportamiento ético o normas de comunidad | ❌ **NO** | `CODE_OF_CONDUCT.md`. |
| Guía paso a paso para contribuir código | ❌ **NO** | `CONTRIBUTING.md`. |

---

## 7. Comandos de Verificación y Auditoría para Agentes

Antes de incorporar dependencias de terceros, el agente debe verificar la compatibilidad de licencias:

```bash
# 1. Auditar licencias de todas las dependencias instaladas en el entorno virtual
pip-licenses --format=markdown --summary

# 2. Alertar si existen dependencias con licencias virales no autorizadas (GPL/AGPL)
pip-licenses --fail-on="GPL;AGPL"
```
