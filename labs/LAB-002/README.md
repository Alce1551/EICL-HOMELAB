# LAB-002 — Proxmox y VMware

**Estado:** en curso · **Inicio:** 25/10/2026

Desplegar dos plataformas de virtualización sobre la red base de LAB-001, comparar su operación y formar un clúster Proxmox de dos nodos con un tercer voto de quórum.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | Red de los nodos en el switch principal (GE0/0/2–4) | ✅ Completado | Pendiente de compilar |
| B | `pve-lab-01` (SRV-01) · Proxmox VE | ✅ Completado | Pendiente de compilar |
| C | `pve-lab-02` (SRV-02) · Proxmox VE | ✅ Completado | Pendiente de compilar |
| D | `esx-lab-01` (SRV-03) · VMware ESXi | ✅ Completado | Pendiente de compilar |
| E | Clúster Proxmox con tercer voto (QDevice) | ⏳ Pendiente | — |
| F | Redes virtuales por VLAN y una máquina virtual Linux por plataforma | ⏳ Pendiente | — |

## Lo más relevante de cada componente

**A — Red de los nodos.** Tres puertos del switch principal pasan de VLAN sin uso y apagados a trunk: la VLAN de gestión va sin etiqueta para el hipervisor y las VLAN de servicios van etiquetadas para las máquinas virtuales (D-028). El ruteo entre máquinas virtuales de distintas VLAN sigue pasando por el firewall.

**B y C — Proxmox VE.** Instalación desde cero con IP fija en la VLAN de gestión, cambio al repositorio sin suscripción, actualización del kernel, hora sincronizada con el firewall y resolución por nombre entre los dos nodos como preparación del clúster.

**D — VMware ESXi.** Versión gratuita instalada en el mismo hardware, con su tarjeta de red reconocida de forma nativa. Se detectó y corrigió un reloj adelantado seis horas (lección en [`validacion.md`](../../docs/validacion.md)).

## Nodos

| Nodo | Hostname | Plataforma | IP de gestión |
|---|---|---|---|
| SRV-01 | `pve-lab-01` | Proxmox VE 9.x | 10.10.10.11 |
| SRV-02 | `pve-lab-02` | Proxmox VE 9.x | 10.10.10.12 |
| SRV-03 | `esx-lab-01` | VMware ESXi 8.0 | 10.10.10.13 |

Hardware, puertos y decisiones en [`docs/architecture.md`](../../docs/architecture.md), [`docs/port-mapping.md`](../../docs/port-mapping.md) y [`docs/decisiones.md`](../../docs/decisiones.md). Pruebas en [`docs/validacion.md`](../../docs/validacion.md).

## Carpetas

Las memorias técnicas de este laboratorio se agregarán aquí cuando se compilen, una carpeta por componente, y su PDF se publicará en [Releases](https://github.com/Alce1551/EICL-HOMELAB/releases).
