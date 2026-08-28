---
id: bp_7ca4g38cnfahatyn6arat1emeh
name: 02_least_privilege
title: "Principio de Menor Privilegio (Principle of Least Privilege - PoLP)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/02_least_privilege.md
version: 1.1.0
category: standards
tags: [least-privilege, polp, security, access-control, rbac, sandboxing, universal_principles]
description: "Menor Privilegio: concesión estricta de permisos mínimos a herramientas, procesos y agentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 02 - Principio de Menor Privilegio (Principle of Least Privilege - PoLP)

## 1. Definición y Fundamento Teórico

Formulado por **Jerome Saltzer** en *Communications of the ACM* (1974) y consolidado en *The Protection of Information in Computer Systems* (1975), el **Principio de Menor Privilegio (PoLP)** postula:

> *"Cada módulo, proceso, usuario, herramienta o entidad de un sistema debe operar utilizando exclusivamente el conjunto mínimo y más restringido de privilegios, permisos y accesos necesarios para desempeñar su función legítima, durante el menor tiempo posible."*

La meta central de PoLP es minimizar el **Radio de Impacto (*Blast Radius*)**: si un componente, clave de acceso o agente de IA se ve comprometido por una vulnerabilidad o inyección maliciosa, el daño que puede ocasionar queda estrictamente contenido.

## 2. Por Qué Existe y Problemas que Resuelve

- **Contención de Brechas de Seguridad:** Impide que la vulnerabilidad en un servicio secundario permita al atacante escalar privilegios hacia toda la base de datos o el sistema operativo.
- **Prevención de Errores Catastróficos Accidentales:** Evita que un script o agente ejecute operaciones destructivas (`DROP TABLE`, `rm -rf`) si su rol no lo requiere.
- **Facilidad de Auditoría y Trazabilidad:** Reduce la superficie de ataque y simplifica el monitoreo de anomalías de acceso.

## 3. Relevancia en Sistemas con IA Agéntica

- **Sandboxing de Tools y Agentes de IA:** Los modelos de lenguaje son vulnerables a inyecciones indirectas de prompt (*Prompt Injection*). Si un agente que solo debe consultar reportes es engañado, tener permisos de solo lectura impide que borre o altere registros productivos.
- **Aislamiento de Entornos de Ejecución de Código:** Las herramientas de ejecución de Python/Bash deben correr en contenedores sin permisos de `root`, sin acceso a la red interna y con cuotas estrictas de CPU y memoria.
- **Credenciales Efímeras y Delimitadas (*Scoped Tokens*):** Cada subagente debe recibir tokens con scopes limitados a su tarea específica en lugar de una clave maestra corporativa.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Conexión con Privilegios Totales de Administrador)

```python
# Antipatrón: Conexión de agente de analítica con credenciales de superusuario/admin
import sqlite3

class AnalyticsReporterAgent:
    def __init__(self):
        # ERROR GRAVE: Acceso con permisos totales de lectura, escritura y DDL
        # Si el prompt del usuario inyecta "DROP TABLE users;", la base de datos lo ejecutará
        self.conn = sqlite3.connect("production.db")

    def consultar_estadisticas_inseguro(self, query_generada_por_llm: str):
        cursor = self.conn.cursor()
        cursor.execute(query_generada_por_llm) # Peligro de mutación destructiva
        return cursor.fetchall()
```

### ✅ Código Correcto (Conforme a PoLP: Conexión Restringida de Solo Lectura)

```python
# src/infrastructure/readonly_db.py
import sqlite3
from typing import Sequence, Any

class ReadOnlyDatabaseGateway:
    """Gateway de persistencia con permisos estrictos de solo lectura (PoLP)."""

    def __init__(self, db_path: str) -> None:
        # URI en modo de solo lectura estricto a nivel de motor SQLite:
        # uri=True y mode=ro impiden físicamente cualquier INSERT, UPDATE o DELETE
        uri_readonly = f"file:{db_path}?mode=ro"
        self._conn = sqlite3.connect(uri_readonly, uri=True)

    def ejecutar_consulta_lectura(
        self,
        query: str,
        parametros: Sequence[Any] = ()
    ) -> list[tuple[Any, ...]]:
        """Ejecuta únicamente sentencias SELECT validadas."""
        query_limpia = query.strip().upper()
        if not query_limpia.startswith("SELECT") and not query_limpia.startswith("EXPLAIN"):
            raise PermissionError(f"Operación no autorizada bajo Menor Privilegio: {query}")

        cursor = self._conn.cursor()
        cursor.execute(query, parametros)
        return cursor.fetchall()
```

## 5. Descripción Didáctica de los Cambios

1. **Restricción a Nivel de Conexión de Motor:** La URI `file:production.db?mode=ro` configura la conexión SQLite en modo lectura obligatoria a nivel de kernel/driver.
2. **Validación Semántica de Sentencias:** Se rechaza explícitamente cualquier sentencia que no sea `SELECT` o `EXPLAIN`.
3. **Inmunidad ante Inyecciones Destructivas:** Si un agente de IA genera un `DROP TABLE` o `UPDATE` por alucinación o ataque externo, el motor de base de datos aborta la operación con un error de permisos.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Micro-gestión Excesiva de Permisos (*Permission Gridlock*):** Crear 50 roles hiper-granulares para un equipo de 3 desarrolladores puede paralizar el trabajo diario por denegaciones de acceso continuas.
- **Herramientas de Mantenimiento Legítimas:** Ciertas herramientas administrativas y agentes de migración de esquema necesitan legítimamente permisos de escritura; en estos casos se requiere aprobación humana explícita (*Human-in-the-Loop*).
- **Sobrecarga de Gestión de Identidades:** Requiere mantener sincronizados los sistemas de IAM (AWS IAM, Azure RBAC, roles de base de datos).

## 7. Checklist de Verificación

- [ ] ¿Los agentes y herramientas de solo lectura tienen conexiones y credenciales con permisos exclusivos de `SELECT`?
- [ ] ¿Los contenedores de ejecución de código para agentes corren sin privilegios de `root` (`USER nonroot`)?
- [ ] ¿Las claves de API tienen permisos y alcances (*scopes*) mínimos acotados a su función específica?
- [ ] ¿Se eliminaron usuarios administradores compartidos en favor de identidades específicas por servicio?