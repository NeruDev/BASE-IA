---
id: bp_7dp73ccy6aatn8fpc7ptrqg0c8
name: 09_contract_testing
title: "Pruebas de Contrato (Contract Testing)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/09_contract_testing.md
version: 1.1.0
category: architecture
tags: [contract-testing, pact, integration-testing, microservices, agent-tools, universal_principles]
description: "Pruebas de Contrato: verificación desacoplada y asíncrona de compatibilidad entre servicios consumidores y proveedores."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 09 - Pruebas de Contrato (Contract Testing)

## 1. Definición y Fundamento Teórico

Conceptualizado por **Ian Robinson** (2006) y popularizado mediante el estándar **Consumer-Driven Contract Testing (CDCT)** y herramientas como **Pact**, el **Contract Testing** es una técnica de pruebas de integración que postula:

> *"La compatibilidad de comunicación entre un servicio Consumidor (*Consumer*) y un servicio Proveedor (*Provider*) debe validarse de forma independiente y aislada verificando que ambos cumplan con un contrato formalmente acordado, sin requerir el despliegue simultáneo de ambos servicios en un entorno conjunto de pruebas de extremo a extremo (E2E)."*

El ciclo opera en dos fases desacopladas:
1. **Prueba del Consumidor:** El consumidor genera un contrato (*Pact file*) con las peticiones que enviará y las respuestas mínimas que espera recibir.
2. **Prueba del Proveedor:** El proveedor reproduce las peticiones del contrato contra su propia API y verifica que sus respuestas cumplan estrictamente con las expectativas acordadas.

## 2. Por Qué Existe y Problemas que Resuelve

- **Reemplazo de Pruebas E2E Frágiles y Lentas:** Las pruebas E2E en entornos compartidos son lentas, propensas a fallos por conectividad y difíciles de orquestar. El contract testing ofrece la misma garantía con la velocidad de pruebas unitarias.
- **Prevención de Roturas Silenciosas en Despliegues:** Si el proveedor renombra o elimina un campo que un consumidor necesita, el fallo se detecta en el CI del proveedor antes de llegar a producción (*Can I Deploy?*).
- **Despliegue Continuo Seguro:** Permite a múltiples equipos desplegar sus servicios en cualquier momento con certeza matemática de compatibilidad.

## 3. Relevancia en Sistemas con IA Agéntica

- **Validación de Herramientas y Subagentes:** En sistemas multi-agente, un subagente consumidor asume un formato específico de respuesta al invocar herramientas externas. El contract testing garantiza que las herramientas respeten ese formato.
- **Detección Temprana de Drift en APIs de Terceros:** Permite verificar si una actualización de versión en un proveedor de LLM o API externa viola el esquema asumido por el agente.
- **Verificación Automatizada en Pipelines de CI/CD:** Los agentes pueden validar automáticamente la compatibilidad de sus integraciones sin realizar llamadas reales a APIs de producción.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Integración a Ciegas y Pruebas E2E Frágiles)

```python
# Antipatrón: El consumidor asume campos no verificados formalmente, requiriendo levantar el servidor real
import requests

class CurrencyExchangeConsumer:
    def __init__(self, base_url: str):
        self.base_url = base_url

    def get_rate(self, pair: str) -> float:
        # ASUNCIÓN NO VERIFICADA: Asume que la respuesta contiene 'rate' como float
        # Si el proveedor cambia 'rate' por 'exchange_rate', fallará en producción
        res = requests.get(f"{self.base_url}/rates/{pair}")
        return res.json()["rate"]
```

### ✅ Código Correcto (Conforme a Pruebas de Contrato con Validación de Esquema)

```python
# src/contracts/exchange_contract.py
from pydantic import BaseModel, Field, ValidationError

class ExchangeRateContract(BaseModel):
    """Contrato acordado entre Consumidor y Proveedor."""
    currency_pair: str = Field(pattern=r"^[A-Z]{3}/[A-Z]{3}$")
    rate: float = Field(gt=0.0, description="Tasa de cambio estrictamente positiva.")
    provider_status: str = Field(default="ACTIVE")

# src/consumers/exchange_client.py (Consumidor Verificado)
class ValidatedExchangeConsumer:
    def __init__(self, fetcher_callable) -> None:
        self._fetcher = fetcher_callable

    def get_rate(self, pair: str) -> float:
        raw_data = self._fetcher(pair)
        try:
            # Valida el cumplimiento estricto del contrato
            validated = ExchangeRateContract.model_validate(raw_data)
            return validated.rate
        except ValidationError as e:
            raise RuntimeError(f"Violación de contrato detectada en respuesta: {e}") from e

# test_contract_verification.py (Test de Proveedor Aislado sin levantar el Consumidor)
def test_provider_honors_contract():
    """Prueba del Proveedor: comprueba que su respuesta real satisface el contrato."""
    # Respuesta real generada por el servicio proveedor
    provider_response = {
        "currency_pair": "USD/EUR",
        "rate": 0.92,
        "provider_status": "ACTIVE"
    }
    
    # La prueba pasa si el contrato valida sin errores
    contract_instance = ExchangeRateContract.model_validate(provider_response)
    assert contract_instance.rate == 0.92
    assert contract_instance.currency_pair == "USD/EUR"
```

## 5. Descripción Didáctica de los Cambios

1. **Definición Explícita del Contrato:** `ExchangeRateContract` formaliza el formato exacto, tipos y patrones (`^[A-Z]{3}/[A-Z]{3}$`) acordados.
2. **Validación en el Consumidor:** El cliente detecta inmediatamente cualquier discrepancia de esquema y la reporta como violación de contrato.
3. **Verificación Independiente del Proveedor:** El proveedor puede ejecutar `test_provider_honors_contract` en su propio CI de forma aislada, garantizando que su cambio no romperá al consumidor.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **No Reemplaza Pruebas de Negocio Profundas:** El contract testing valida la *forma* de los mensajes y respuestas, pero no valida si el cálculo financiero interno del proveedor es matemáticamente correcto.
- **No Apto para APIs Públicas de Acceso Masivo Desconocido:** En APIs públicas abiertas (ej. Twitter/X API pública), el proveedor no puede recolectar los contratos de millones de consumidores individuales; en ese caso se utiliza *Provider-Driven Versioning*.
- **Sobrecarga en Aplicaciones Monolíticas Simples:** En sistemas monolíticos donde consumidor y proveedor son funciones dentro del mismo ejecutable, el sistema de tipos de Python (`mypy`) ya ofrece esta garantía sin frameworks de contratos.

## 7. Checklist de Verificación

- [ ] ¿Los contratos capturan únicamente los campos que el consumidor realmente utiliza?
- [ ] ¿El proveedor ejecuta pruebas de verificación de contrato en su pipeline de CI antes de fusionar código?
- [ ] ¿Se cuenta con un repositorio central de contratos (*Pact Broker* o esquemas versionados) para compartir contratos?
- [ ] ¿Se reemplazaron pruebas E2E lentas e inestables por pruebas de contrato aisladas?