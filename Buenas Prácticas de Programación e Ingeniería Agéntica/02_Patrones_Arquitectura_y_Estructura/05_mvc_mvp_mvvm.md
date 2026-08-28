---
id: bp_0qtxqdr1vqbd19td9tjewmcmm6
name: 05_mvc_mvp_mvvm
title: "Patrones de Presentación: MVC, MVP y MVVM"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/05_mvc_mvp_mvvm.md
version: 1.1.0
category: architecture
tags: [mvc, mvp, mvvm, ui-patterns, separation-of-concerns, universal_principles]
description: "Patrones de Presentación: separación estricta entre modelo de datos, estado y vistas de usuario."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 05 - Patrones de Presentación: MVC, MVP y MVVM

## 1. Definición y Fundamento Teórico

Los patrones de capa de presentación resuelven la desconexión entre la experiencia del usuario y la lógica de negocio subyacente:

1. **MVC (Model-View-Controller):**
   - *Origen:* **Trygve Reenskaug** (Xerox PARC, 1979) para Smalltalk.
   - *Mecánica:* El **Controlador** recibe las interacciones del usuario, actualiza el **Modelo** (datos y reglas) y selecciona o actualiza la **Vista** para renderizar la respuesta.
2. **MVP (Model-View-Presenter):**
   - *Origen:* **Mike Potel** (Taligent/IBM, 1996) y formalizado por **Martin Fowler**.
   - *Mecánica:* La **Vista** es completamente pasiva y expone una interfaz abstracta; el **Presentador** manipula el Modelo y actualiza la Vista llamando a sus métodos de interfaz.
3. **MVVM (Model-View-ViewModel):**
   - *Origen:* **John Gossman** (Microsoft, 2005) para frameworks con enlace de datos (*Data Binding*).
   - *Mecánica:* El **ViewModel** actúa como un adaptador de estado del Modelo, exponiendo propiedades observables y comandos a la **Vista**, la cual se sincroniza automáticamente mediante *data-binding* bidireccional sin que el ViewModel conozca detalles del framework visual.

## 2. Por Qué Existen y Problemas que Resuelven

- **Separación de la Lógica Visual de la Lógica de Negocio:** Permite rediseñar la interfaz de usuario completa (ej. migrar de CLI a Web React o móvil) sin alterar los modelos de datos ni las reglas de cálculo.
- **Testabilidad de la Interfaz:** Facilita verificar el comportamiento de la UI mediante pruebas unitarias en el Controlador, Presentador o ViewModel sin necesidad de inicializar navegadores ni emuladores gráficos.
- **Reutilización del Modelo:** Múltiples vistas (gráficos, tablas, exports) pueden consumir el mismo modelo de datos simultáneamente.

## 3. Relevancia en Sistemas con IA Agéntica

- **Generación Segura de UIs por Agentes:** Los LLMs pueden crear y refactorizar componentes visuales de manera autónoma con cero riesgo de corromper la lógica de negocio si los patrones de presentación aíslan el estado.
- **Observabilidad de Estados Agénticos:** En paneles de control para agentes (*Agent Dashboards*), el patrón MVVM permite reflejar el flujo de pensamientos, tokens consumidos y llamadas a herramientas en tiempo real de forma reactiva.
- **Simulación de Interacciones de Usuario:** Permite a subagentes de testing automatizado interactuar con el ViewModel o Presenter simulando acciones humanas sin lidiar con selectores DOM frágiles.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: UI Acoplada a Negocio y Persistencia)

```python
# Antipatrón: Componente visual de consola que mezcla renderizado, validación y mutación
class TaskConsoleWidget:
    def __init__(self):
        self.tasks = []

    def on_button_click(self, raw_input: str):
        # ERROR: Validación de negocio incrustada en el widget visual
        if len(raw_input) < 3:
            print("ERROR: Tarea muy corta.") # Acoplado a la consola
            return

        # ERROR: Lógica de negocio y cálculo mezclado con presentación
        task_data = {"title": raw_input.strip().upper(), "done": False}
        self.tasks.append(task_data)

        # ERROR: Renderizado manual inline acoplado
        print(f"[*] Total tareas: {len(self.tasks)}")
        for t in self.tasks:
            print(f"- {t['title']}")
```

### ✅ Código Correcto (Conforme al Patrón MVVM / Presenter Desacoplado)

```python
# src/domain/models.py (Modelo Puro de Dominio)
from dataclasses import dataclass

@dataclass(frozen=True)
class Task:
    id: int
    title: str
    is_done: bool = False

# src/presentation/view_model.py (ViewModel: Estado y Comandos Desacoplados de UI)
class TaskViewModel:
    """Expone el estado y las operaciones de la tarea sin dependencias de UI."""
    def __init__(self) -> None:
        self._tasks: list[Task] = []
        self._error_message: str | None = None

    @property
    def tasks(self) -> tuple[Task, ...]:
        return tuple(self._tasks)

    @property
    def error_message(self) -> str | None:
        return self._error_message

    def add_task(self, title: str) -> bool:
        title_clean = title.strip()
        if len(title_clean) < 3:
            self._error_message = "El título de la tarea debe tener al menos 3 caracteres."
            return False

        new_task = Task(id=len(self._tasks) + 1, title=title_clean)
        self._tasks.append(new_task)
        self._error_message = None
        return True

# src/views/cli_view.py (Vista Pasiva: Solo renderiza el estado del ViewModel)
class TaskCliView:
    def __init__(self, view_model: TaskViewModel) -> None:
        self.vm = view_model

    def render(self) -> None:
        if self.vm.error_message:
            print(f"[!] Error: {self.vm.error_message}")
        print(f"=== Lista de Tareas ({len(self.vm.tasks)}) ===")
        for task in self.vm.tasks:
            status = "✓" if task.is_done else " "
            print(f"[{status}] {task.id}. {task.title}")
```

## 5. Descripción Didáctica de los Cambios

1. **Separación de Responsabilidades:** `TaskViewModel` gestiona la validación, el estado interno y la lógica de actualización, sin importar si la salida es una consola CLI, una página web en React o una API JSON.
2. **Testabilidad Sin Interfaz:** Se pueden escribir tests unitarios directos para `TaskViewModel.add_task()` comprobando los casos válidos y los mensajes de error en microsegundos.
3. **Vista Pasiva e Intercambiable:** `TaskCliView` solo lee las propiedades del ViewModel para renderizar, permitiendo crear una `TaskWebDashboardView` sin alterar una sola línea de lógica.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Servicios Backend Puros y Microservicios:** En APIs REST/gRPC que no disponen de interfaces visuales humanas, la estructura MVC tradicional o la arquitectura en capas (Clean Architecture / Hexagonal) es más pertinente que MVP o MVVM.
- **Complejidad del Data-Binding Oculto:** En MVVM con frameworks de enlace complejos, diagnosticar por qué una propiedad no se actualiza en la vista puede ser difícil debido a la magia reactiva de bindings bidireccionales.
- **Sobrecarga en Formularios Triviales:** Para interfaces con un único campo o diálogos efímeros de confirmación, crear un ViewModel completo puede representar exceso de código.

## 7. Checklist de Verificación

- [ ] ¿Los componentes visuales (vistas) carecen de lógica de cálculo de negocio y accesos directos a bases de datos?
- [ ] ¿Es posible testear unitariamente el ViewModel/Presenter/Controller sin renderizar componentes gráficos?
- [ ] ¿El Modelo de datos es independiente de la tecnología de presentación (HTML, CLI, GUI)?
- [ ] ¿La comunicación entre la vista y el modelo está canalizada de forma unidireccional o mediante enlace de datos controlado?