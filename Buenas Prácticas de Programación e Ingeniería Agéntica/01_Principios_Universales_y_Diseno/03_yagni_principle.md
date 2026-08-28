---
id: bp_4va8kwgrdvayd9qm75tf7d85a6
name: 03_yagni_principle
title: "Principio YAGNI: You Aren't Gonna Need It"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/03_yagni_principle.md
version: 1.1.0
category: universal_principles
tags: [yagni, agile, minimalism, speculative-design, universal_principles]
description: "You Aren't Gonna Need It: eliminación de código especulativo y parámetros por si acaso."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 03 - Principio YAGNI: You Aren't Gonna Need It

## 1. Definición y Fundamento Teórico

Introducido por **Ron Jeffries**, **Kent Beck** y **Ward Cunningham** como uno de los pilares de *Extreme Programming (XP)*, el principio **YAGNI (You Aren't Gonna Need It)** establece:

> *"Implementa siempre las cosas cuando realmente las necesites, nunca cuando solo preveas que las vas a necesitar."*

YAGNI ataca la **programación especulativa**: la práctica de añadir métodos, configuraciones, capas de abstracción o soporte para tecnologías futuras que no están respaldadas por un requerimiento actual concreto.

## 2. Por Qué Existe y Problemas que Resuelve

- **Reducción del Costo de Oportunidad:** El tiempo invertido en escribir, documentar y probar código especulativo se resta de resolver problemas reales de negocio.
- **Eliminación de Código Muerto (*Dead Code*):** Frecuentemente, el futuro previsto nunca ocurre o los requisitos cambian radicalmente, dejando código sin uso que confunde y degrada la base de código.
- **Menor Superficie de Mantenimiento:** Cada línea añadida debe mantenerse, actualizarse y auditarse ante vulnerabilidades de seguridad.

## 3. Relevancia en Sistemas con IA Agéntica

- **Contención de Respuestas Especulativas de LLMs:** Los modelos fundacionales tienden a "sobre-completar" tareas agregando parámetros opcionales, stubs de métodos futuros y flags "por si acaso" no solicitados.
- **Foco en el Prompt y la Tarea:** En prompts de agentes, instruir el cumplimiento de YAGNI reduce el tamaño de las respuestas, ahorra costos de inferencia y disminuye drásticamente la tasa de fallos en tests de integración.
- **Evitar Stubs Incompletos:** Los agentes a menudo generan esqueletos vacíos (`raise NotImplementedError` o `# TODO`) que causan errores en tiempo de ejecución si son invocados por otros subagentes.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Funcionalidad Especulativa No Solicitada)

```python
# Antipatrón: Se solicitó únicamente exportar un reporte a JSON, pero se diseñó
# un motor universal con soporte para múltiples formatos no requeridos.
from pathlib import Path
from typing import Any
import json

class ReportExporter:
    def export(
        self,
        data: dict[str, Any],
        path: Path,
        format_type: str = "json",
        enable_compression: bool = False,   # ESPECULATIVO: No solicitado
        encryption_key: str | None = None, # ESPECULATIVO: Sin implementar
        target_cloud: str | None = None    # ESPECULATIVO: Código muerto
    ) -> None:
        if format_type == "json":
            path.write_text(json.dumps(data, indent=2), encoding="utf-8")
        elif format_type == "xml":
            raise NotImplementedError("Soporte XML planeado para el futuro.")  # Bug latente
        elif format_type == "parquet":
            raise NotImplementedError("Parquet no implementado.")
        else:
            raise ValueError(f"Formato no soportado: {format_type}")
```

### ✅ Código Correcto (Conforme a Estándar YAGNI: Enfocado y Robusto)

```python
# src/reports/exporter.py
from pathlib import Path
from typing import Any
import json

def exportar_reporte_json(data: dict[str, Any], file_path: Path) -> Path:
    """Exporta los datos del reporte a un archivo JSON con formato indentado.

    Args:
        data: Diccionario con la información a serializar.
        file_path: Ruta destino del archivo.

    Returns:
        Path del archivo generado.

    Raises:
        ValueError: Si el diccionario de datos está vacío.
        IOError: Si ocurre un error al escribir en disco.
    """
    if not data:
        raise ValueError("Los datos del reporte no pueden estar vacíos.")

    file_path.parent.mkdir(parents=True, exist_ok=True)
    file_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    return file_path
```

## 5. Descripción Didáctica de los Cambios

1. **Eliminación de Parámetros Especulativos:** Se suprimieron flags de compresión, encriptación y cloud que no formaban parte del requerimiento actual.
2. **Eliminación de Código Incompleto:** Se eliminaron los bloques con `NotImplementedError` que representaban trampas de error para los consumidores.
3. **Manejo Robusto del Requerimiento Presente:** Se aseguró la creación de directorios padre y la validación de entrada vacía para el caso concreto solicitado.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Decisiones Arquitectónicas Irreversibles:** YAGNI aplica a funcionalidades de negocio, no a fundamentos estructurales indispensables (como diseñar interfaces modulares, establecer manejo de transacciones o definir una estrategia de autenticación base).
- **Costo Asimétrico de Modificación Futura:** Si preparar una extensión mínima hoy cuesta 1 hora, pero implementarla a posteriori requeriría reescribir un esquema de base de datos en producción con millones de registros, una previsión calculada está justificada.
- **Contratos de API Pública y SemVer:** Romper compatibilidad hacia atrás en librerías públicas es muy costoso. Diseñar firmas de API extensibles (usando parámetros con valores por defecto o modelos Pydantic) previene *breaking changes*.

## 7. Checklist de Verificación

- [ ] ¿Cada parámetro y función implementada responde a un requisito actual verificado?
- [ ] ¿Se eliminaron métodos vacíos con `TODO` o `NotImplementedError`?
- [ ] ¿El código está libre de abstracciones creadas para soportar casos hipotéticos no confirmados?
- [ ] ¿El diseño es lo suficientemente limpio para permitir añadir nuevas capacidades fácilmente cuando sean necesarias?