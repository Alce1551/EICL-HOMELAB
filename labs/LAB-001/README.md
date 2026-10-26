# LAB-001 — Infraestructura física y red base

**Estado:** completado · **Periodo:** 23/10/2026 – 25/10/2026

Levantar la red base del laboratorio: firewall perimetral con segmentación por VLAN, switch principal, switch de acceso, montaje en rack y validación de punta a punta.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | FortiGate 50E (FGT-LAB-01) | ✅ Completado | `fortigate/` · [lab-001-fortigate-v1.2](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-001-fortigate-v1.2) |
| B | Huawei S5735 (SW-LAB-01) | ✅ Completado | `huawei/` · [lab-001-huawei-v1.1](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-001-huawei-v1.1) |
| C | Omada ES208G (SW-LAB-02) | ✅ Completado | `omada/` · [lab-001-omada-v1.1](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-001-omada-v1.1) |
| D | Rack, cableado y etiquetado | ✅ Completado | No se publica (D-024) |
| E | Topología y tabla de puertos | ✅ Completado | [`docs/architecture.md`](../../docs/architecture.md) · [`docs/port-mapping.md`](../../docs/port-mapping.md) |
| F | Validación de punta a punta | ✅ Completado | [`docs/validacion.md`](../../docs/validacion.md) |
| G | Entregables | ✅ Completado | [`docs/implementation.md`](../../docs/implementation.md) y resto de [`docs/`](../../docs/) |

## Lo más relevante de cada componente

**A — Firewall.** Recuperación de acceso y reset de fábrica de un equipo usado, subinterfaces VLAN sobre un puerto dedicado, DHCP por segmento, políticas de mínimo privilegio con registro, administración restringida por trusted hosts, red OOB de emergencia y NTP interno. La memoria cubre la configuración base (23/10/2026); los cambios posteriores del firewall se documentan en las memorias del switch principal y del switch de acceso.

**B — Switch principal.** Endurecimiento desde cero: usuario local con AAA, SSH con llave RSA 3072 y Telnet deshabilitado, ACL de administración también aplicada al servidor SSH (SFTP incluido), STP con raíz definida y protección BPDU, puertos sin uso en VLAN 999 y apagados, respaldo por SFTP.

**C — Switch de acceso.** Integración de un equipo *easy managed* con capacidades limitadas: levantamiento aislado, VLAN 802.1Q, migración de la gestión a VLAN 10 sin perder acceso (y un incidente documentado), Loop Prevention y protección `root-protection` en el puerto del switch principal que lo conecta.

**D — Montaje físico.** Equipos de red montados en rack, cableados y etiquetados. El detalle físico no se publica por seguridad (D-024); las conexiones se documentan puerto a puerto.

**E — Topología.** Topología lógica (segmentos, gateways y flujos) y de enlaces, con capacidad prevista para hasta cuatro nodos de cómputo en el switch principal (D-025).

**F — Validación.** Ocho pruebas de punta a punta, positivas y negativas, repetidas a través del switch de acceso.

**G — Entregables.** Memorias técnicas por componente, procedimiento de implementación, plan de VLAN, mapa de puertos, decisiones y validaciones.

## Carpetas

```
fortigate/   componente A
├── EICL-LAB-001-fortigate-levantamiento.tex
└── evidencias/LAB-001-fortigate/          capturas E-01 a E-28, saneadas
huawei/      componente B
├── EICL-LAB-001-huawei-levantamiento.tex
├── evidence/                              capturas EVID-nnn y salidas de consola, saneadas
└── configs/                               comandos aplicados (reconstruidos y saneados)
omada/       componente C
├── EICL-LAB-001-omada-levantamiento.tex
└── evidence/                              capturas EVID-nnn, saneadas
```

Cada memoria se compila automáticamente y se publica como PDF en [Releases](https://github.com/Alce1551/EICL-HOMELAB/releases).
