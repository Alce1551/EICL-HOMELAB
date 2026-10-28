# Mapa de puertos

**Laboratorio:** LAB-001 · **Versión:** 1.5 · **Fecha:** 28/10/2026

## FGT-LAB-01 — FortiGate 50E

| Puerto | Uso | Configuración |
|---|---|---|
| wan1 | Enlace al router doméstico | 192.168.1.2/24, ruta por defecto |
| lan5 | Trunk hacia SW-LAB-01 GE0/0/1 | Subinterfaces VLAN 10, 20, 30, 40 y 50 |
| lan1–lan4 | Red OOB de emergencia | 10.10.254.1/24, DHCP, sin internet (D-005) |

## SW-LAB-01 — Huawei S5735-L8P4S-A1 (switch principal)

| Puerto | Uso | Modo / VLAN | Estado |
|---|---|---|---|
| GE0/0/1 | FGT-LAB-01 lan5 | trunk 10–50 · PVID 999 · sin VLAN 1 | Activo |
| GE0/0/2 | `pve-lab-01` (SRV-01, Proxmox) · `SRV-01-PROXMOX` | trunk · PVID 10 · VLAN 10–50 · sin VLAN 1 · edge (D-028) | Activo |
| GE0/0/3 | `pve-lab-02` (SRV-02, Proxmox) · `SRV-02-PROXMOX` | trunk · PVID 10 · VLAN 10–50 · sin VLAN 1 · edge (D-028) | Activo |
| GE0/0/4 | `esx-lab-01` (SRV-03, ESXi) · `SRV-03-ESXI` | trunk · PVID 10 · VLAN 10–50 · sin VLAN 1 · edge (D-028) | Activo |
| GE0/0/5 | Uplink a SW-LAB-02 puerto 1 | trunk 10, 20, 50 · PVID 999, sin la 999 permitida (D-042) · `stp root-protection` | Activo |
| GE0/0/6 | `pve-lab-03` (SRV-04, Proxmox) · `SRV-04-PROXMOX` | trunk · PVID 10 · VLAN 10–50 · sin VLAN 1 · edge (D-028, D-030) | Activo |
| GE0/0/7 | Pruebas SRV | access 20 · edge | Activo |
| GE0/0/8 | Clientes LAB | access 50 · edge | Activo |
| GE0/0/9 | Acceso MGMT (laptop o equipo de administración) · `ACCESO-MGMT-VLAN10` · puerto SFP | access 10 · edge (D-030) | Configurado · **sin módulo SFP**, sin enlace |
| GE0/0/10–12 (SFP) | Sin uso | access 999 | Apagados |

Protecciones globales: STP raíz primaria (prioridad 0), `stp bpdu-protection` en puertos edge, PoE apagado en todos los puertos (D-009). Gestión solo por SSH en Vlanif10 (10.10.10.2), limitada por ACL.

## SW-LAB-02 — TP-Link Omada ES208G (switch de acceso)

| Puerto | Uso | Modo / VLAN | Estado |
|---|---|---|---|
| 1 | Uplink a SW-LAB-01 GE0/0/5 | V10, V20, V50 tagged · PVID 999 | Activo |
| 2 | Acceso MGMT | V10 untagged · PVID 10 | Activo |
| 3 | Pruebas SRV | V20 untagged · PVID 20 | Activo |
| 4–5 | Clientes LAB | V50 untagged · PVID 50 | Activos |
| 6 | Sin uso (único miembro posible de VLAN 1, D-017) | V999 untagged · PVID 999 | Deshabilitado |
| 7 | Banco de clientes: TL-SG108 no administrable (D-026) | V50 untagged · PVID 50 | Activo |
| 8 | Sin uso | V999 untagged · PVID 999 | Deshabilitado |

Loop Prevention habilitado (D-015) e Ingress Checking activo. Gestión web solo en VLAN 10 (10.10.10.3).

## Hipervisores — interfaces y red virtual

Cada nodo tiene una sola NIC conectada a su trunk del switch principal (D-028). La VLAN 10 llega sin etiqueta y las VLAN 20 a 50 etiquetadas.

