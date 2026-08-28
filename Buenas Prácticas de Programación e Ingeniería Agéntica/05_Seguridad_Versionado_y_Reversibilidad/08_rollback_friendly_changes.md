---
id: bp_7gkd2g5w5vba3rv4163fzx9bpb
name: 08_rollback_friendly_changes
title: "Cambios Diseñados para Reversión (Rollback-Friendly Changes)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/08_rollback_friendly_changes.md
version: 1.1.0
category: standards
tags: [rollback-friendly, expand-contract, zero-downtime, migrations, database, universal_principles]
description: "Cambios Diseñados para Reversión: patrón expand/contract en migraciones y despliegues sin downtime."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 08 - Cambios Diseñados para Reversión (Rollback-Friendly Changes)

## 1. Definición y Fundamento Teórico

Formalizado por **Martin Fowler** mediante el patrón **Expand and Contract** (también conocido como *Parallel Change* o *Tolerant Reader Pattern*), el principio de **Cambios Diseñados para Reversión** postula:

> *"Todas las modificaciones en esquemas de bases de datos, contratos de APIs y lógica de negocio deben estructurarse de tal manera que cualquier nuevo despliegue a producción pueda revertirse instantáneamente a la versión de software anterior sin requerir la reversión destructiva de la base de datos ni provocar caídas de servicio (*Zero-Downtime Rollback*)."*

El ciclo opera en tres fases desacopladas e independientes:
1. **Fase 1 - Expand (Expandir):** Se añade la nueva estructura (columna, tabla, campo API) sin eliminar ni alterar la preexistente. La aplicación nueva escribe en ambos campos y lee con fallback. La versión antigua sigue funcionando con normalidad.
2. **Fase 2 - Migrate (Migrar):** Se realiza la migración y sincronización de datos históricos en segundo plano.
3. **Fase 3 - Contract (Contraer):** Solo tras verificar que la nueva versión es 100% estable en producción, se elimina el campo antiguo en un release posterior independiente.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Caídas por Rollback (*Rollback Crashes*):** Evita que al revertir una versión de aplicación que falló, la versión previa colapse al no encontrar columnas renombradas o eliminadas.
- **Despliegues sin Tiempo de Inactividad (*Zero-Downtime Deployments*):** Permite que convivan en paralelo versiones antiguas y nuevas durante despliegues Blue-Green o Rolling Updates.
- **Seguridad en Producción:** Transforma las modificaciones arriesgadas de bases de datos en pasos graduales, seguros y auditables.

## 3. Relevancia en Sistemas con IA Agéntica

- **Prohibición de Migraciones Destructivas por Agentes:** Los agentes de IA tienden a generar scripts con `DROP COLUMN` o `ALTER TABLE RENAME COLUMN` para simplificar su tarea. Esta práctica impone el patrón Expand/Contract como regla inmutable.
- **Mitigación Automática de Errores Agénticos:** Si un cambio generado por un agente introduce una degradación de latencia o error de lógica, los sistemas de CI/CD pueden revertir el despliegue del agente en 3 segundos sin riesgo de corrupción de datos.
- **Compatibilidad Hacia Atrás en Tools de IA:** Asegura que los agentes puedan seguir invocando versiones previas de herramientas sin que una actualización rompa sus flujos activos.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Migración Destructiva Inmediata)

```sql
-- Antipatrón: Renombramiento destructivo en un solo paso
-- Si la nueva versión v2.0.0 falla en producción y se hace rollback a v1.0.0:
-- ¡LA VERSIÓN v1.0.0 CRASHEA AL INSTANTE porque busca la columna 'email' que ya no existe!
ALTER TABLE usuarios RENAME COLUMN email TO correo_corporativo;
```

### ✅ Código Correcto (Conforme al Patrón Expand/Contract: Rollback-Friendly)

#### Paso 1: Migración Expand en Base de Datos
```sql
-- FASE EXPAND: Añadir nueva columna sin tocar la existente
ALTER TABLE usuarios ADD COLUMN correo_corporativo VARCHAR(255);
-- Ambas columnas coexisten; la versión antigua v1.0.0 sigue operativa al 100%
```

#### Paso 2: Código de Aplicación con Soporte Dual (Fase Expand)
```python
# src/domain/users.py
from dataclasses import dataclass

@dataclass
class Usuario:
    id: str
    correo: str

def guardar_usuario_expand_contract(conn, usuario: Usuario) -> None:
    # ESCRITURA DUAL: Escribe en la columna antigua y en la nueva
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO usuarios (id, email, correo_corporativo)
        VALUES (?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            email = excluded.email,
            correo_corporativo = excluded.correo_corporativo;
        """,
        (usuario.id, usuario.correo, usuario.correo)
    )

def leer_usuario_expand_contract(conn, user_id: str) -> Usuario | None:
    # LECTURA CON FALLBACK: Lee el nuevo campo; si está nulo, recurre al antiguo
    cursor = conn.cursor()
    cursor.execute("SELECT id, COALESCE(correo_corporativo, email) FROM usuarios WHERE id = ?", (user_id,))
    row = cursor.fetchone()
    return Usuario(id=row[0], correo=row[1]) if row else None
```

## 5. Descripción Didáctica de los Cambios

1. **Coexistencia Pacífica:** Las columnas `email` y `correo_corporativo` coexisten simultáneamente.
2. **Escritura Dual y Lectura con Fallback:** `guardar_usuario_expand_contract` actualiza ambos campos, y `leer_usuario_expand_contract` utiliza `COALESCE` para garantizar lectura ininterrumpida.
3. **Rollback Seguro:** Si la aplicación se revierte a la versión previa, dicha versión continuará leyendo y escribiendo en la columna `email` sin notar ningún cambio.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Disciplina de Múltiples Despliegues:** Requiere planificar 2 o 3 releases sucesivos para completar un cambio de esquema en lugar de 1 solo paso.
- **Entornos de Desarrollo Inicial sin Producción:** En fases tempranas de diseño donde la base de datos se recrea desde cero en cada ejecución local, el patrón Expand/Contract añade sobrecarga innecesaria.
- **Duplicación Temporal de Almacenamiento:** Mantener datos duplicados temporalmente durante la fase de migración consume almacenamiento adicional en tablas masivas.

## 7. Checklist de Verificación

- [ ] ¿Las migraciones de base de datos añaden campos o tablas sin eliminar ni renombrar columnas existentes (*Fase Expand*)?
- [ ] ¿El nuevo código soporta escritura dual o lectura con fallback para garantizar compatibilidad hacia atrás?
- [ ] ¿Se verificó que la versión anterior de la aplicación continúe funcionando si se realiza un rollback inmediato?
- [ ] ¿Existe una tarea programada para la *Fase Contract* que retire las columnas deprecadas solo tras estabilizar el release?