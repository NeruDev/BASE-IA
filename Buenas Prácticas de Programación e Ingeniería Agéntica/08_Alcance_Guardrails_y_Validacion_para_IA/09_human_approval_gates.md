---
id: bp_3t86k3yetyawrb9rg7h1rk95yb
name: 09_human_approval_gates
title: "Puertas de Aprobación Humana (Human Approval Gates)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/09_human_approval_gates.md
version: 1.1.0
category: agentic
tags: [human-approval-gates, human-in-the-loop, hitl, ai-governance, high-stakes, universal_principles]
description: "Puertas de Aprobación Humana: interrupción y confirmación obligatoria ante acciones destructivas o de alto riesgo."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 09 - Puertas de Aprobación Humana (Human Approval Gates)

## 1. Definición y Fundamento Teórico

Basada en los estándares de gobernanza y supervisión de sistemas autónomos (**IEEE 7000 Series / NIST AI RMF**), la práctica de **Puertas de Aprobación Humana (Human-in-the-Loop - HITL)** postula:

> *"La autonomía operativa de un agente de IA debe pausarse de forma determinista ante cualquier acción irreversible, destructiva, financiera o de alto impacto para la seguridad (*High-Stakes Operations*), exigiendo la revisión informada y la autorización explícita de un operador humano antes de proceder con la ejecución."*

Este principio establece un equilibrio virtuoso: **Autonomía total para análisis, desarrollo local y pruebas** vs. **Supervisión humana obligatoria para mutaciones críticas**.

```text
 [Agente: Análisis + Desarrollo Local + Tests] ──► [🛡️ HUMAN APPROVAL GATE] ──► [Ejecución Crítica]
                  (Autónomo)                             (Pausa & Confirmación)        (Despliegue / DDL)
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Desastres Irreversibles:** Evita que un agente ejecute comandos como `DROP TABLE`, `git push --force` o `terraform destroy` de forma desatendida.
- **Control Financiero y de Recursos:** Bloquea llamadas a APIs de pago masivas o aprovisionamiento de instancias cloud costosas sin presupuesto aprobado.
- **Responsabilidad Legal y Ética:** Garantiza que las decisiones de despliegue a producción mantengan una cadena de custodia y responsabilidad humana demostrable.

## 3. Relevancia en Sistemas con IA Agéntica

- **Integración con Herramientas Interactivas (`ask_question`):** Permite al agente pausar su bucle ReAct y renderizar un modal interactivo en la UI para solicitar confirmación al desarrollador.
- **Flujo de Pull Requests como Puerta Canónica:** El agente abre el PR con toda la evidencia de pruebas, delegando la decisión final de merge al revisor humano.
- **Despliegues en Staging vs. Producción:** Permite a los agentes desplegar automáticamente en entornos efímeros de prueba mientras bloquea el paso a producción.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Ejecución Desatendida de Acción Destructiva)

```python
# Antipatrón: El agente ejecuta una migración destructiva en la base de datos sin preguntar
def aplicar_limpieza_base_datos_antipatron(cursor):
    print("Limpiando tablas obsoletas...")
    # ERROR GRAVE: Ejecuta DROP TABLE en producción sin confirmar con un humano
    cursor.execute("DROP TABLE usuarios_legacy;")
    cursor.execute("DROP TABLE transacciones_2025;")
    # ¡Pérdida irreversible de datos sin autorización!
```

### ✅ Flujo Correcto (Conforme a Human Approval Gate: Protocolo Interactivo HITL)

```python
# src/agent/approval_gate.py
from dataclasses import dataclass
from typing import Callable

@dataclass(frozen=True)
class ActionProposal:
    action_type: str
    impact_level: str  # "LOW", "MEDIUM", "CRITICAL"
    target_resource: str
    command_preview: str

def solicitar_aprobacion_humana(proposal: ActionProposal) -> bool:
    """Interrumpe la ejecución del agente y solicita confirmación explícita."""
    print("==================================================")
    print(" 🛑 PUERTA DE APROBACIÓN HUMANA REQUERIDA (HITL)")
    print("==================================================")
    print(f"Tipo de Acción:  {proposal.action_type}")
    print(f"Nivel de Riesgo: {proposal.impact_level}")
    print(f"Recurso Destino: {proposal.target_resource}")
    print(f"Comando a Ejecutar:\n  {proposal.command_preview}")
    print("==================================================")
    
    # En entornos interactivos se utiliza ask_question / input bloqueante
    respuesta = input("¿Autorizas la ejecución de esta acción crítica? (escribe 'SI' para confirmar): ")
    return respuesta.strip().upper() == "SI"

# Uso en herramientas del agente:
def ejecutar_migracion_esquema(sql_script: str, db_env: str) -> None:
    if "DROP" in sql_script.upper() or "TRUNCATE" in sql_script.upper() or db_env == "production":
        propuesta = ActionProposal(
            action_type="MIGRACIÓN DDL DESTRUCTIVA",
            impact_level="CRITICAL",
            target_resource=f"Base de Datos: {db_env}",
            command_preview=sql_script
        )
        
        if not solicitar_aprobacion_humana(propuesta):
            raise PermissionError("Acción destructiva abortada: El operador humano denegó la autorización.")

    print(f"[✓] Ejecutando migración autorizada en {db_env}...")
```

## 5. Descripción Didáctica de los Cambios

1. **Clasificación de Riesgo:** Se evalúa si la acción contiene comandos peligrosos (`DROP`, `TRUNCATE`) o apunta a producción.
2. **Pausa e Interrupción Obligatoria:** El flujo se detiene y muestra una vista previa completa de la acción al operador humano.
3. **Bloqueo Defensivo:** Si el humano rechaza la acción, el sistema aborta de inmediato con `PermissionError`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Fatiga de Aprobación (*Approval Fatigue*):** Exigir confirmación humana para operaciones triviales (como ejecutar pytest o leer un archivo local) genera frustración y lleva a que el humano apruebe todo automáticamente sin leer; las puertas deben reservarse **exclusivamente para acciones críticas e irreversibles**.
- **Entornos de Sandbox Aislados:** En contenedores efímeros locales diseñados específicamente para destruirse, se puede relajar la supervisión humana.

## 7. Checklist de Verificación

- [ ] ¿Las operaciones destructivas (DDL, borrado de datos, push forzado) requieren aprobación humana explícita?
- [ ] ¿El agente presenta una vista previa clara del impacto y los comandos a ejecutar al solicitar aprobación?
- [ ] ¿Las operaciones rutinarias y de solo lectura se ejecutan con plena autonomía para no generar fatiga cognitiva?
- [ ] ¿Los pipelines de despliegue a producción cuentan con una puerta de revisión formal en GitHub Actions / GitLab CI?