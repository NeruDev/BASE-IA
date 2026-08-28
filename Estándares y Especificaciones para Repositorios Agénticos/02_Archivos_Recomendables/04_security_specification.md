---
id: spec_4kh4dwdggqakhvak0967fk0a8j
name: 04_security_specification
title: "Especificación y Plantilla Maestra de SECURITY.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/02_Archivos_Recomendables/04_security_specification.md
version: 1.0.0
category: templates
tags: [security, vulnerabilities, secrets, credentials, guardrails]
description: "Especificación y plantilla de SECURITY.md (política de seguridad y no-exposición de claves)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 04 - Especificación y Plantilla Maestra de SECURITY.md

## 1. Definición y Propósito del Archivo

### ¿Qué es SECURITY.md?

SECURITY.md define las políticas de seguridad del proyecto, el canal oficial de reporte responsable de vulnerabilidades y las normas estrictas de manejo de datos sensibles y credenciales.

### ¿Por qué existe y qué problemas resuelve?

- **Protección de Datos y Secretos:** Previene incidentes de seguridad y establece los acuerdos de divulgación responsable.

- **Directivas Inquebrantables para Agentes de IA:** Los agentes tienen prohibido registrar, imprimir, copiar o commitear claves API, contraseñas o tokens en archivos de código, documentación o trazas de test.

## 2. Plantilla Maestra Canónica de SECURITY.md

# Política de Seguridad (SECURITY.md)

Nos tomamos muy en serio la seguridad de nuestro software. Este documento describe nuestras políticas de soporte y reporte de vulnerabilidades.

---

## 1. Versiones con Soporte de Seguridad

| Versión | Soportada |
|:---|:---:|
| `1.x.x` | ✅ Sí |
| `< 1.0.0` | ❌ No |

---

## 2. Reporte de Vulnerabilidades

Si descubres una vulnerabilidad de seguridad, **no abras un issue público en GitHub**.

Por favor, envía un correo electrónico a:

📧 `security@tu-dominio.com` con el asunto `[Vulnerabilidad de Seguridad] - Nombre del Proyecto`.

---

## 3. Protocolo Estricto de Manejo de Secretos

### Reglas Mandatorias para Desarrolladores y Agentes de IA:

1. **Nunca incluir en texto plano:** API Keys, tokens de acceso personal, certificados `.pem`, contraseñas o URIs de bases de datos.

2. **Sanitización de Salidas:** Los agentes deben redactar automáticamente cualquier secreto en logs y mensajes de error (`***REDACTED***`).

3. **Escaneo Automático:** Todo commit es auditado por herramientas de escaneo de secretos (ej. `trufflehog` / `detect-secrets`).