---
id: spec_57gsfnxq3dbdytz586ymfhsj7n
name: 02_codeowners_specification
title: "Especificación y Plantilla Maestra de CODEOWNERS"
file_path: Estándares y Especificaciones para Repositorios Agénticos/04_Proyectos_Maduros/02_codeowners_specification.md
version: 1.0.0
category: templates
tags: [codeowners, governance, security, code-review, permissions]
description: "Especificación y plantilla de CODEOWNERS (responsabilidad humana y zonas sensibles)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 02 - Especificación y Plantilla Maestra de CODEOWNERS

## 1. Definición y Propósito del Archivo

### ¿Qué es CODEOWNERS (.github/CODEOWNERS)?

CODEOWNERS es el archivo de gobernanza de GitHub que asigna automáticamente revisores humanos o equipos responsables a directorios y archivos específicos del repositorio.

### ¿Por qué existe y qué problemas resuelve?

- **Gobernanza y Control:** Asegura que los cambios en áreas críticas sean revisados por sus propietarios legítimos.

- **Para Agentes de IA:** Sirve como **mapa de zonas sensibles**; un agente reconoce que archivos bajo src/core/ o .github/ tienen alta criticidad y requieren máxima precaución.

## 2. Plantilla Maestra Canónica de CODEOWNERS

```text
# ==========================================
# Propietarios Globales por Defecto
# ==========================================
* @equipo-arquitectura @lead-dev

# ==========================================
# Capa de Dominio (Zona Crítica)
# ==========================================
/src/core/ @equipo-core-domain

# ==========================================
# Configuración de Seguridad y CI/CD
# ==========================================
/.github/ @equipo-devops
/.github/workflows/ @equipo-devops
SECURITY.md @equipo-seguridad

# ==========================================
# Documentación y Especificaciones
# ==========================================
/docs/ @equipo-documentacion
```