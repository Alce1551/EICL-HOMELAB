# Plan de VLAN y direccionamiento

**Laboratorio:** LAB-001 · **Versión:** 1.0 · **Fecha:** 24/10/2026

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

| IP | Equipo |
|---|---|
| 10.10.10.1 | FGT-LAB-01 (FortiGate 50E) |
| 10.10.10.2 | SW-LAB-01 (Huawei S5735) |
| 10.10.10.3 | SW-LAB-02 (Omada ES208G) |

## Servicios de red

- **DNS para clientes:** 1.1.1.1 y 8.8.8.8 (entregados por DHCP).
- **Hora:** `pool.ntp.org` → FGT-LAB-01 (servidor NTP solo en VLAN10-MGMT) → SW-LAB-01 (D-007). El Omada no soporta NTP.
