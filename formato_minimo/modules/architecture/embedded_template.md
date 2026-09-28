---
id: tmpl_btpyxf4dea2vghzfyeq9pfhmte
name: embedded_template
title: "Plantilla de Arquitectura para Sistemas Embebidos y Bare-Metal (C/C++/Rust)"
file_path: modules/architecture/embedded_template.md
version: 2.0.0
category: templates
tags: [architecture, embedded, iot, microcontrollers, hal, drivers, bare-metal, c, cpp, rust]
description: "Patrón arquitectónico por capas de abstracción de hardware (HAL -> Drivers -> Application) para microcontroladores y sistemas embebidos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Arquitectura para Sistemas Embebidos y Bare-Metal (ARCHITECTURE.md)

Este documento define las **capas de abstracción de hardware, límites de memoria y máquinas de estado** para este proyecto embebido.

---

## 1. Topología de Abstracción de Hardware (HAL)

El código se organiza en tres capas desacopladas para permitir portabilidad entre microcontroladores y pruebas unitarias en host:

```mermaid
flowchart TD
    subgraph Capa_Aplicacion ["1. Lógica de Aplicación & Máquinas de Estado"]
        AppLogic["Controlador Principal / Protocolos de Aplicación"]
        FSM["FSM de Estados del Sistema"]
    end

    subgraph Capa_Drivers ["2. Drivers de Periféricos & Sensores"]
        Sensors["Drivers I2C / SPI / UART (Sensores, Actuadores, Displays)"]
        Comm["Stacks de Comunicación (BLE, WiFi, LoRa, CAN)"]
    end

    subgraph Capa_HAL ["3. Capa de Abstracción de Hardware (HAL / BSP)"]
        HAL["Abstracciones de Registros y GPIOs (Portables)"]
        MCU["Hardware Específico (STM32, ESP32, AVR, RP2040)"]
    end

    AppLogic --> Sensors
    AppLogic --> Comm
    Sensors --> HAL
    Comm --> HAL
    HAL --> MCU
```

---

## 2. Delimitación de Responsabilidades

| **Capa** | **Directorio Físico** | **Responsabilidad** | **Reglas de Aislamiento** |
|:---|:---|:---|:---|
| **Aplicación (`app/`)** | `src/app/` | Lógica pura del producto, toma de decisiones y estados. | `MUST_NOT` acceder a registros de hardware directamente. Compilable en Host nativo. |
| **Drivers (`drivers/`)** | `src/drivers/` | Protocolos de sensores, decodificación de tramas y buses. | Consume interfaces abstractas de HAL. |
| **HAL / BSP (`bsp/`)** | `src/bsp/` | Configuración de pines, interrupciones (ISRs), DMA y timers. | Única capa acoplada al SDK del microcontrolador específico. |

---

## 3. Invariantes de Sistemas Embebidos

1. **Gestión de Memoria Determinista:** `MUST_NOT` usar asignación dinámica de memoria (`malloc()`, `free()`, `new`) en bucles principales de tiempo real para evitar fragmentación del heap.
2. **ISRs Ultracortas:** Las Rutinas de Servicio de Interrupción (ISRs) solo deben fijar flags o escribir en ring-buffers; el procesamiento pesado se delega al bucle principal o tarea RTOS.
3. **Simulabilidad en Host:** La capa de aplicación debe compilar y probarse con mocks en el computador de desarrollo (Linux/Windows/macOS) sin requerir hardware físico conectado para pruebas unitarias.
