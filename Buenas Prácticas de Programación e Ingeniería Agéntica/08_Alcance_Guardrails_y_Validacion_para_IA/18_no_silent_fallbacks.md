---
id: bp_01m1343cywf6r957mx5tmdh1s6
name: 18_no_silent_fallbacks
title: "No Silent Fallbacks: Prohibición de Enmascaramiento y Fallo Explícito"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/18_no_silent_fallbacks.md
version: 1.0.0
category: agentic
tags: [no-silent-fallbacks, fail-fast, error-handling, exceptions, code-quality, linter-rules]
description: "Norma de ingeniería para prohibir capturas genéricas de excepciones silenciosas y forzar fallos explícitos y tipados."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 18 - No Silent Fallbacks (Prohibición de Fallbacks Silenciosos)

Los **fallbacks silenciosos** (capturar todas las excepciones y retornar `None`, `{}` o un valor predeterminado sin registrar el error) son el antipatrón más destructivo en sistemas agénticos, pues ocultan fallas críticas y causan corrupción progresiva de estado en pasos posteriores.

---

## 1. El Principio de Fallo Explícito (*Fail-Fast*)

```mermaid
flowchart TD
    subgraph Antipatron_Silencioso ["Antipatrón: Fallback Silencioso"]
        F1["Error en DB / Red"] --> F2["except Exception: return {}"]
        F2 --> F3["Agente asume datos válidos pero vacíos"]
        F3 --> F4["❌ Corrupción de estado y bug fantasma"]
    end

    subgraph Patron_Explicito ["Patrón Conforme: Fallo Explícito"]
        E1["Error en DB / Red"] --> E2["raise DatabaseConnectionError(...)"]
        E2 --> E3["Payload RFC 9457 con Causa Raíz"]
        E3 --> E4["✅ Auto-depuración o Reintento con Full Jitter"]
    end
```

---

## 2. Comparativa de Código

### ❌ Anti-Patrón: Enmascaramiento de Excepciones
```python
def get_user_profile(user_id: str) -> dict:
    try:
        return db.fetch_user(user_id)
    except Exception:
        # PÉSIMO: Oculta si fue un timeout, clave inexistente o credencial rota
        return {}
```

### ✅ Patrón Conforme: Elevación de Excepción Tipada
```python
class UserNotFoundError(Exception):
    """Excepción lanzada cuando el usuario no existe en el registro."""

class DatabaseUnavailableError(Exception):
    """Excepción lanzada cuando el motor de persistencia no responde."""

def get_user_profile(user_id: str) -> dict[str, str]:
    """Recupera el perfil de usuario o eleva una excepción de dominio explícita."""
    try:
        user = db.fetch_user(user_id)
        if not user:
            raise UserNotFoundError(f"Usuario '{user_id}' no encontrado.")
        return user
    except ConnectionError as e:
        raise DatabaseUnavailableError(f"Falla de conexión a base de datos: {e}") from e
```

---

## 3. Reglas de Linter para Forzar la Prohibición (Ruff / Flake8)

- **`BLE001` (Blind exception catch):** Prohíbe `except Exception:` sin re-lanzar o registrar.
- **`E722` (Bare except):** Prohíbe terminantemente bloques `except:`.
