---
id: bp_754qvx5sj0bvgt2pqnjegwt4p4
name: 09_continuous_delivery
title: "Entrega y Despliegue Continuo (CD)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/09_continuous_delivery.md
version: 1.1.0
category: code_standards
tags: [continuous-delivery, continuous-deployment, cd, devops, docker, release, universal_principles]
description: "Entrega Continua: pipelines reproducibles de empaquetado, release y despliegue seguro con rollback."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 09 - Entrega y Despliegue Continuo (CD)

## 1. Definición y Fundamento Teórico

Conceptualizado y formalizado por **Jez Humble** y **David Farley** en su obra de referencia *Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation* (2010), el principio de **Entrega Continua (CD)** postula:

> *"El software debe construirse, probarse y empaquetarse de tal forma que esté siempre en un estado listo para ser desplegado a producción en cualquier momento, transformando los releases en eventos rutinarios, predecibles y de bajo riesgo."*

Se distinguen dos modalidades fundamentales:
- **Entrega Continua (*Continuous Delivery*):** Todo el proceso de construcción, pruebas y despliegue a entornos de prueba (*Staging*) es 100% automatizado; el paso a producción requiere una aprobación manual de un clic por decisión de negocio.
- **Despliegue Continuo (*Continuous Deployment*):** Cada cambio que supera con éxito todas las etapas del pipeline se despliega a producción inmediatamente sin intervención humana.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del Error Humano en Despliegues:** Suprime los pasos manuales por SSH o scripts improvisados que causan caídas de servicio.
- **Trazabilidad y Reproducibilidad Total:** Cada versión desplegada corresponde exactamente a un commit inmutable de Git y a un artefacto empaquetado (imagen Docker).
- **Rollback Instantáneo:** Facilita la reversión inmediata a la versión previa saludable en caso de detectar anomalías post-despliegue.

## 3. Relevancia en Sistemas con IA Agéntica

- **Despliegue Autónomo a Entornos Efímeros:** Permite que agentes de desarrollo autónomos creen entornos de prueba temporales (*Preview Environments*) para validar visual y funcionalmente sus cambios antes de solicitar revisión.
- **Estrategias Canary para Agentes:** Permite desplegar parches generados por IA a una fracción mínima del tráfico (1-5%), monitoreando métricas de error antes de expandir el release.
- **Cierre del Bucle DevOps:** El agente no solo genera el código, sino que puede supervisar el éxito del despliegue mediante comprobaciones de salud automáticas (*Health Checks*).

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Despliegue Manual Opaco por SSH)

```bash
# Antipatrón: Despliegue manual artesanal desde la máquina local
# Sin trazabilidad de artefactos, sin verificación de salud y sin posibilidad de rollback rápido
ssh deploy@servidor-produccion "cd /var/www/app && git pull && systemctl restart app"
# ERROR: Si la versión tiene un fallo fatal, el servidor se cae de inmediato
# y restaurar la versión anterior requiere tiempo manual valioso.
```

### ✅ Código Correcto (Conforme a CD: Pipeline Declarativo con Verificación de Salud)

```yaml
# .github/workflows/cd.yml (Pipeline de Despliegue Continuo Automatizado)
name: CD Pipeline

on:
  push:
    tags:
      - 'v*.*.*'  # Disparado por versiones etiquetadas (SemVer)

jobs:
  deploy_production:
    runs-on: ubuntu-latest
    steps:
      - name: Descargar código
        uses: actions/checkout@v4

      - name: Construir Imagen Docker Inmutable
        run: |
          IMAGE_TAG=ghcr.io/empresa/app:${{ github.ref_name }}
          docker build -t $IMAGE_TAG .
          echo "Imagen $IMAGE_TAG construida y versionada."

      - name: Ejecutar Despliegue con Estrategia Blue-Green
        run: |
          echo "Desplegando en entorno alternativo (Green)..."
          # Comando de orquestación (Kubernetes / AWS ECS / Cloud Run)

      - name: Verificación de Salud Automática (Health Check)
        run: |
          echo "Esperando confirmación de disponibilidad..."
          for i in {1..10}; do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.empresa.com/health || true)
            if [ "$STATUS" -eq 200 ]; then
              echo "Servicio saludable (HTTP 200). Despliegue exitoso."
              exit 0
            fi
            echo "Reintentando verificación de salud ($i/10)..."
            sleep 3
          done
          echo "Fallo de salud detectado. Iniciando ROLLBACK automático..."
          exit 1
```

## 5. Descripción Didáctica de los Cambios

1. **Artefactos Inmutables:** El build genera una imagen Docker etiquetada con la versión semántica estricta (`v1.2.0`), garantizando que lo probado en staging sea exactamente lo que llega a producción.
2. **Estrategia Segura (Blue-Green / Rolling):** El servicio nuevo se levanta en paralelo sin cortar el tráfico productivo.
3. **Verificación Activa y Rollback:** El pipeline consulta el endpoint `/health`; si no responde satisfactoriamente en el tiempo estipulado, el proceso aborta y revierte al estado anterior automáticamente.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Despliegue Continuo sin Observabilidad:** Aplicar despliegue continuo automático sin telemetría en tiempo real (APM, tasas de error, alertas) es peligroso; un fallo puede afectar a todos los usuarios antes de que el equipo lo note.
- **Entornos Altamente Regulados (Banca / Salud):** Sectores regulados exigen firmas y aprobaciones formales de auditoría humana por ley; en estos casos se adopta *Continuous Delivery* con una compuerta manual de liberación.
- **Dependencias de Migraciones de Base de Datos Pesadas:** Migraciones destructivas de esquemas de datos requieren técnicas especiales (*Expand/Contract Pattern*) para no romper versiones previas activas durante el despliegue.

## 7. Checklist de Verificación

- [ ] ¿El proceso de release y despliegue está 100% automatizado mediante scripts o pipelines de CD?
- [ ] ¿Los artefactos de producción son inmutables y están etiquetados con versiones de Git (SemVer / Commit SHA)?
- [ ] ¿El pipeline incluye verificaciones de salud post-despliegue (*Health Checks*) con reversión (*Rollback*) automática?
- [ ] ¿Las migraciones de base de datos son compatibles hacia atrás con la versión previa del código?