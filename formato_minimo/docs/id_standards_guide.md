---
id: guide_0g87rmra43b03a8eadvpdzsdg8
name: id_standards_guide
title: "Guía Exhaustiva de Identificadores Únicos (IDs) Estándar para Repositorios y Sistemas Agénticos"
file_path: id_standards_guide.md
version: 1.0.0
category: standards
tags: [id, uuidv7, ulid, typeid, standards, naming-conventions, agentic, schemas]
description: "Guía completa y comparativa de modelos de identificadores únicos (IDs) estandarizados, escalables y sencillos para repositorios públicos, APIs y sistemas agénticos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T14:15:00Z
updated_at: 2026-08-27T14:15:00Z
schema_version: 1.0.0
---

# Guía Exhaustiva de Identificadores Únicos (IDs) Estándar para Repositorios y Sistemas Agénticos

Esta guía proporciona un marco normativo, técnico y comparativo para la definición, generación y validación de **Identificadores Únicos (IDs)** en repositorios de código abierto, arquitecturas de software y sistemas basados en Inteligencia Artificial Agéntica.

---

## 1. Importancia de los IDs en Sistemas Agénticos y Repositorios Públicos

En el desarrollo de software moderno y particularmente en arquitecturas *Agent-First*, los identificadores no son simples cadenas arbitrarias; son **puntos de anclaje semántico** que permiten:

1. **Evitar Alucinaciones y Ambigüedad:** Un ID estructurado permite al LLM asociar una entidad o tarea inequívocamente sin inferir nombres variables.
2. **Determinismo y Parseabilidad:** Identificadores con patrones sintácticos estrictos (`regex`) pueden ser validados en precondiciones y herramientas antes de mutar el sistema.
3. **Ordenamiento Temporal (K-Sortability):** Los IDs ordenables cronológicamente permiten a agentes y bases de datos recuperar trazas y eventos en secuencia natural sin sobrecarga de índices.
4. **Seguridad y Compatibilidad de Transporte:** Deben ser seguros para su uso en URLs, nombres de archivos POSIX, variables de entorno y cabeceras HTTP.

---

## 2. Taxonomía de los Modelos de Identificadores Más Usados en la Industria

A continuación se detallan los 6 modelos de identificación más extendidos, desde los más sencillos para documentación hasta los más escalables para arquitecturas distribuidas:

```yaml
taxonomia_identificadores_unicos:
  1_slug_secuencial_numerico:
    ejemplos: ["01_dry_principle", "04_metadata_schemas"]
    proposito: "Documentación, especificaciones y orden secuencial"
  2_prefijo_tipado_typeid:
    ejemplos: ["doc_01j7x8k2m9pa4v7cb50153dnq9", "task_01h455vb4pex5v7cb50153dnq9"]
    proposito: "APIs públicas, recursos agénticos y seguridad de tipos"
  3_temporal_k_sortable_uuidv7_ulid:
    ejemplos: ["01890a5e-0a4b-7d3b-9a4f-123456789abc", "01ARZ3NDEKTSV4RRFFQ69G5FAV"]
    proposito: "Bases de datos relacionales (B-Tree friendly) y streaming"
  4_jerarquico_namespaced:
    ejemplos: ["tools:filesystem:read_file", "com.agent.core.planner"]
    proposito: "Permisos granulares, observabilidad y control de herramientas"
  5_codigo_taxonomia_error:
    ejemplos: ["ADR-0001", "RFC-0042", "ERR_AUTH_INVALID_TOKEN"]
    proposito: "Decisiones de arquitectura y códigos de excepción estandarizados"
  6_basado_en_contenido_hash:
    ejemplos: ["sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"]
    proposito: "Integridad criptográfica e inmutabilidad de snapshots"
```

---

### Modelo 1: Slug Secuencial Numérico (`XX_snake_case`)
*El más sencillo y legible para navegación humana y de agentes en repositorios de documentación.*

