# LAB-002 — Proxmox y VMware

**Estado:** completado · **Periodo:** 25/10/2026 – 28/10/2026

Desplegar dos plataformas de virtualización sobre la red base de LAB-001, comparar su operación y formar un clúster Proxmox de tres nodos con quórum propio, con una máquina virtual Linux en cada plataforma que respeta la segmentación del firewall.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | Red de los nodos en el switch principal (GE0/0/2–4 y 6) | ✅ Completado | [`EICL-LAB-002-hipervisores-levantamiento`](EICL-LAB-002-hipervisores-levantamiento.tex) · [lab-002-v1.1](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-002-v1.1) |
| B | `pve-lab-01` (SRV-01) · Proxmox VE | ✅ Completado | Misma memoria |
| C | `pve-lab-02` (SRV-02) · Proxmox VE | ✅ Completado | Misma memoria |
| D | `esx-lab-01` (SRV-03) · VMware ESXi | ✅ Completado | Misma memoria |
| E | Clúster Proxmox `pve-lab-clr` de tres nodos | ✅ Completado | Misma memoria |
| F | Redes virtuales por VLAN y una máquina virtual Linux por plataforma | ✅ Completado | Misma memoria |
| G | `pve-lab-03` (SRV-04) · Proxmox VE, tercer nodo del clúster | ✅ Completado | Misma memoria |

Versión anterior de la memoria (componentes A a D): [lab-002-v1.0](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-002-v1.0).

## Lo más relevante de cada componente

**A — Red de los nodos.** Cuatro puertos del switch principal pasan de VLAN sin uso y apagados a trunk: la VLAN de gestión va sin etiqueta para el hipervisor y las VLAN de servicios van etiquetadas para las máquinas virtuales (D-028). El ruteo entre máquinas virtuales de distintas VLAN sigue pasando por el firewall.

**B y C — Proxmox VE.** Instalación desde cero con IP fija en la VLAN de gestión, cambio al repositorio sin suscripción, actualización del kernel, hora sincronizada con el firewall y resolución por nombre entre los nodos como preparación del clúster.

**D — VMware ESXi.** Versión gratuita instalada en el mismo hardware, con su tarjeta de red reconocida de forma nativa. Se detectó y corrigió un reloj adelantado seis horas (lección en [`validacion.md`](../../docs/validacion.md)).

**G — Cuarto nodo.** Un cuarto OptiPlex, con la mitad de RAM que los demás, se integra como tercer Proxmox para que el clúster tenga quórum propio sin un QDevice externo (D-031). Ocupa `GE0/0/6` del switch principal, contiguo a los otros nodos; el acceso de gestión que estaba en ese puerto pasa a `GE0/0/9` (D-030), un puerto SFP que todavía no tiene módulo instalado. Antes de crear el clúster se alinearon las versiones de los tres Proxmox y se corrigieron dos errores en `/etc/hosts`, uno de ellos con un ping que respondía desde el equipo equivocado.

**E — Clúster de tres nodos.** Clúster `pve-lab-clr` (D-037) con transporte `knet` y autenticación segura sobre la VLAN de gestión: tres nodos, tres votos y quórum de 2. Con un nodo apagado el clúster siguió operando con 2 de 3 votos, y al encenderlo el nodo se reincorporó solo en unos dos minutos.

**F — Red virtual y máquinas virtuales.** En Proxmox, el bridge `vmbr0` de cada nodo pasa a *VLAN aware* con las VLAN 20 a 50 (D-038); en ESXi, un *port group* por VLAN (D-041). Una VM Debian en cada plataforma, en la VLAN 20 por DHCP, sale a internet y resuelve DNS, pero no alcanza la gestión de los hipervisores, el switch ni la red doméstica: la segmentación de LAB-001 se comprueba también desde máquinas virtuales.

## Nodos

| Nodo | Hostname | Plataforma | IP de gestión | Función |
|---|---|---|---|---|
| SRV-01 | `pve-lab-01` | Proxmox VE 9.x | 10.10.10.11 | Nodo 1 de `pve-lab-clr`; aloja `deb-lab-01` |
| SRV-02 | `pve-lab-02` | Proxmox VE 9.x | 10.10.10.12 | Nodo 2 de `pve-lab-clr` |
| SRV-03 | `esx-lab-01` | VMware ESXi 8.0 | 10.10.10.13 | Plataforma VMware; aloja `deb-lab-02` |
| SRV-04 | `pve-lab-03` | Proxmox VE 9.x | 10.10.10.14 | Nodo 3 de `pve-lab-clr` (8 GB de RAM) |

## Máquinas virtuales de prueba

| VM | Plataforma | Recursos | Red | Resultado |
|---|---|---|---|---|
| `deb-lab-01` | Proxmox (`pve-lab-01`, VMID 100) | 2 vCPU (tipo por defecto, D-040) · 2 GiB · 16 GiB | VirtIO en `vmbr0`, etiqueta 20 | DHCP en la VLAN 20, internet y DNS; sin acceso a gestión ni a la red doméstica |
| `deb-lab-02` | ESXi (`esx-lab-01`) | 2 vCPU · 2 GB · 16 GB *thin* | VMXNET 3 en el *port group* `VLAN20-SRV` | Igual que `deb-lab-01` |

Las dos VM usan Debian 13 (netinst, solo servidor SSH) con su agente de invitado (D-039).

Hardware, puertos y decisiones en [`docs/architecture.md`](../../docs/architecture.md), [`docs/port-mapping.md`](../../docs/port-mapping.md) y [`docs/decisiones.md`](../../docs/decisiones.md). Pruebas en [`docs/validacion.md`](../../docs/validacion.md).

## Incidentes

| ID | Resumen | Estado |
|---|---|---|
| [INC-001](../../incidentes/INC-001-nodo-sin-enlace-fisico.md) | `pve-lab-01` sin enlace físico con el switch principal (conector mal insertado) | ✅ Resuelto |

## Carpetas

```
EICL-LAB-002-hipervisores-levantamiento.tex   memoria de los componentes A a G (v1.1)
evidence/                                     capturas EVID-001 a EVID-063, saneadas
                                              (EVID-032 y EVID-033: salidas de consola en texto)
```

Los siete componentes comparten una sola memoria porque dependen unos de otros: la v1.0 cubrió A a D y la v1.1 agrega E, F y G. Las versiones de software se publican generalizadas (Proxmox VE 9.x, ESXi 8.0, Debian 13; sin kernel, build ni BIOS) según la norma de protección.

Quedan fuera de este laboratorio, y se abordan después: grupos de alta disponibilidad y migración de VM entre nodos, segundo enlace del clúster en la VLAN 70 (LAB-012), VM de monitoreo en el ESXi (LAB-005) y DNS interno que sustituya `/etc/hosts` (LAB-003).

Cada memoria se compila automáticamente y se publica como PDF en [Releases](https://github.com/Alce1551/EICL-HOMELAB/releases).
