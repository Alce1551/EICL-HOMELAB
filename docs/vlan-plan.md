# Plan de VLAN y direccionamiento

**Laboratorio:** LAB-001 · **Versión:** 1.4 · **Fecha:** 28/10/2026

## Criterios

- Rango del laboratorio: **10.10.0.0/16**, con el tercer octeto igual al ID de VLAN (D-001).
- Ruteo inter-VLAN en el firewall (*router-on-a-stick*); los switches trabajan en capa 2 (D-002).
- VLAN nativa sin uso (999) en todos los trunks; la VLAN 1 no transporta tráfico.
- Dominio interno: `eicl.internal`.

## VLAN

| VLAN | Nombre | Subred | Gateway | DHCP | Estado |
|---|---|---|---|---|---|
| 10 | VLAN10-MGMT | 10.10.10.0/24 | 10.10.10.1 | .100–.120 | Activa |
| 20 | VLAN20-SRV | 10.10.20.0/24 | 10.10.20.1 | .100–.199 | Activa |
| 30 | VLAN30-MON | 10.10.30.0/24 | 10.10.30.1 | Sin DHCP | Creada, sin puertos |
| 40 | VLAN40-DMZ | 10.10.40.0/24 | 10.10.40.1 | Sin DHCP | Creada, sin puertos |
| 50 | VLAN50-LAB | 10.10.50.0/24 | 10.10.50.1 | .100–.199 | Activa |
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

## Servicios de red

- **DNS para clientes:** 1.1.1.1 y 8.8.8.8 (entregados por DHCP).
- **Hora:** `pool.ntp.org` → FGT-LAB-01 (servidor NTP solo en VLAN10-MGMT) → SW-LAB-01 y los hipervisores (D-007). El Omada no soporta NTP.
