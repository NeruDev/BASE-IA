---
id: bp_3am1vwg6ssarkr5pbb59h8t11c
name: 09_feature_flags
title: "Interruptores de Funcionalidad (Feature Flags / Toggles)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/09_feature_flags.md
version: 1.1.0
category: code_standards
tags: [feature-flags, feature-toggles, dark-launching, canary, continuous-delivery, universal_principles]
description: "Feature Flags: activación dinámica de funcionalidades desacoplada del despliegue para releases seguros."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 09 - Interruptores de Funcionalidad (Feature Flags / Toggles)

## 1. Definición y Fundamento Teórico

Formalizado por **Martin Fowler** en su ensayo canónico *Feature Toggles* (2010/2017), el patrón de **Interruptores de Funcionalidad (Feature Flags)** establece:

> *"El código de nuevas características debe integrarse y desplegarse continuamente a producción protegido detrás de interruptores dinámicos en tiempo de ejecución, desacoplando completamente el acto técnico de Desplegar (*Deployment*) del acto de negocio de Lanzar (*Release*)."*

Las cuatro categorías principales de *toggles* son:
1. **Release Toggles:** Permiten fusionar código incompleto o experimental en `main` sin exponerlo al usuario final.
2. **Experiment Toggles (A/B Testing):** Dirigen diferentes variantes de una funcionalidad o modelo a grupos de usuarios para comparar métricas de conversión o satisfacción.
3. **Ops Toggles (Kill Switches):** Interruptores de emergencia que permiten apagar instantáneamente una integración costosa o lenta (ej. un proveedor de LLM) ante degradación de servicio.
4. **Permissioning Toggles:** Habilitan capacidades exclusivas según el rol o plan del usuario (usuarios VIP, beta testers).

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Ramas de Larga Duración:** Permite adoptar *Trunk-Based Development* integrando cambios a `main` diariamente sin riesgo de activar código no terminado.
- **Rollbacks Instantáneos en Milisegundos:** Desactivar una funcionalidad rota se logra cambiando un valor booleano en configuración central (o dashboard), sin requerir un nuevo pipeline de CI/CD de 15 minutos.
- **Lanzamientos Progresivos (*Canary Releases*):** Habilita la exposición gradual de una nueva feature (1% -> 10% -> 50% -> 100%) monitoreando la tasa de errores.

## 3. Relevancia en Sistemas con IA Agéntica

- **Evaluación Segura de Nuevos Modelos de LLM:** Permite activar un modelo nuevo (ej. Gemini 2.0 vs. GPT-4o) para una fracción controlada de las peticiones agénticas, comparando latencia y precisión antes de la migración global.
- **Kill Switch para Herramientas (*Tools*):** Si una herramienta de agente presenta una vulnerabilidad o satura el límite de cuota (*rate limit*), el Feature Flag permite apagarla en tiempo de ejecución sin reiniciar el servidor.
- **Despliegues Oscuros (*Dark Launching*):** Permite que el nuevo agente procese las solicitudes en segundo plano en modo sombra (*shadow mode*) comparando su respuesta con el sistema legacy antes de responder a usuarios reales.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Despliegue Todo-o-Nada sin Capacidad de Apagado)

```python
# Antipatrón: Integración rígida al 100% sin posibilidad de desactivación dinámica
def buscar_documentos_antipatron(consulta: str):
    # Si la API de búsqueda semántica con embeddings falla o se satura,
    # todo el sistema colapsa obligando a un despliegue de emergencia a medianoche.
    return motor_embeddings_caro_y_experimental(consulta)
```

### ✅ Código Correcto (Conforme a Feature Flags: Gestor Tipado con Fallback Seguro)

```python
# src/features/flags.py
from dataclasses import dataclass
from typing import Callable

@dataclass(frozen=True)
class FeatureFlagsManager:
    """Gestor de interruptores de funcionalidad en tiempo de ejecución."""
    flags: dict[str, bool]

    def is_enabled(self, flag_name: str, default: bool = False) -> bool:
        return self.flags.get(flag_name, default)

# src/services/search.py
from src.features.flags import FeatureFlagsManager

class SearchService:
    def __init__(self, flag_manager: FeatureFlagsManager) -> None:
        self._flags = flag_manager

    def buscar(self, consulta: str, user_id: str) -> list[str]:
        # EVALUACIÓN DINÁMICA DEL FLAG:
        if self._flags.is_enabled("use_semantic_embeddings_search", default=False):
            try:
                # Camino experimental / Canary
                return self._busqueda_vectorial_llm(consulta)
            except Exception as exc:
                # Degradación elegante automática ante fallo del LLM
                print(f"[!] Fallo en búsqueda vectorial, usando fallback tradicional: {exc}")
                return self._busqueda_lexica_tradicional(consulta)

        # Camino tradicional estable por defecto
        return self._busqueda_lexica_tradicional(consulta)

    def _busqueda_vectorial_llm(self, consulta: str) -> list[str]:
        return [f"Resultado vectorial para: {consulta}"]

    def _busqueda_lexica_tradicional(self, consulta: str) -> list[str]:
        return [f"Resultado léxico estándar para: {consulta}"]
```

## 5. Descripción Didáctica de los Cambios

1. **Desacoplamiento Operativo:** La activación de la búsqueda vectorial depende de `is_enabled("use_semantic_embeddings_search")`, permitiendo encenderla o apagarla dinámicamente.
2. **Resiliencia con Degradación Elegante:** Si el servicio de embeddings falla, el bloque `try/except` redirige al motor léxico tradicional de forma transparente para el usuario.
3. **Control Gradual:** El gestor de flags puede configurarse mediante servicios dinámicos (LaunchDarkly, Flagsmith o Redis) sin recompilar el código.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Deuda Técnica de Flags (*Flag Debt / Spaghetti Toggles*):** Si los flags no se retiran una vez que la funcionalidad está 100% estabilizada, el código se llena de condicionales muertos y bifurcaciones difíciles de entender.
- **Explosión Combinatoria en Testing:** Tener 10 flags independientes activos genera $2^{10} = 1024$ estados posibles del sistema, haciendo imposible probar todas las combinaciones en CI.
- **Sobrecarga de Latencia de Red:** Si cada evaluación de flag consulta una base de datos remota sin caché local, puede introducir latencia en cada solicitud HTTP.

## 7. Checklist de Verificación

- [ ] ¿Las nuevas funcionalidades complejas o experimentales están protegidas detrás de un Feature Flag?
- [ ] ¿Existe un plan formal con fecha límite para retirar el Feature Flag una vez completado el release al 100%?
- [ ] ¿Las herramientas de agentes y proveedores de LLM cuentan con interruptores de apagado rápido (*Kill Switches*)?
- [ ] ¿El código cuenta con un camino de degradación elegante (*Fallback*) si el flag falla?