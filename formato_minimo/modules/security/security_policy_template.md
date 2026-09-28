---
id: tmpl_zn6yrj9qy5g1gt95fpakbq64z8
name: security_policy_template
title: "Plantilla de Política de Seguridad y Reporte de Vulnerabilidades"
file_path: modules/security/security_policy_template.md
version: 2.0.0
category: security
tags: [security, policy, vulnerability-reporting, cve, disclosure, guardrails]
description: "Política estándar de seguridad y proceso de divulgación responsable de vulnerabilidades (SECURITY.md)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Política de Seguridad del Repositorio (SECURITY.md)

Este documento define el **proceso de reporte responsable de vulnerabilidades y los estándares de seguridad** del proyecto.

---

## 1. Versiones Soportadas

| Versión | Soportada |
|:---:|:---:|
| `2.x` | ✅ Sí |
| `1.x` | ❌ No (Fin de soporte) |

---

## 2. Reporte de Vulnerabilidades

Si descubres una vulnerabilidad de seguridad o una fuga accidental de secretos:

1. **`MUST_NOT` Crear un Issue Público:** Por favor no abras un issue público en GitHub para reportar vulnerabilidades.
2. **Canal Privado de Reporte:** Envía los detalles técnicos a través del canal de seguridad privado o correo electrónico: `security@example.com`.
3. **Información a Incluir:**
   - Descripción detallada del vector de ataque o vulnerabilidad.
   - Pasos deterministas para reproducir el fallo.
   - Evaluación de impacto potencial.

---

## 3. Guardrails de Seguridad para Agentes de IA

1. **Cero Secretos en Código:** `MUST_NOT` commitear tokens, passwords, claves privadas o cadenas de conexión con credenciales embebidas.
2. **Uso de `.env.example`:** Toda variable de configuración debe declararse en `.env.example` con valores ficticios o placeholders.
3. **Principio de Menor Privilegio:** Ningún componente o script debe ejecutarse con privilegios elevados (`root` / `Administrator`) a menos que sea estrictamente indispensable.
