# LAB-000 — Preparación, inventario y línea base

**Estado:** completado · **Periodo:** 14/10/2026 – 28/10/2026

Recepción e inspección del equipo, verificación de firmware, inventario de hardware, limpieza de configuraciones previas y definición del direccionamiento.

| Actividad | Estado |
|---|---|
| Verificación de firmware del firewall y del switch principal | ✅ Completada |
| Red doméstica documentada | ✅ Completada (solo lo que delimita el laboratorio, D-036) |
| Plan de direccionamiento y VLAN | ✅ Implementado y validado en LAB-001 |
| Eliminación de configuraciones anteriores | ✅ Completada (los nodos se reinstalaron desde cero en LAB-002; respaldo selectivo previo no aplicó, D-033) |
| Montaje en rack de los equipos de red y de los nodos | ✅ Completado (detalle físico no publicado, D-024) |
| Arranque, POST y especificaciones de los servidores | ✅ Completado: cuatro OptiPlex 5070 Micro (i5-9500T, SSD de ~256 GB, una interfaz de red); tres con 16 GB de RAM y uno con 8 GB |
| Revisión de la placa base de repuesto | ✅ Completada: instalada en SRV-01 |
| Verificación del material del cable | ✅ Completada: todo el cableado es CCA; se acepta con PoE apagado (D-032) |
| Inventario completo | ✅ Completado |

## Lo más relevante

**Inventario con evidencia.** Cuatro nodos inspeccionados y operativos, con especificaciones confirmadas en consola, en lugar de dar por buenas las fichas de compra.

**Cableado CCA detectado y acotado.** La verificación del material mostró que todos los cables son de aluminio recubierto de cobre (CCA). En vez de reemplazarlos, se comprobó que los enlaces en uso negocian 1000M/full sin errores y que los pares están bien (prueba de cable del switch), y se aceptó el riesgo con una condición clara: PoE apagado y reemplazo por cobre sólido si aparecen errores o se necesita PoE (D-032).

**Cierre por criterios.** La etapa se cierra al cumplir sus siete criterios; lo que no aplicaba se cerró con decisión registrada (D-033 a D-036), no por omisión.

## Memoria técnica

| Versión | Fecha | Release |
|---|---|---|
| 1.0 | 28/10/2026 | [lab-000-v1.0](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-000-v1.0) |
| 0.3 | 25/10/2026 | [lab-000-v0.3](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-000-v0.3) |

La v1.0 cierra la Etapa 00: cuatro nodos inventariados, placa base de repuesto, material del cable, topología AS-IS y decisiones de cierre. La v0.3 se conserva como versión anterior.

## Carpetas

```
EICL-LAB-000-preparacion-inventario-y-linea-base.tex   fuente de la memoria técnica (v1.0)
evidence/                                              capturas y salida de consola EVID-001 a EVID-006, saneadas
```
