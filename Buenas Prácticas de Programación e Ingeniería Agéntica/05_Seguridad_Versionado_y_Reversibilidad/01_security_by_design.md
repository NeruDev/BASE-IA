---
id: bp_7dgv1zkqdka33v5rg100phnq0q
name: 01_security_by_design
title: "Seguridad por Diseño (Security by Design)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/01_security_by_design.md
version: 1.1.0
category: standards
tags: [security-by-design, cybersecurity, secrets-management, encryption, owasp, universal_principles]
description: "Seguridad por Diseño: integración nativa de autenticación, cifrado y secretos desde la arquitectura inicial."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 01 - Seguridad por Diseño (Security by Design)

## 1. Definición y Fundamento Teórico

Formalizado originalmente por **Jerome Saltzer** y **Michael Schroeder** en *The Protection of Information in Computer Systems* (1975) y respaldado por los estándares **NIST** y **OWASP**, el principio de **Seguridad por Diseño (Security by Design)** postula:

> *"La seguridad, la privacidad y la protección de datos deben concebirse e integrarse como requisitos fundamentales en la arquitectura base del software desde su primera línea de diseño, en lugar de intentarse añadir como una capa superficial o parche tardío (*Bolt-on Security*)."*

Los pilares de la seguridad por diseño incluyen:
- **Gestión Estricta de Secretos:** Separación absoluta entre el código fuente y las credenciales mediante variables de entorno y gestores de secretos (*Vault*, *AWS Secrets Manager*).
- **Criptografía Robusta:** Uso de algoritmos modernos validados (Argon2id, AES-GCM-256) con generación de números aleatorios criptográficamente seguros (`secrets`).
- **Defensa en Profundidad (*Defense in Depth*):** Múltiples capas de control defensivo redundantes en red, aplicación y datos.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Brechas de Datos Masivas:** Evita la exposición involuntaria de contraseñas, claves privadas y datos sensibles de usuarios.
- **Reducción Exponencial de Costos de Remediación:** Corregir un fallo estructural de seguridad en producción cuesta hasta 100 veces más que diseñarlo correctamente desde el inicio.
- **Cumplimiento Normativo Automático:** Facilita la conformidad con estándares como GDPR, PCI-DSS, HIPAA y SOC 2.

## 3. Relevancia en Sistemas con IA Agéntica

- **Protección contra Riesgos OWASP para LLMs:** Mitiga ataques críticos como *Prompt Injection*, exfiltración de memoria de contexto (*Context Leakage*) y ejecución insegura de herramientas.
- **Aislamiento de Claves de API de Modelos:** Evita que los agentes de IA impriman claves privadas en logs estructurados o las expongan en prompts enviados a proveedores externos.
- **Sanitización de Salidas Agénticas:** Asegura que los datos generados por LLMs se validen y escapen antes de ser interpretados por bases de datos o navegadores web.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Secretos Hardcodeados y Hashing Débil)

```python
# Antipatrón: Credenciales en código fuente y uso de MD5 obsoleto sin salt
import hashlib

# ERROR GRAVE: Clave privada expuesta en el repositorio Git
JWT_SECRET_KEY = "mi_clave_secreta_super_insegura_123"

def guardar_usuario_inseguro(email: str, password_plana: str):
    # ERROR DE SEGURIDAD: MD5 es vulnerable a colisiones y ataques por tablas rainbow
    password_hash = hashlib.md5(password_plana.encode()).hexdigest()
    # Persiste password_hash vulnerable...
```

### ✅ Código Correcto (Conforme a Seguridad por Diseño: Secrets Tipados y Hashing Moderno)

```python
# src/core/security.py
import secrets
import hashlib
import hmac
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import SecretStr

class SecuritySettings(BaseSettings):
    """Configuración inmutable de secretos leída exclusivamente desde el entorno."""
    model_config = SettingsConfigDict(env_prefix="APP_", env_file=".env", extra="ignore")
    
    jwt_secret: SecretStr
    encryption_salt: SecretStr

def hashear_password_seguro(password_plana: str, salt: bytes | None = None) -> tuple[str, bytes]:
    """Genera un hash criptográficamente seguro usando PBKDF2-HMAC-SHA256 con salt aleatorio."""
    if len(password_plana) < 10:
        raise ValueError("La contraseña debe tener al menos 10 caracteres.")

    # Generación de salt criptográfico de 16 bytes
    salt_seguro = salt if salt is not None else secrets.token_bytes(16)
    
    # 100,000 iteraciones de PBKDF2 para mitigar ataques de fuerza bruta
    hash_bytes = hashlib.pbkdf2_hmac(
        hash_name="sha256",
        password=password_plana.encode("utf-8"),
        salt=salt_seguro,
        iterations=100_000
    )
    return hash_bytes.hex(), salt_seguro

def verificar_password(password_plana: str, hash_esperado: str, salt: bytes) -> bool:
    """Verificación en tiempo constante para mitigar ataques de temporización (Timing Attacks)."""
    hash_calculado, _ = hashear_password_seguro(password_plana, salt=salt)
    return hmac.compare_digest(hash_calculado, hash_esperado)
```

## 5. Descripción Didáctica de los Cambios

1. **Gestión de Secretos con `SecretStr`:** `Pydantic-settings` impide que la clave secreta se imprima accidentalmente en logs o volcados de memoria (`repr(jwt_secret)` oculta el valor real).
2. **Criptografía Robusta (PBKDF2-HMAC-SHA256):** Reemplaza MD5 por un algoritmo con salt criptográfico de 16 bytes y 100,000 iteraciones para resistir ataques por GPU.
3. **Protección contra Timing Attacks:** Uso de `hmac.compare_digest` para comparar hashes en tiempo constante, evitando que un atacante deduzca la clave midiendo tiempos de respuesta en nanosegundos.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobrecarga de Algoritmos Pesados en Tests:** Usar 600,000 iteraciones de hashing en suites de pruebas unitarias locales con 500 usuarios puede ralentizar los tests; se recomienda configurar un factor de costo reducido (`iterations=1000`) exclusivamente para el entorno de pruebas unitarias.
- **Entornos Locales de Prototipado Rápido:** No es necesario contratar un servicio de HSM (Hardware Security Module) en la nube para un script de prueba de concepto local.
- **Falsa Sensación de Seguridad por Cifrado:** Cifrar datos en reposo no protege si las claves de desencriptado residen en el mismo servidor sin control de acceso.

## 7. Checklist de Verificación

- [ ] ¿El repositorio está 100% libre de claves de API, tokens o contraseñas hardcodeadas?
- [ ] ¿Todos los secretos se cargan mediante variables de entorno protegidas con `SecretStr`?
- [ ] ¿Se utilizan algoritmos criptográficos modernos (Argon2id, PBKDF2-SHA256, AES-GCM) en lugar de MD5/SHA1?
- [ ] ¿Las comparaciones de tokens y hashes utilizan funciones de tiempo constante (`hmac.compare_digest`)?