- **Estructura:** `<orden_dos_digitos>_<nombre_descriptivo_snake_case>`
- **Ejemplo:** `00_global_standards`, `01_readme_specification`, `04_metadata_and_field_schemas`
- **Regla Regex:** `^[0-9]{2}_[a-z0-9_]{3,60}$`
- **Ventajas:**
  - Orden natural garantizado en exploradores de archivos, terminales (`ls`), editores y árboles de contexto para LLMs.
  - Cero dependencias de librerías para generación.
- **Cuándo Usar:** Especificaciones de arquitectura, directrices de repositorio, migraciones de base de datos secuenciales.
- **Cuándo NO Usar:** Entidades de base de datos creadas dinámicamente o alta concurrencia.

---

### Modelo 2: Identificadores con Prefijo Tipado (TypeID / Stripe-Style IDs)
*El más escalable, seguro y recomendado para APIs modernas y llamadas a herramientas de agentes.*

- **Estructura:** `<tipo>_<base32_ulid_o_uuidv7>`
- **Ejemplos:**
  - Documentos / Specs: `doc_01h455vb4pex5v7cb50153dnq9`
  - Tareas de Agente: `task_01j7w2b8k4z0v9m1x2c3d4e5f6`
  - Ejecuciones / Runs: `run_01j7w3m5r8y2v0k1a2b3c4d5e6`
  - Usuarios / Cuentas: `usr_01h2xcejqtf2nbrexx3vqjhp41`