| Nodo | NIC física | Conmutador virtual | VLAN permitidas para VM | Gestión |
|---|---|---|---|---|
| `pve-lab-01` | `nic0` · GE0/0/2 | `vmbr0` *VLAN aware* | 20, 30, 40, 50 | 10.10.10.11 en `vmbr0`, sin etiqueta |
| `pve-lab-02` | `nic0` · GE0/0/3 | `vmbr0` *VLAN aware* | 20, 30, 40, 50 | 10.10.10.12 en `vmbr0`, sin etiqueta |
| `pve-lab-03` | `nic0` · GE0/0/6 | `vmbr0` *VLAN aware* | 20, 30, 40, 50 | 10.10.10.14 en `vmbr0`, sin etiqueta |
| `esx-lab-01` | `vmnic0` · GE0/0/4 | `vSwitch0` | *Port group* `VLAN20-SRV` (VLAN ID 20) | 10.10.10.13 en `vmk0` (*Management Network*, sin etiqueta) |

Ninguna VM usa la VLAN 10; en ESXi, `VM Network` (VLAN 0) no se usa para VM (D-038, D-041). Los *port groups* de las VLAN 30, 40 y 50 se crean cuando haya una VM que los necesite.

| VM | Hipervisor | Interfaz | Conectada a |
|---|---|---|---|
| `deb-lab-01` | `pve-lab-01` | `net0` VirtIO (`ens18` en la VM) | `vmbr0`, etiqueta 20 |
| `deb-lab-02` | `esx-lab-01` | Adaptador VMXNET 3 (`ens192` en la VM) | *Port group* `VLAN20-SRV` |

## Enlaces entre equipos

| Origen | Destino | Tipo | Estado |
|---|---|---|---|
| Router doméstico (LAN) | FGT-LAB-01 wan1 | Enlace WAN | Activo |
| FGT-LAB-01 lan5 | SW-LAB-01 GE0/0/1 | Trunk 802.1Q · VLAN 10–50 · nativa 999 | Activo |
| SW-LAB-01 GE0/0/5 | SW-LAB-02 puerto 1 | Trunk 802.1Q · VLAN 10/20/50 · nativa 999 | Activo |
| SW-LAB-02 puerto 7 | TL-SG108 (banco de clientes) | Acceso VLAN 50 | Activo |
| SW-LAB-01 GE0/0/2 | pve-lab-01 | Trunk 802.1Q · VLAN 10 sin etiqueta · VLAN 20–50 etiquetadas | Activo |
| SW-LAB-01 GE0/0/3 | pve-lab-02 | Trunk 802.1Q · VLAN 10 sin etiqueta · VLAN 20–50 etiquetadas | Activo |
| SW-LAB-01 GE0/0/4 | esx-lab-01 | Trunk 802.1Q · VLAN 10 sin etiqueta · VLAN 20–50 etiquetadas | Activo |
| SW-LAB-01 GE0/0/6 | pve-lab-03 | Trunk 802.1Q · VLAN 10 sin etiqueta · VLAN 20–50 etiquetadas | Activo |

SRV-04 ocupa `GE0/0/6`, contiguo a los demás nodos; el acceso de gestión que estaba ahí pasa a `GE0/0/9`, que estaba sin uso (D-030). `GE0/0/9` es un puerto SFP y no tiene módulo instalado, así que hoy el switch principal no tiene un puerto de acceso de gestión operativo; la VLAN 10 se alcanza desde la PC de administración a través del firewall y desde el puerto 2 del switch de acceso. El acceso definitivo queda por decidir. El puerto 2 del switch de acceso sigue siendo un segundo acceso a la VLAN 10. Si hicieran falta más puertos en el switch principal, quedan tres SFP sin uso (GE0/0/10–12).

El TL-SG108 se conecta al switch de acceso con un solo cable. Todo lo que se conecta a él queda en la VLAN 50 y pasa por el firewall como cualquier otro cliente; ante un bucle protegen el Loop Prevention del switch de acceso y `stp root-protection` en GE0/0/5.

El montaje en rack, el cableado y el etiquetado están completados. Su detalle físico (fotos, plan de cables y etiquetas) no se publica (D-024).
