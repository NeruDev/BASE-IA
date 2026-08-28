---
id: spec_01m133cfy2f5z9c361rga5gb61
name: 07_funding_specification
title: "Especificación y Configuración de Patrocinio (.github/FUNDING.yml)"
file_path: Estándares y Especificaciones para Repositorios Agénticos/04_Proyectos_Maduros/07_funding_specification.md
version: 1.0.0
category: templates
tags: [funding, github-sponsors, open-collective, patreon, donations, open-source]
description: "Especificación técnica y esquema de metadatos para el archivo de configuración de patrocinio y financiación .github/FUNDING.yml."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:00:00Z
updated_at: 2026-08-27T16:00:00Z
schema_version: 1.0.0
---

# 07 - Especificación y Configuración de Patrocinio (.github/FUNDING.yml)

Este documento establece la especificación técnica, plataformas autorizadas y plantilla canónica para el archivo de patrocinio comunitario `.github/FUNDING.yml`.

---

## 1. Estándar de GitHub para Botones de Patrocinio (*Sponsor Button*)

GitHub interpreta automáticamente el archivo `.github/FUNDING.yml` para desplegar el botón oficial **"Sponsor"** en la cabecera del repositorio, conectando a la comunidad con los canales legítimos de financiamiento y sostenibilidad del proyecto.

### ⛔ Reglas de Seguridad Inviolables para Agentes de IA:
1. **Inmutabilidad Financiera:** Los agentes de IA tienen **prohibido modificar o agregar enlaces de pago**, billeteras criptográficas o cuentas de recaudación sin aprobación explícita humana.
2. **Prohibición de Secretos:** Nunca incluir tokens de API, credenciales bancarias o información privada en `FUNDING.yml`.

---

## 2. Esquema de Plataformas Soportadas

| **Plataforma** | **Clave YAML** | **Formato Permitido** | **Ejemplo** |
|:---|:---|:---|:---|
| **GitHub Sponsors** | `github` | Nombre de usuario o lista de usuarios | `github: [usuario1, organizacion]` |
| **Open Collective** | `open_collective` | Slug del proyecto | `open_collective: mi-proyecto` |
| **Patreon** | `patreon` | Nombre de usuario | `patreon: usuario` |
| **Ko-fi** | `ko_fi` | Nombre de usuario | `ko_fi: usuario` |
| **Tidelift** | `tidelift` | `platform/package-name` | `tidelift: pypi/mi-paquete` |
| **URLs Personalizadas** | `custom` | URL o lista de URLs HTTPS | `custom: ['https://ejemplo.com/donar']` |

---

## 3. Plantilla Canónica de `.github/FUNDING.yml`

```yaml
# =============================================================================
# CONFIGURACIÓN OFICIAL DE PATROCINIO DEL PROYECTO
# =============================================================================

# GitHub Sponsors (Nombres de usuario o cuentas de organización)
github: [organizacion-oficial]

# Plataformas Comunitarias
open_collective: proyecto-open-source
ko_fi: equipo_desarrollo
patreon: equipo_creador

# Enlace personalizado a portal institucional
custom: ['https://mi-proyecto.org/sponsors']
```
