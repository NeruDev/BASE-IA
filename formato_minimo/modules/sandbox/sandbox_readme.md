# Directorio de Sandbox y Experimentación Aislada

> [!WARNING]
> **Espacio Efímero y Desechable:** El contenido de este directorio está destinado exclusivamente a pruebas de concepto, scripts de depuración rápida y prototipos temporales.

## Reglas Operativas para Agentes y Desarrolladores

1. **Aislamiento Estricto:** Los archivos de este directorio están excluidos de Git y NUNCA deben ser importados por código en `src/` ni en `tests/`.
2. **Blast Radius Controlado:** No colocar credenciales reales ni apuntar a recursos productivos desde scripts aquí alojados.
3. **Ciclo de Promoción:** Si un prototipo resulta exitoso, promoverlo siguiendo el protocolo en 5 pasos hacia `src/` y agregar las pruebas correspondientes.
