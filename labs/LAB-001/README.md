# LAB-001 — Infraestructura física y red base

**Estado:** en curso · **Inicio:** 23/10/2026

Levantar la red base del laboratorio: firewall perimetral con segmentación por VLAN, switch principal, switch de acceso, montaje en rack y validación de punta a punta.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | FortiGate 50E (FGT-LAB-01) | ✅ Completado | `fortigate/` · Release `lab-001-fortigate-v1.1` |
| B | Huawei S5735 (SW-LAB-01) | ✅ Completado | `huawei/` · Release `lab-001-huawei-v1.0` |
| C | Omada ES208G (SW-LAB-02) | ✅ Completado | `omada/` · memoria en preparación |
| D | Rack, cableado y etiquetado | 🔄 En curso | — |
| E | Topología y tabla de puertos | 🔄 En curso | [`docs/port-mapping.md`](../../docs/port-mapping.md) |
| F | Validación de punta a punta | ✅ Completado | [`docs/validacion.md`](../../docs/validacion.md) |
| G | Entregables | 🔄 En curso | [`docs/`](../../docs/) |

## Lo más relevante de cada componente

**A — Firewall.** Recuperación de acceso y reset de fábrica de un equipo usado, subinterfaces VLAN sobre un puerto dedicado, DHCP por segmento, cinco políticas con registro, administración restringida por trusted hosts, red OOB de emergencia y NTP interno.

**B — Switch principal.** Endurecimiento desde cero: usuario local con AAA, SSH con llave RSA 3072 y Telnet deshabilitado, ACL de administración también aplicada al servidor SSH (SFTP incluido), STP con raíz definida y protección BPDU, puertos sin uso en VLAN 999 y apagados, respaldo por SFTP.

**C — Switch de acceso.** Integración de un equipo *easy managed* con capacidades limitadas: levantamiento aislado, VLAN 802.1Q, migración de la gestión a VLAN 10 sin perder acceso (y un incidente documentado), Loop Prevention y protección `root-protection` en el puerto del switch principal que lo conecta.

## Carpetas

```
fortigate/   memoria (.tex) y evidencias saneadas del componente A
huawei/      ídem, componente B
omada/       ídem, componente C
```
