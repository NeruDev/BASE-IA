---
id: bp_26dz7sqbdyah1vntxjszr7yn82
name: 16_known_pitfalls_registry
title: "Registro de Errores y Trampas Conocidas (Known Pitfalls)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/16_known_pitfalls_registry.md
version: 1.1.0
category: agentic
tags: [known-pitfalls, troubleshooting, post-mortem, runbooks, agent-memory, universal_principles]
description: "Registro de Trampas Conocidas: catálogo de errores no intuitivos y soluciones probadas en TROUBLESHOOTING.md."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 16 - Registro de Errores y Trampas Conocidas (Known Pitfalls)

## 1. Definición y Fundamento Teórico

Inspirado en la metodología de **Análisis Post-Mortem sin Culpa (*Blameless Post-Mortems*)** y en los **Manuales Operativos de Resolución (*Runbooks / Troubleshooting Guides*)**, el **Registro de Errores y Trampas Conocidas** establece:

> *"Todos los comportamientos no intuitivos del stack tecnológico, incompatibilidades entre librerías, peculiaridades del sistema operativo y errores recurrentes resueltos en el pasado deben documentarse formalmente en un catálogo centralizado (`docs/TROUBLESHOOTING.md`), estructurado en Síntoma, Causa Raíz y Solución Probada, sirviendo como base de conocimiento de diagnóstico inmediato para agentes de IA y desarrolladores."*

Esta base de conocimiento evita que el equipo y los agentes inviertan horas resolviendo problemas que ya tienen solución documentada.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del Re-descubrimiento de la Rueda en Depuración:** Transforma un fallo desconcertante de 3 horas en una resolución de 15 segundos.
- **Prevención de Bucles de Bloqueo en LLMs:** Evita que los agentes de IA intenten parches fallidos que contradicen particularidades del stack.
- **Preservación de la Sabiduría Operativa:** Captura los aprendizajes técnicos sutiles adquiridos durante incidentes de producción.

## 3. Relevancia en Sistemas con IA Agéntica

- **Paso de Consulta Obligatorio ante Fallos:** Si un test o comando falla inesperadamente, el agente consulta `docs/TROUBLESHOOTING.md` antes de especular.
- **Memoria Institucional para Modelos sin Estado:** Provee al LLM el contexto de trampas específicas de librerías como Pydantic v2, SQLAlchemy 2.0 o diferencias de paths en Windows vs. Linux.
- **Reducción de Costes de Inferencia:** Corta de raíz los bucles de ensayo y error donde el agente prueba 10 soluciones erróneas.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Error Misterioso que Paraliza al Agente)

```text
# El agente ejecuta pytest y recibe:
sqlite3.OperationalError: database is locked
# ANTIPATRÓN: El agente no tiene acceso a un registro de trampas conocidas:
Turno 1: Intenta añadir time.sleep(1) en el código de producción.
Turno 2: Intenta cambiar el orden de los tests.
Turno 3: Intenta borrar la base de datos a mano.
# 10 turnos desperdiciados sin resolver la causa raíz de concurrencia en pytest-xdist.
```

### ✅ Catálogo Estructurado (`docs/TROUBLESHOOTING.md`)

```markdown
# Registro de Errores y Trampas Conocidas (docs/TROUBLESHOOTING.md)

## 🗄️ Base de Datos y Persistencia

### PITFALL-01: `sqlite3.OperationalError: database is locked` en Pytest
- **Síntoma:** Los tests fallan aleatoriamente con error de base de datos bloqueada al ejecutarse en paralelo (`pytest -n auto`).
- **Causa Raíz:** SQLite en modo archivo no soporta escrituras concurrentes simultáneas entre múltiples procesos de pytest.
- **Solución Canónica:** Configurar la fixture de base de datos con SQLite en memoria y `StaticPool`:
  ```python
  # tests/conftest.py
  from sqlalchemy import create_engine
  from sqlalchemy.pool import StaticPool

  @pytest.fixture
  def db_engine():
      return create_engine(
          "sqlite:///:memory:",
          connect_args={"check_same_thread": False},
          poolclass=StaticPool,
      )
  ```

---

## 🐍 Python & Tipos

### PITFALL-02: `PydanticUserError: validator is deprecated in V2`
- **Síntoma:** Error de inicio al instanciar modelos Pydantic.
- **Causa Raíz:** Uso del decorador `@validator` de Pydantic v1 en lugar de `@field_validator` de Pydantic v2.
- **Solución Canónica:**
  ```python
  from pydantic import field_validator

  @field_validator("email")
  @classmethod
  def validar_email(cls, v: str) -> str:
      return v.lower().strip()
  ```
```

## 5. Descripción Didáctica de los Cambios

1. **Estructura Didáctica Uniforme:** Cada entrada documenta *Síntoma exacto*, *Causa técnica profunda* y *Fragmento de código de solución probada*.
2. **Identificador Único (`PITFALL-XX`):** Permite a los agentes y humanos referenciar la solución en comentarios o issues.
3. **Resolución Instantánea:** El agente lee `PITFALL-01`, aplica la fixture con `StaticPool` y resuelve el bloqueo en 1 solo turno.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Catálogos Desactualizados (*Stale Pitfalls*):** Si una trampa correspondía a un bug de una librería que ya fue corregido en la versión actual, la entrada debe retirarse o archivarse para no confundir al agente.
- **No Documentar Errores Triviales de Sintaxis:** Documentar que falta un dos puntos (`:`) tras un `if` es ruido; el registro debe contener **peculiaridades no obvias y trampas arquitectónicas**.

## 7. Checklist de Verificación

- [ ] ¿Existe un archivo `docs/TROUBLESHOOTING.md` con las trampas conocidas del stack técnico?
- [ ] ¿Cada entrada sigue la estructura estándar: Síntoma, Causa Raíz y Solución con código?
- [ ] ¿Se instruye a los agentes en `AGENTS.md` a consultar este registro ante errores inesperados?
- [ ] ¿El registro se actualiza cada vez que se resuelve un bug complejo o incidente no trivial?