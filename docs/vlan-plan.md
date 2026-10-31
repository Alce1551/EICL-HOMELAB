# Plan de VLAN y direccionamiento

**Laboratorio:** LAB-001 · **Versión:** 1.6 · **Fecha:** 31/10/2026

## Criterios

- Rango del laboratorio: **10.10.0.0/16**, con el tercer octeto igual al ID de VLAN (D-001).
- Ruteo inter-VLAN en el firewall (*router-on-a-stick*); los switches trabajan en capa 2 (D-002).
- VLAN nativa sin uso (999) en los trunks entre equipos de red; la VLAN 1 no transporta tráfico. Excepción: los trunks de los hipervisores llevan la VLAN 10 sin etiqueta (D-028), y por eso ninguna VM usa la VLAN 10 (D-038, D-041).
- Dominio interno: `eicl.internal`.

## VLAN

| VLAN | Nombre | Subred | Gateway | DHCP | Estado |
|---|---|---|---|---|---|
| 10 | VLAN10-MGMT | 10.10.10.0/24 | 10.10.10.1 | .100–.120 | Activa · acceso en `GE0/0/7` del switch principal y puerto 2 del switch de acceso (D-048) |
| 20 | VLAN20-SRV | 10.10.20.0/24 | 10.10.20.1 | .100–.199 | Activa · servicios de LAB-003 (NAS). Sin puerto de acceso en el switch principal; pruebas en el puerto 3 del switch de acceso |
| 30 | VLAN30-MON | 10.10.30.0/24 | 10.10.30.1 | Sin DHCP | Creada · `GE0/0/8` reservado y apagado para el monitoreo de LAB-005 (D-046, D-048) |
| 40 | VLAN40-DMZ | 10.10.40.0/24 | 10.10.40.1 | Sin DHCP | Creada, sin puertos |
| 50 | VLAN50-LAB | 10.10.50.0/24 | 10.10.50.1 | .100–.199 | Activa · clientes en los puertos 4, 5 y 7 del switch de acceso; sin puerto de acceso en el switch principal |
| 60 | Respaldos | Reservada | — | — | LAB-008 |
| 70 | Clúster Proxmox | Reservada | — | — | LAB-012 |
| 999 | NATIVA-SIN-USO | Solo en switches | — | — | PVID de trunks y puertos sin uso |
| — | OOB (lan1–lan4 del firewall) | 10.10.254.0/24 | 10.10.254.1 | .100–.110, sin internet | Emergencia |

En el switch de acceso (Omada) los nombres se acortan por el límite del campo: `V10-MGMT`, `V20-SRV`, `V50-LAB`, `V999-NATIV` (D-016). Lo que une las VLAN entre equipos es el ID, no el nombre.

## Convención dentro de cada /24

| Rango | Uso |
|---|---|
| .1 | Gateway (firewall) |
| .2–.9 | Equipos de red |
| .10–.49 | Servidores e hipervisores |
| .50–.99 | Reservado |
| .100–.199 | DHCP |
| .200–.254 | Reservado |

## IP de infraestructura

| IP | Equipo | Estado |
|---|---|---|
| 10.10.10.1 | FGT-LAB-01 (FortiGate 50E) | Asignada |
| 10.10.10.2 | SW-LAB-01 (Huawei S5735) | Asignada |
| 10.10.10.3 | SW-LAB-02 (Omada ES208G) | Asignada |
| 10.10.10.11 | `pve-lab-01` (SRV-01, Proxmox) | Asignada |
| 10.10.10.12 | `pve-lab-02` (SRV-02, Proxmox) | Asignada |
| 10.10.10.13 | `esx-lab-01` (SRV-03, VMware ESXi) | Asignada |
| 10.10.10.14 | `pve-lab-03` (SRV-04, Proxmox) | Asignada |

Las IP de los nodos siguen la convención (.10–.49 para servidores e hipervisores) y el último octeto coincide con el número del equipo físico (SRV-NN). Los hostnames siguen la convención `TIPO-LAB-NN` con el dominio `eicl.internal` y numeran por plataforma (D-029, D-031). Los nodos usan gateway 10.10.10.1 y DNS 1.1.1.1.

## IP de servicios (VLAN 20)

| IP | Uso | Estado |
|---|---|---|
| 10.10.20.10–.19 | Reservadas para los servicios base de LAB-003 (DNS interno y siguientes) | Reservadas (D-045) |
| 10.10.20.20 | `nas-lab-01` (NAS OpenMediaVault en `esx-lab-01`) | Asignada (D-045) |

Las IP de servicio son fijas y quedan fuera del rango DHCP. Las máquinas virtuales de prueba de LAB-002 tomaban su IP por DHCP en la VLAN 20 (D-039) y se retiran en LAB-003 (D-043).

## Servicios de red

- **DNS para clientes:** 1.1.1.1 y 8.8.8.8 (entregados por DHCP).
- **Hora:** `pool.ntp.org` → FGT-LAB-01 (servidor NTP solo en VLAN10-MGMT) → SW-LAB-01 y los cuatro hipervisores (D-007). El Omada no soporta NTP. El NAS, en la VLAN 20, toma la hora de `pool.ntp.org` directamente, porque el firewall solo sirve NTP en la VLAN 10.
