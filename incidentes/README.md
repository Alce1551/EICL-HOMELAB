# Registro de incidentes

Fallas reales ocurridas durante la construcción y operación del laboratorio, documentadas con el mismo método que se usa en un área de soporte o de operaciones: qué se observó, cómo se diagnosticó, cuál fue la causa raíz, cómo se resolvió, cómo se comprobó y qué se cambia para que no se repita.

## Índice

| ID | Fecha | Equipo afectado | Capa | Síntoma | Tiempo de resolución | Estado |
|---|---|---|---|---|---|---|
| [INC-001](INC-001-nodo-sin-enlace-fisico.md) | 27/10/2026 | `pve-lab-01` · SW-LAB-01 `GE0/0/2` | 1 · Físico | `Destination Host Unreachable` entre nodos Proxmox | 17 min | ✅ Resuelto |
| [INC-002](INC-002-corte-electrico-general.md) | 29/10/2026 | Todo el laboratorio · `pve-lab-03` | 1 · Eléctrico | Corte eléctrico general; `pve-lab-03` no arranca solo al volver la energía | Pendiente (~26 h sin servicio del nodo) | 🔄 En curso |

## Resumen

| Indicador | Valor |
|---|---|
| Incidentes registrados | 2 |
| Resueltos | 1 |
| Abiertos o en curso | 1 |
| Tiempo medio de resolución | 17 min (solo incidentes resueltos) |
| Por capa | Capa 1: 2 |

## Método

1. **Detección:** qué prueba o síntoma reveló la falla, y desde qué equipo.
2. **Diagnóstico por capas:** de la capa física hacia arriba, descartando con evidencia antes de pasar a la siguiente.
3. **Causa raíz:** el motivo real de la falla, no solo el síntoma.
4. **Solución:** el cambio mínimo que corrige la causa.
5. **Validación:** la misma prueba que detectó la falla, repetida con éxito.
6. **Prevención:** qué se revisa o se cambia para que no se repita.

Severidad: **Alta** (afecta un servicio en uso o a varios equipos) · **Media** (un equipo sin servicio, sin impacto en servicios en uso) · **Baja** (degradación o aviso sin pérdida de servicio).

Los incidentes se registran con la misma norma de protección que el resto del repositorio: sin credenciales, sin MAC, sin IP de equipos personales. Para registrar uno nuevo se usa la [plantilla](PLANTILLA.md).