- **Regla Regex:** `^[a-z]{2,12}_[0-9a-hjkmnp-tv-z]{26}$`
- **Estándar:** Especificación formal [Jetpack TypeID](https://github.com/jetpack-io/typeid) y convención global de la API de Stripe.
- **Ventajas:**
  - **Seguridad de Tipos en Runtime:** Un agente nunca pasará un `usr_...` a una herramienta que espera un `task_...`.
  - **100% URL-Safe y POSIX-Safe:** Caracteres Base32 Crockford (sin vocales ambiguas `i, l, o, u` para evitar errores de lectura).
  - **Ordenable Cronológicamente (K-Sortable):** La parte Base32 contiene timestamp milimétrico.
  - **Eficiencia en Base de Datos:** Se puede decodificar y almacenar internamente como un entero binario UUID de 128 bits (16 bytes).

---

### Modelo 3: UUIDv7 (RFC 9562) y ULID
*El estándar oficial para llaves primarias en bases de datos relacionales y distribuidas.*

- **UUIDv7 (RFC 9562):**
  - **Estructura:** `018e3c45-2f8a-7d23-9a3b-8f123456789a` (36 caracteres con guiones).
  - **Composición:** 48 bits de timestamp Unix (ms) + 4 bits versión (7) + 12 bits secuencia + 2 bits variante + 62 bits aleatorios.
  - **Ventajas:** Evita la fragmentación de índices B-Tree en PostgreSQL/MySQL típica de UUIDv4 aleatorio.
- **ULID (Universally Unique Lexicographically Sortable Identifier):**
  - **Estructura:** `01ARZ3NDEKTSV4RRFFQ69G5FAV` (26 caracteres Base32).
  - **Composición:** 48 bits timestamp (ms) + 80 bits entropía.
  - **Ventajas:** Más corto que UUIDv7 en representación de texto y sin caracteres especiales.

---

### Modelo 4: Notación Jerárquica y Namespaces (`Namespace / Dot / Colon`)
*El estándar para permisos, herramientas, módulos y telemetría (OpenTelemetry / Kubernetes).*

- **Estructura:** `<dominio>:<componente>:<accion_o_recurso>` o `<dominio>.<subdominio>.<recurso>`
- **Ejemplos:**
  - Herramientas de Agentes: `tools:filesystem:write_file`, `tools:git:create_branch`
  - Políticas de Seguridad: `guardrail:security:secret_leak_prevention`
  - Métricas / Spans: `agent.execution.turn_duration_ms`
- **Regla Regex:** `^[a-z0-9_-]+(:[a-z0-9_-]+){2,5}$`
- **Ventajas:** Permite validación de permisos por prefijo jerárquico (ej. `tools:filesystem:*`).

---

### Modelo 5: Códigos de Decisión, Especificación y Error
*El estándar formal para ADRs, RFCs y Taxonomía de Excepciones.*

- **ADRs y RFCs:**
  - **Estructura:** `<PREFIJO>-<NUMERO_PADDED>`
  - **Ejemplos:** `ADR-0001`, `ADR-0015`, `RFC-0042`, `SPEC-0100`
- **Códigos de Error (RFC 7807 / RFC 9457):**
  - **Estructura:** `<ERR|AGENT>_<MODULO>_<DESCRIPCION_CORTA>`
  - **Ejemplos:** `ERR_AUTH_EXPIRED_TOKEN`, `AGENT_ERR_CONTEXT_OVERFLOW`, `VALIDATION_SCHEMA_MISMATCH`
- **Ventajas:** Búsqueda determinista en logs y catálogos de soporte.

---

### Modelo 6: Hashes Criptográficos Basados en Contenido
*El estándar para inmutabilidad y firmas de estado.*

- **Estructura:** `<algoritmo>:<hex_digest>`
- **Ejemplos:** `sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`, `git_commit:7f3a9b2`
- **Ventajas:** Verificación matemática de integridad de artefactos generados por IA.

---

## 3. Segmentación y Recomendaciones por Tipo de Proyecto

| **Tipo de Proyecto / Entorno** | **Modelo Recomendado** | **Ejemplo Concreto** | **Justificación Técnica** |
|:---|:---|:---|:---|
| **1. Repositorios de Documentación y Especificaciones** | Slug Secuencial Numérico | `01_dry_principle.md`, `02_architecture.md` | Lectura guiada y determinista para humanos y agentes. |
| **2. Frontmatter `name` en Markdown** | Snake_case idéntico al basename | `name: 01_dry_principle` | Permite resolución 1:1 entre identificador y archivo físico. |
| **3. APIs Públicas y Microservicios** | TypeID (Prefijo + Base32) | `usr_01j7x8k2m9pa...`, `doc_01j7...` | Autodescriptivo, seguro en URLs, K-sortable y tipo seguro. |
| **4. Sistemas Agénticos y Multi-Agente** | TypeID para recursos y eventos | `task_01j7w2b8k4...`, `run_01j7w3m...` | Trazabilidad milimétrica e identificación inmediata de contexto. |
| **5. Herramientas y Acciones de Agentes** | Notación Jerárquica por Dos Puntos | `tools:fs:read`, `tools:bash:execute` | Permite crear matrices de permisos granulares tipo RBAC. |
| **6. Bases de Datos Relacionales (PostgreSQL/MySQL)** | UUIDv7 (RFC 9562) | `01890a5e-0a4b-7d3b...` | Almacenamiento nativo en 16 bytes y rendimiento B-Tree óptimo. |
| **7. Decisiones de Arquitectura y Errores** | Prefijo + Padding / Snake Uppercase | `ADR-0001`, `ERR_VALIDATION_FAILED` | Estandarización ISO/RFC para auditoría y troubleshooting. |

---

## 4. Matriz Comparativa Global de Modelos

| **Modelo** | **Longitud** | **K-Sortable** | **Human Readable** | **URL / POSIX Safe** | **Resistencia a Colisiones** | **Complejidad** |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Slug Secuencial** | 10-60 chars | Por prefijo manual | ⭐⭐⭐⭐⭐ (Excelente) | ⭐⭐⭐⭐⭐ (Total) | Manual / Baja | Mínima (0 dependencias) |
| **TypeID (Stripe)** | ~30 chars | ⭐⭐⭐⭐⭐ (Automático) | ⭐⭐⭐⭐ (Muy Alta) | ⭐⭐⭐⭐⭐ (Total) | Criptográfica (128-bit) | Baja (Librería estándar) |
| **UUIDv7 (RFC 9562)** | 36 chars | ⭐⭐⭐⭐⭐ (Automático) | ⭐⭐ (Media) | ⭐⭐⭐⭐ (Requiere guiones) | Criptográfica (128-bit) | Baja (Soporte nativo) |
| **ULID** | 26 chars | ⭐⭐⭐⭐⭐ (Automático) | ⭐⭐⭐ (Alta) | ⭐⭐⭐⭐⭐ (Total) | Criptográfica (128-bit) | Baja |
| **Namespaced Colon** | 15-50 chars | No | ⭐⭐⭐⭐⭐ (Excelente) | ⭐⭐⭐⭐ (Evitar en filenames) | Jerárquica | Mínima |
| **ADR / RFC Code** | 8-12 chars | Por numeración | ⭐⭐⭐⭐⭐ (Excelente) | ⭐⭐⭐⭐⭐ (Total) | Controlada por repositorio | Mínima |

---

## 5. Implementación Práctica y Snippets de Código

### 5.1 En Python (TypeID y UUIDv7)

```python
import uuid
import time
import os

# Generación nativa de UUIDv7 (Python 3.12+ o compatible)
def generate_uuidv7() -> str:
    # Timestamp en milisegundos (48 bits)
    timestamp_ms = int(time.time() * 1000)
    rand_bytes = os.urandom(10)
    
    # Ensamblar UUIDv7 conforme a RFC 9562
    time_high = (timestamp_ms >> 16) & 0xFFFFFFFF
    time_mid = timestamp_ms & 0xFFFF
    time_low_and_version = 0x7000 | (int.from_bytes(rand_bytes[:2], 'big') & 0x0FFF)
    clock_seq_and_variant = 0x8000 | (int.from_bytes(rand_bytes[2:4], 'big') & 0x3FFF)
    node = int.from_bytes(rand_bytes[4:], 'big')
    
    return str(uuid.UUID(fields=(time_high, time_mid, time_low_and_version, clock_seq_and_variant >> 8, clock_seq_and_variant & 0xFF, node)))

# Generación de TypeID simple (Prefijo + Crockford Base32)
def generate_typeid(prefix: str) -> str:
    # Codificación Base32 de Crockford simplificada
    alphabet = "0123456789abcdefghjkmnpqrstvwxyz"
    raw_bytes = int(time.time() * 1000).to_bytes(6, 'big') + os.urandom(10)
    num = int.from_bytes(raw_bytes, 'big')
    encoded = []
    for _ in range(26):
        encoded.append(alphabet[num % 32])
        num //= 32
    return f"{prefix}_{''.join(reversed(encoded))}"

# Ejemplos de uso:
if __name__ == "__main__":
    print("Task ID:", generate_typeid("task"))  # ej. task_01j7x8k2m9pa4v7cb50153dnq9
    print("Doc ID:", generate_typeid("doc"))    # ej. doc_01j7x8k2m9pa4v7cb50153dnq9
    print("UUIDv7:", generate_uuidv7())         # ej. 018e3c45-2f8a-7d23-9a3b-8f123456789a
```

### 5.2 Expresiones Regulares Oficiales para Validación

```json
{
  "regex_typeid": "^[a-z]{2,12}_[0-9a-hjkmnp-tv-z]{26}$",
  "regex_uuidv7": "^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
  "regex_slug_spec": "^[0-9]{2}_[a-z0-9_]{3,60}$",
  "regex_adr": "^ADR-[0-9]{4}$",
  "regex_error_code": "^[A-Z]{3,8}_[A-Z0-9_]{3,32}$",
  "regex_tool_name": "^tools:[a-z0-9_]+:[a-z0-9_]+$"
}
```

---

## 6. Integración con `04_metadata_and_field_schemas.md` y `frontmatter_yaml.md`

1. **Campo `name` en Documentos Markdown del Repositorio:**
   - Debe utilizar el **Modelo 1 (Slug Secuencial)**: `^[a-z0-9_]{3,64}$`, coincidiendo exactamente con el nombre de archivo sin la extensión `.md`.
   - Ejemplo: `name: 04_metadata_and_field_schemas`.
2. **Identificadores de Entidades y Tareas Agénticas (`task_id`, `run_id`, `doc_id`):**
   - Deben adoptar el **Modelo 2 (TypeID)** para garantizar trazabilidad y prevención de errores de tipo en tiempo de ejecución.
3. **Manejo de Errores y Excepciones:**
   - Deben adoptar el **Modelo 5 (Códigos de Error Estructurados)** conforme a la taxonomía definida en `05_exception_handling_and_errors.md`.