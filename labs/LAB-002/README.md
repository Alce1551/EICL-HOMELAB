# LAB-002 — Proxmox y VMware

**Estado:** en curso · **Inicio:** 25/10/2026

Desplegar dos plataformas de virtualización sobre la red base de LAB-001, comparar su operación y formar un clúster Proxmox de tres nodos con quórum propio.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | Red de los nodos en el switch principal (GE0/0/2–4) | ✅ Completado | [`EICL-LAB-002-hipervisores-levantamiento`](EICL-LAB-002-hipervisores-levantamiento.tex) · [lab-002-v1.0](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-002-v1.0) |
| B | `pve-lab-01` (SRV-01) · Proxmox VE | ✅ Completado | Misma memoria (A–D) |
| C | `pve-lab-02` (SRV-02) · Proxmox VE | ✅ Completado | Misma memoria (A–D) |
| D | `esx-lab-01` (SRV-03) · VMware ESXi | ✅ Completado | Misma memoria (A–D) |
| E | Clúster Proxmox de tres nodos | ⏳ Pendiente | — |
| F | Redes virtuales por VLAN y una máquina virtual Linux por plataforma | ⏳ Pendiente | — |
| G | `pve-lab-03` (SRV-04) · Proxmox VE, tercer nodo del clúster | ✅ Completado | Memoria pendiente |

## Lo más relevante de cada componente

**A — Red de los nodos.** Tres puertos del switch principal pasan de VLAN sin uso y apagados a trunk: la VLAN de gestión va sin etiqueta para el hipervisor y las VLAN de servicios van etiquetadas para las máquinas virtuales (D-028). El ruteo entre máquinas virtuales de distintas VLAN sigue pasando por el firewall.

**B y C — Proxmox VE.** Instalación desde cero con IP fija en la VLAN de gestión, cambio al repositorio sin suscripción, actualización del kernel, hora sincronizada con el firewall y resolución por nombre entre los dos nodos como preparación del clúster.

**D — VMware ESXi.** Versión gratuita instalada en el mismo hardware, con su tarjeta de red reconocida de forma nativa. Se detectó y corrigió un reloj adelantado seis horas (lección en [`validacion.md`](../../docs/validacion.md)).

**G — Cuarto nodo.** Un cuarto OptiPlex, con la mitad de RAM que los demás, se integra como tercer Proxmox para que el clúster tenga quórum propio sin un QDevice externo (D-031). Ocupa `GE0/0/6` del switch principal, contiguo a los otros nodos y configurado como trunk igual que ellos; el acceso de gestión que estaba en ese puerto pasa a `GE0/0/9` (D-030).

## Nodos

| Nodo | Hostname | Plataforma | IP de gestión |
|---|---|---|---|
| SRV-01 | `pve-lab-01` | Proxmox VE 9.x | 10.10.10.11 |
| SRV-02 | `pve-lab-02` | Proxmox VE 9.x | 10.10.10.12 |
| SRV-03 | `esx-lab-01` | VMware ESXi 8.0 | 10.10.10.13 |
| SRV-04 | `pve-lab-03` | Proxmox VE 9.x | 10.10.10.14 |

Hardware, puertos y decisiones en [`docs/architecture.md`](../../docs/architecture.md), [`docs/port-mapping.md`](../../docs/port-mapping.md) y [`docs/decisiones.md`](../../docs/decisiones.md). Pruebas en [`docs/validacion.md`](../../docs/validacion.md).

## Incidentes

| ID | Resumen | Estado |
|---|---|---|
| [INC-001](../../incidentes/INC-001-nodo-sin-enlace-fisico.md) | `pve-lab-01` sin enlace físico con el switch principal (conector mal insertado) | ✅ Resuelto |

## Carpetas

```
EICL-LAB-002-hipervisores-levantamiento.tex   memoria de los componentes A a D (v1.0)
evidence/                                     capturas EVID-001 a EVID-017, saneadas
```

Los componentes A a D comparten una sola memoria porque se hicieron en la misma sesión y dependen unos de otros. Las versiones de software se publican generalizadas (Proxmox VE 9.x, ESXi 8.0; sin kernel, build ni BIOS) según la norma de protección. El clúster (E) y las redes virtuales (F) se agregarán como nuevas versiones o memorias propias.

Cada memoria se compila automáticamente y se publica como PDF en [Releases](https://github.com/Alce1551/EICL-HOMELAB/releases).
