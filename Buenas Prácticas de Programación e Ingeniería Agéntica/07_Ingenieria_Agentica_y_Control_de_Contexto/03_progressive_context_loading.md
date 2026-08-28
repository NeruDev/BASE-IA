---
id: bp_23evdz7h49bgzsjayb5bewxqjz
name: 03_progressive_context_loading
title: "Carga Progresiva de Contexto Bajo Demanda"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/03_progressive_context_loading.md
version: 1.1.0
category: agentic
tags: [progressive-loading, lazy-loading, context-control, tool-use, index-discovery, universal_principles]
description: "Carga Progresiva de Contexto: lectura de índices livianos y recuperación bajo demanda mediante herramientas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:25:00Z
schema_version: 1.0.0
---

# 03 - Carga Progresiva de Contexto Bajo Demanda

## 1. Definición y Fundamento Teórico

Basada en el patrón arquitectónico de **Carga Perezosa (Lazy Loading)** y en los mecanismos de búsqueda por capas de información, la **Carga Progresiva de Contexto** establece:

> *"Un agente de IA no debe recibir pasivamente la totalidad de la base de código o documentación en su prompt inicial; debe recibir un índice liviano y autodescriptivo de descubrimiento (`INDEX.md`), utilizando sus herramientas de inspección (`view_file`, `grep_search`) de forma activa y progresiva para cargar únicamente los archivos y fragmentos estrictamente necesarios para resolver la tarea en curso."*

El ciclo de carga progresiva opera en 3 pasos interactivos:
1. **Descubrimiento Inicial (*Discovery*):** El agente consulta el índice de módulos o el mapa de símbolos (<50 líneas).
2. **Localización Quirúrgica (*Targeting*):** Utiliza búsquedas por patrones o nombres de archivos para ubicar el símbolo exacto.
3. **Carga Acotada (*Selective Loading*):** Lee exclusivamente el rango de líneas relevante para la modificación.

## 2. Por Qué Existe y Problemas que Resuelve

- **Ahorro Masivo de Ventana de Contexto:** Reserva el espacio de atención para el razonamiento profundo y la generación de código.
- **Prevención de Alucinaciones por Ruido:** Evita que el agente se distraiga con implementaciones secundarias no relacionadas con su objetivo.
- **Soporte para Repositorios Masivos:** Permite a agentes operar en proyectos de millones de líneas donde es físicamente imposible cargar todo el código a la vez.

## 3. Relevancia en Sistemas con IA Agéntica

- **Flujo Natural de Tool Calling:** Fomenta un comportamiento metódico: *Explorar -> Localizar -> Leer fragmento -> Editar -> Validar*.
- **Reducción de Costes Operativos en Tareas Complejas:** En bucles de 20 turnos de razonamiento, no arrastrar 40 archivos innecesarios en cada turno reduce el coste financiero en más del 80%.
- **Precisión en Refactorizaciones:** Permite al agente inspeccionar interfaces y contratos exactos antes de proponer modificaciones.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Inyección Eager Monolítica de Todo el Repositorio)

```python
# Antipatrón: Carga Eager descontrolada antes de que el agente sepa qué necesita
def iniciar_sesion_agente_antipatron():
    # ERROR: Lee y vuelca 40 archivos de código en el primer mensaje
    archivos = [leer_archivo(f) for f in os.listdir("src/")]
    prompt_inicial = "\n".join(archivos) + "\n\nTarea: Corrige el bug del cálculo de IVA."
    # El modelo recibe 60,000 tokens de código no relacionado (auth, UI, reportes)
    # y gasta su presupuesto atencional antes de empezar.
```

### ✅ Flujo Correcto (Conforme a Carga Progresiva: Índice + Herramientas Dirigidas)

Índice Liviano de Descubrimiento (`docs/INDEX.md`):
```markdown
# Índice de Módulos del Repositorio

| Módulo | Ruta Principal | Descripción |
| :--- | :--- | :--- |
| **Facturación** | `src/billing/` | Cálculo de impuestos, tasas y emisión de facturas. |
| **Autenticación** | `src/auth/` | Gestión de tokens JWT y permisos RBAC. |
| **Usuarios** | `src/users/` | Registro, perfiles y entidades de clientes. |
```

Interacción Progresiva del Agente:
```text
Turno 1: Agente lee `docs/INDEX.md` (30 tokens).
         Razonamiento: "El bug de IVA pertenece al módulo de Facturación en `src/billing/`."

Turno 2: Agente invoca herramienta de búsqueda:
         `grep_search(SearchPath="src/billing", Query="calcular_iva")`
         Resultado: "src/billing/tax.py:L45 - def calcular_iva(monto: Decimal) -> Decimal:"

Turno 3: Agente carga quirúrgicamente solo las líneas necesarias:
         `view_file(AbsolutePath="src/billing/tax.py", StartLine=40, EndLine=60)`
         Resultado: Carga únicamente 20 líneas de código exacto.

Turno 4: Agente aplica el fix preciso con `replace_file_content`.
```

## 5. Descripción Didáctica de los Cambios

1. **Economía Atencional:** El agente solo cargó 20 líneas de código en lugar de volcar los 40 archivos del proyecto.
2. **Navegación Dirigida:** El índice en `docs/INDEX.md` proporcionó la pista inicial sin sobrecargar la memoria de trabajo.
3. **Máxima Eficiencia:** El agente resolvió el problema consumiendo una fracción mínima de tokens y sin distraerse con código irrelevante.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Índices Desactualizados o Vagos:** Si `INDEX.md` no describe con claridad los módulos, el agente puede verse forzado a ejecutar 10 llamadas a `grep_search` a ciegas, aumentando la latencia total.
- **Tareas de Refactorización Global Transversal:** Para tareas que requieren renombrar un símbolo en todo el proyecto simultáneamente, la carga progresiva individual puede ser más lenta que una búsqueda global automatizada.

## 7. Checklist de Verificación

- [ ] ¿Existe un archivo de índice liviano (`INDEX.md` / `AGENTS.md`) que mapea los subsistemas principales?
- [ ] ¿El agente dispone de herramientas de lectura acotada (`view_file` con `StartLine` y `EndLine`)?
- [ ] ¿Se evita la inyección masiva de código no solicitado en el prompt de arranque?
- [ ] ¿Las herramientas de búsqueda (`grep_search`, `find_by_name`) están habilitadas para la localización autónoma de símbolos?