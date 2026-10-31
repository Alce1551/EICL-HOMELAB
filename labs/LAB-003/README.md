# LAB-003 — Servicios esenciales

**Estado:** en curso · **Inicio:** 30/10/2026

Construir los servicios de infraestructura que usarán los demás laboratorios: almacenamiento en red (NAS), un host de servicios, DNS interno para el dominio `eicl.internal`, hora unificada, inventario de direccionamiento (IPAM) y el primer respaldo funcional. Antes de empezar se validó toda la infraestructura contra lo documentado.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | Validación integral de switches, firewall y nodos; reasignación de puertos del switch principal | ✅ Completado | Pendiente |
| B | NAS `nas-lab-01`: OpenMediaVault en `esx-lab-01` con dos discos USB de 2 TB | ✅ Completado | Pendiente |
| C | Máquinas virtuales: retiro de las VM de prueba de LAB-002 y VM RHEL 10 en `pve-lab-03` | ⏳ Pendiente | — |
| D | DNS interno y filtrado (AdGuard Home) para `eicl.internal` | ⏳ Pendiente | — |
| E | Hora y DHCP: clientes NTP y entrega del DNS interno por VLAN | ⏳ Pendiente | — |
| F | Inventario IPAM con NetBox | ⏳ Pendiente | — |
| G | Respaldos básicos: máquinas virtuales y configuración de los equipos de red en el NAS | ⏳ Pendiente | — |
| H | Validación y entregables | ⏳ Pendiente | — |

El orden de las letras es el orden de implementación. Este plan sustituye al publicado el 29/10, que preveía el NAS en `pve-lab-03` y un host Debian con Docker: el NAS pasó al ESXi (D-045) y el host de servicios será una VM RHEL 10 (D-044).

## Lo más relevante de cada componente

**A — Validación integral.** Se revisó la configuración real del switch principal, el switch de acceso, el firewall, los tres Proxmox y el ESXi contra lo documentado, y coincide. La revisión descubrió un corte eléctrico que había reiniciado todo el laboratorio y dejado un nodo apagado un día ([INC-002](../../incidentes/INC-002-corte-electrico-general.md)): se reconstruyó con el tiempo de actividad del switch y los contadores de BPDU, porque la hora de los registros no era confiable. También se corrigió el acceso de gestión del switch principal: `GE0/0/9` no tenía módulo SFP ni equipo, así que el acceso pasó a `GE0/0/7`, que da gestión en capa 2 aunque falle el firewall; `GE0/0/8` queda reservado para el monitoreo (D-048).

**B — NAS.** El ESXi se dedica a una VM con OpenMediaVault (`nas-lab-01`, 10.10.20.20) que recibe dos discos USB de 2 TB por *passthrough*. Sin RAID, porque los discos son SMR y van por USB: un disco principal y uno de copia con Rsync diario que no borra en el destino lo borrado en el origen. Comparte por SMB con permisos por carpeta, se administra por HTTPS y desde la PC solo es accesible por una política específica del firewall (D-045, D-047). Arranca solo con el ESXi y se apaga de forma ordenada, una regla que ahora aplica a toda VM de servicio (D-049).

## Plan de servicios

| Servicio | Host | Plataforma | Nodo | VLAN | IP | Estado |
|---|---|---|---|---|---|---|
| NAS (SMB, copia diaria) | `nas-lab-01` | VM OpenMediaVault 8 | `esx-lab-01` | 20 | 10.10.20.20 | ✅ Operativo |
| Host de servicios | Por definir | VM RHEL 10 (CPU `x86-64-v3`) | `pve-lab-03` | 20 | Rango .10–.19 | ⏳ Pendiente |
| DNS interno y filtrado | AdGuard Home | Contenedor en el host de servicios | `pve-lab-03` | 20 | Rango .10–.19 | ⏳ Pendiente |
| Inventario IPAM | NetBox | Contenedores en el host de servicios | `pve-lab-03` | 20 | Rango .10–.19 | ⏳ Pendiente |

Las IP de servicio son fijas, fuera del DHCP; el rango 10.10.20.10–.19 queda reservado para los servicios base (D-045). Los servicios van en la VLAN de servidores porque la de gestión no lleva máquinas virtuales (D-038).

## Criterio de cierre

- Todos los equipos y servicios del laboratorio se resuelven por nombre en `eicl.internal`, desde cada VLAN autorizada.
- El NAS funciona con su copia diaria comprobada, y una restauración desde el disco de copia está probada.
- Hay al menos un respaldo programado de VM en el NAS y una restauración comprobada.
- NetBox refleja el inventario y el direccionamiento reales.
- El clúster mantiene el quórum durante todo el laboratorio.
- Cada acceso nuevo entre VLAN tiene su política específica en el firewall, con registro.

## Decisiones por tomar

- Podman o Docker CE para los contenedores en RHEL.
- IP del DNS interno dentro de 10.10.20.10–.19.
- Si `/etc/hosts` de los nodos Proxmox conserva los tres nodos como respaldo del DNS (recomendado, para que el clúster no dependa de una VM).
- Cómo respaldan los nodos Proxmox en el NAS (carpeta compartida por SMB o NFS).

## Fuera de alcance

Copia de respaldos fuera del laboratorio, VLAN 60 de respaldos y UPS (LAB-008) · monitoreo de los servicios con Zabbix en una Raspberry Pi (LAB-005) · publicación de cualquier servicio hacia internet (LAB-007) · alta disponibilidad de los servicios (LAB-012).

## Incidentes

| ID | Resumen | Estado |
|---|---|---|
| [INC-002](../../incidentes/INC-002-corte-electrico-general.md) | Corte eléctrico general; `pve-lab-03` no arranca solo al volver la energía (falta *AC Recovery* en la BIOS) | 🔄 En curso |

## Carpetas

```
README.md   este documento; la memoria técnica de A y B se agrega cuando se publique
```
