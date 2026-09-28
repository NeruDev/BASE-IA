---
id: tmpl_gtzz7sch95hpx4a2kcp2nw8jht
name: notebook_research_template
title: "Plantilla de Arquitectura para Proyectos de Investigación, ML y Data Science"
file_path: modules/architecture/notebook_research_template.md
version: 2.0.0
category: templates
tags: [architecture, datascience, machine-learning, research, notebooks, data-pipeline, experiments]
description: "Patrón arquitectónico reproducible para proyectos de experimentación, ciencia de datos, notebooks y machine learning."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Arquitectura de Investigación y Ciencia de Datos (ARCHITECTURE.md)

Este documento define la **topología de experimentación, flujo de datos reproducible y ciclo de vida de modelos** del proyecto.

---

## 1. Ciclo de Experimentación Reproducible

```mermaid
flowchart LR
    RawData["1. Data Ingestion<br/>(data/raw/)"] --> Processing["2. Feature Engineering<br/>(data/processed/)"]
    Processing --> ModelTraining["3. Model Training & Tuning<br/>(src/models/)"]
    ModelTraining --> Evaluation["4. Evaluation & Metrics<br/>(reports/metrics/)"]
    Evaluation --> Artifacts["5. Model Registry & Export<br/>(models/)"]
```

---

## 2. Estructura Canónica de Directorios

| Directorio | Propósito | Reglas de Versionado |
|:---|:---|:---|
| `data/raw/` | Datos de entrada inmutables en bruto. | `MUST_NOT` mutar. Ignorado en Git si supera 50MB. |
| `data/processed/` | Datasets limpios y transformados listos para modelado. | Generados mediante scripts deterministas. |
| `notebooks/` | Notebooks exploratorios con nombres numerados (`01_eda.ipynb`, `02_model.ipynb`). | Código maduro se promueve a `src/`. |
| `src/features/` | Funciones puras de extracción y transformación de variables. | Testeables y versionadas en Git. |
| `src/models/` | Definición de algoritmos, funciones de pérdida y pipelines de entrenamiento. | Con soporte para semillas deterministas (`random_state`). |
| `reports/` | Gráficos, métricas en CSV/JSON y reportes generados. | Versionados para trazabilidad de experimentos. |

---

## 3. Invariantes de Reproducibilidad

1. **Fijación de Semillas Deterministas:** Todo generador de números aleatorios (`random.seed()`, `np.random.seed()`, `torch.manual_seed()`) DEBE fijar una semilla explícita.
2. **Promoción de Notebooks a Módulos:** Toda función o pipeline que se use en más de un notebook DEBE refactorizarse dentro de `src/`.
3. **Control de Versiones de Datos:** Los datasets grandes no se incluyen en Git; deben referenciarse mediante hashes o almacenamiento S3/DVC.
