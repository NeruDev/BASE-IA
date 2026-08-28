---
id: bp_2jchw627jcb5hrb9fc7gvz3g2d
name: 08_infrastructure_as_code
title: "Infraestructura como Código (Infrastructure as Code - IaC)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/08_infrastructure_as_code.md
version: 1.1.0
category: code_standards
tags: [iac, infrastructure-as-code, docker-compose, terraform, devops, universal_principles]
description: "Infraestructura como Código: aprovisionamiento declarativo y versionado en Git de entornos y recursos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 08 - Infraestructura como Código (Infrastructure as Code - IaC)

## 1. Definición y Fundamento Teórico

Pilar fundacional de la cultura **DevOps** y la ingeniería de plataformas en la nube, la **Infraestructura como Código (IaC)** postula que:

> *"Todos los recursos de infraestructura (servidores, redes, bases de datos vectoriales, colas de mensajes y entornos de ejecución) deben definirse, aprovisionarse y configurarse de forma declarativa mediante archivos de código fuente versionados en Git, erradicando la administración manual de sistemas."*

Las dos filosofías principales de IaC son:
- **Declarativa (Recomendada):** Se describe el *estado final deseado* (ej. Terraform, Docker Compose, Kubernetes YAML) y el motor calcula las acciones para alcanzarlo.
- **Imperativa:** Se especifican las secuencias de comandos paso a paso para construir el entorno (ej. scripts de Bash).

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Deriva de Configuración (*Configuration Drift*):** Previene que los servidores diverjan con el tiempo debido a parches manuales indocumentados.
- **Aprovisionamiento Repetible en Minutos:** Permite clonar infraestructuras completas de producción en entornos de staging o pruebas en un solo paso.
- **Auditoría y Control de Cambios:** Cualquier modificación de infraestructura pasa por Pull Request, code review y pipeline de validación antes de aplicarse.

## 3. Relevancia en Sistemas con IA Agéntica

- **Entornos de Prueba Efímeros para Agentes (*Ephemeral Testbeds*):** Permite a agentes autónomos levantar dependencias complejas (PostgreSQL con `pgvector`, Redis, sandboxes de código) mediante `docker compose up -d`, ejecutar pruebas de integración y destruir los contenedores al concluir (*Self-Cleaning Environments*).
- **Aprovisionamiento Autónomo por Agentes:** Los agentes de DevOps pueden generar o ajustar configuraciones de Terraform o Docker Compose bajo contratos estrictos y reproducibles.
- **Aislamiento de Seguridad:** Garantiza que los agentes ejecuten código potencialmente riesgoso dentro de contenedores con límites estrictos de CPU, memoria y red declarados en código.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Guía de Pasos Manuales / Configuración Artesanal)

```markdown
# Antipatrón: Documento wiki con instrucciones manuales propensas a error humano
1. Iniciar sesión en el servidor por SSH: ssh admin@server-01
2. Instalar PostgreSQL a mano: sudo apt-get install postgresql
3. Crear base de datos: CREATE DATABASE agent_db;
4. Instalar extensión vectorial: apt install postgresql-15-pgvector
5. Configurar puertos y usuarios manualmente sin registro de auditoría...
# ERROR: Si el servidor falla, reconstruirlo tomará horas y no será idéntico.
```

### ✅ Código Correcto (Conforme a IaC: Manifiesto Declarativo Docker Compose)

```yaml
# docker-compose.yml (Infraestructura Declarativa para Entorno Agéntico)
version: '3.8'

services:
  # Base de datos vectorial para memoria semántica del agente
  vector-db:
    image: pgvector/pgvector:pg16
    container_name: agent_vector_db
    environment:
      POSTGRES_DB: agent_memory
      POSTGRES_USER: agent_user
      POSTGRES_PASSWORD: secure_dev_password_123
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U agent_user -d agent_memory"]
      interval: 3s
      timeout: 3s
      retries: 5

  # Caché en memoria para sesiones de subagentes
  redis-cache:
    image: redis:7.2-alpine
    container_name: agent_redis_cache
    ports:
      - "6379:6379"
    command: ["redis-server", "--maxmemory", "256mb", "--maxmemory-policy", "allkeys-lru"]

volumes:
  pgdata:
```

## 5. Descripción Didáctica de los Cambios

1. **Definición 100% Declarativa:** El archivo `docker-compose.yml` fija las imágenes exactas (`pg16`, `redis:7.2-alpine`), credenciales y límites de memoria.
2. **Chequeo de Salud Integrado (*Healthcheck*):** Garantiza que las aplicaciones cliente o agentes solo se conecten cuando PostgreSQL esté listo para recibir consultas.
3. **Reproducibilidad Inmediata:** Cualquier desarrollador o agente ejecuta `docker compose up -d` y dispone de la infraestructura idéntica a producción en 5 segundos.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Modificaciones Manuales Directas (*ClickOps*):** Si los miembros del equipo modifican configuraciones directamente en la consola web de AWS/Azure, el estado de IaC se desincroniza (*Drift*). Se deben aplicar permisos de solo lectura para humanos en producción.
- **Gestión de Estado y Bloqueos:** En herramientas como Terraform, la pérdida o corrupción del archivo de estado remoto (`terraform.tfstate`) puede requerir reconstrucciones complejas.
- **Sobrecarga en Tareas Aisladas Simples:** Para scripts puros sin servicios de soporte externos, crear manifiestos IaC añade complejidad innecesaria.

## 7. Checklist de Verificación

- [ ] ¿Toda la infraestructura requerida para desarrollo, testing y producción está definida en archivos de código en Git?
- [ ] ¿Se eliminaron las instrucciones manuales de configuración de servidores en favor de scripts o manifiestos IaC?
- [ ] ¿Los manifiestos definen chequeos de salud (*health checks*) y límites de recursos (memoria/CPU)?
- [ ] ¿Es posible destruir y reconstruir el entorno completo de forma determinista con un solo comando?