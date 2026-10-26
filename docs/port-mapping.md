# Mapa de puertos

**Laboratorio:** LAB-001 · **Versión:** 1.1 · **Fecha:** 25/10/2026

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
| GE0/0/2 | Reservado SRV-01 (Proxmox) | access 999 | Apagado hasta LAB-002 |
| GE0/0/3 | Reservado SRV-02 (ESXi) | access 999 | Apagado hasta LAB-002 |
| GE0/0/4 | Reservado SRV-03 | access 999 | Apagado hasta LAB-002 |
| GE0/0/5 | Uplink a SW-LAB-02 puerto 1 | trunk 10, 20, 50 · PVID 999 · `stp root-protection` | Activo |
| GE0/0/6 | Acceso MGMT | access 10 · edge | Activo |
| GE0/0/7 | Pruebas SRV · reservado para SRV-04 (D-025) | access 20 · edge | Activo; pasa a SRV-04 si se incorpora en LAB-002 |
| GE0/0/8 | Clientes LAB | access 50 · edge | Activo |
| GE0/0/9–12 (SFP) | Sin uso | access 999 | Apagados |

Protecciones globales: STP raíz primaria (prioridad 0), `stp bpdu-protection` en puertos edge, PoE apagado en todos los puertos (D-009). Gestión solo por SSH en Vlanif10 (10.10.10.2), limitada por ACL.

## SW-LAB-02 — TP-Link Omada ES208G (switch de acceso)

| Puerto | Uso | Modo / VLAN | Estado |
|---|---|---|---|
| 1 | Uplink a SW-LAB-01 GE0/0/5 | V10, V20, V50 tagged · PVID 999 | Activo |
| 2 | Acceso MGMT | V10 untagged · PVID 10 | Activo |
| 3 | Pruebas SRV | V20 untagged · PVID 20 | Activo |
| 4–5 | Clientes LAB | V50 untagged · PVID 50 | Activos |
| 6 | Sin uso (único miembro posible de VLAN 1, D-017) | V999 untagged · PVID 999 | Deshabilitado |
| 7–8 | Sin uso | V999 untagged · PVID 999 | Deshabilitados |

Loop Prevention habilitado (D-015) e Ingress Checking activo. Gestión web solo en VLAN 10 (10.10.10.3).

## Enlaces entre equipos

| Origen | Destino | Tipo | Estado |
|---|---|---|---|
| Router doméstico (LAN) | FGT-LAB-01 wan1 | Enlace WAN | Activo |
| FGT-LAB-01 lan5 | SW-LAB-01 GE0/0/1 | Trunk 802.1Q · VLAN 10–50 · nativa 999 | Activo |
| SW-LAB-01 GE0/0/5 | SW-LAB-02 puerto 1 | Trunk 802.1Q · VLAN 10/20/50 · nativa 999 | Activo |
| SW-LAB-01 GE0/0/2 a GE0/0/4 | SRV-01 a SRV-03 | Por definir en LAB-002 | Reservados, apagados |
| SW-LAB-01 GE0/0/7 | SRV-04 (opcional) | Por definir en LAB-002 | Reservado; hoy acceso de pruebas VLAN 20 |

Cuando se conecte SRV-04, las pruebas en VLAN 20 se hacen en el puerto 3 del switch de acceso, que ya cumple esa función. Si hicieran falta más puertos en el switch principal, quedan los cuatro SFP (GE0/0/9–12), que admiten módulos 1000BASE-T.

El montaje en rack, el cableado y el etiquetado están completados. Su detalle físico (fotos, plan de cables y etiquetas) no se publica (D-024).
