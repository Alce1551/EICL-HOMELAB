# LAB-003 — Servicios esenciales

**Estado:** pendiente · **Inicio:** por definir

Construir los servicios de infraestructura que usarán los demás laboratorios: un host de servicios con contenedores, DNS interno para el dominio `eicl.internal`, hora unificada, inventario de direccionamiento (IPAM), almacenamiento en red (NAS) y el primer respaldo funcional del clúster.

## Componentes

| Componente | Equipo / alcance | Estado | Memoria técnica |
|---|---|---|---|
| A | NAS: dos SSD externos de 2 TB en espejo sobre `pve-lab-03` | ⏳ Pendiente | — |
| B | Host de servicios `svc-lab-01`: VM Debian con Docker | ⏳ Pendiente | — |
| C | DNS interno y filtrado (AdGuard Home) para `eicl.internal` | ⏳ Pendiente | — |
| D | Hora y DHCP: clientes NTP y entrega del DNS interno por VLAN | ⏳ Pendiente | — |
| E | Inventario IPAM con NetBox | ⏳ Pendiente | — |
| F | Respaldos básicos: máquinas virtuales y configuración de los equipos de red | ⏳ Pendiente | — |
| G | Validación y entregables | ⏳ Pendiente | — |

El orden de las letras es el orden de implementación: el NAS va primero porque es el destino de los respaldos, y el DNS se apoya en el host de servicios.

## Qué se va a implementar

**A — NAS.** Los dos SSD externos se conectan al tercer nodo del clúster, que sigue siendo nodo del clúster (no se revierte D-031). Con ellos se crea un pool ZFS en espejo, con unos 1.8 TiB útiles y tolerancia a la falla de un disco, y la caché de ZFS se limita por la RAM de 8 GB del nodo. Un contenedor LXC sin privilegios (`nas-lab-01`, VLAN de servidores) comparte una carpeta por SMB 3, sin acceso de invitado, y el mismo pool queda registrado en Proxmox como almacenamiento de respaldos. Antes de crear el pool, los discos pasan una prueba de estrés por USB; si fallan, se evalúa una VM con OpenMediaVault como alternativa.

**B — Host de servicios.** Una VM Debian 13 con Docker y Docker Compose en la VLAN de servidores, con IP fija. Aloja los servicios en contenedores (DNS y NetBox) y queda en un nodo de 16 GB de RAM. Los archivos de Compose se guardan en el NAS y su versión saneada se publica en el repositorio.

**C — DNS interno.** AdGuard Home resuelve la zona `eicl.internal` (firewall, switches, nodos, VM y servicios), reenvía el resto a resolvedores públicos y filtra dominios de publicidad y rastreo. Cada VLAN que lo use necesita su política en el firewall, limitada al puerto 53. La VLAN de gestión ya alcanza la de servidores (política 3).

**D — Hora y DHCP.** La cadena de hora actual (firewall como servidor NTP interno) se extiende a los servicios nuevos y se comprueba en cada equipo. El DHCP del firewall pasa a entregar el DNS interno en cada VLAN, y los nodos Proxmox lo usan para todo lo que no sea el propio clúster.

**E — Inventario IPAM.** NetBox registra el inventario real del laboratorio: sitio y rack, equipos y sus puertos, VLAN, prefijos, IP asignadas y máquinas virtuales. A partir de este laboratorio, toda IP nueva se asigna primero en NetBox.

**F — Respaldos básicos.** Trabajos programados de `vzdump` para respaldar las VM y los contenedores en el NAS, con retención definida. Los respaldos de configuración del firewall y de los switches, que hoy se hacen a mano, también se guardan en el NAS. La prueba que cierra el componente es restaurar una VM con otro identificador y comprobar que arranca. Una copia fuera del laboratorio (regla 3-2-1) queda para LAB-008.

**G — Validación y entregables.** Pruebas de punta a punta de cada servicio, positivas y negativas: resolución desde cada VLAN, acceso al NAS solo desde orígenes autorizados, falla simulada de un disco, restauración de un respaldo y reinicio de los nodos sin pérdida de servicio. Se actualizan `docs/` (servicios, direccionamiento, decisiones y validaciones).

## Plan de servicios (propuesto)

| Servicio | Host | Plataforma | Nodo | VLAN | IP propuesta |
|---|---|---|---|---|---|
| NAS (ZFS en espejo + SMB) | `nas-lab-01` | Contenedor LXC Debian 13 | `pve-lab-03` | 20 | 10.10.20.20 |
| Host de servicios | `svc-lab-01` | VM Debian 13 + Docker | `pve-lab-02` | 20 | 10.10.20.10 |
| DNS interno y filtrado | AdGuard Home | Contenedor Docker | `svc-lab-01` | 20 | 10.10.20.10 |
| Inventario IPAM | NetBox | Contenedores Docker | `svc-lab-01` | 20 | 10.10.20.10 |

Las IP siguen la convención por /24 (rango de servidores .10–.49) y quedan fuera del DHCP. Los servicios van en la VLAN de servidores porque la de gestión no lleva máquinas virtuales ni contenedores (D-038). Los nombres siguen la convención `TIPO-LAB-NN`.

## Criterio de cierre

- Todos los equipos y servicios del laboratorio se resuelven por nombre en `eicl.internal`, desde cada VLAN autorizada.
- El NAS está en espejo y saludable, y se comprobó la falla y la recuperación de un disco.
- Hay al menos un respaldo programado de VM en el NAS y una restauración comprobada.
- NetBox refleja el inventario y el direccionamiento reales.
- El clúster mantiene el quórum durante todo el laboratorio y después de reiniciar el nodo del NAS.
- Cada acceso nuevo entre VLAN tiene su política específica en el firewall, con registro.

## Dependencias y decisiones por tomar

- **Antes de empezar:** revisión integral de la infraestructura (configuración de puertos y VLAN, y acceso de gestión del switch principal).
- **Por confirmar:** modelo, puente USB y versión de USB de los SSD; puertos USB libres de `pve-lab-03`; RAM disponible de cada nodo.
- **Por decidir:** si `/etc/hosts` de los nodos Proxmox conserva los tres nodos como respaldo del DNS (recomendado, para que el clúster no dependa de una VM); si el DNS va en Docker o en un contenedor LXC propio; si el NAS se comparte con la PC de administración (requiere una política solo para SMB); cómo respaldan en el NAS los nodos que no tienen los discos (NFS desde el host o Proxmox Backup Server en LAB-008).

## Fuera de alcance

Copia de respaldos fuera del laboratorio, VLAN 60 de respaldos y Proxmox Backup Server (LAB-008) · monitoreo de los servicios (LAB-005) · publicación de cualquier servicio hacia internet (LAB-007) · alta disponibilidad de los servicios (LAB-012).

## Incidentes

| ID | Resumen | Estado |
|---|---|---|
| [INC-002](../../incidentes/INC-002-corte-electrico-general.md) | Corte eléctrico general; `pve-lab-03` no arranca solo al volver la energía (falta *AC Recovery* en la BIOS) | 🔄 En curso |

## Carpetas

```
README.md   este documento; las carpetas de cada componente se crean con su memoria técnica
```
