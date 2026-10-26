# Arquitectura

**Laboratorio:** LAB-001 · **Versión:** 1.2 · **Fecha:** 25/10/2026

## Objetivo

Construir una red de laboratorio con prácticas de entorno empresarial: segmentación por función, un único punto de control del tráfico entre segmentos, gestión aislada y acceso de emergencia independiente.

## Capas

```mermaid
flowchart TB
    subgraph Externa[Red doméstica - fuera del alcance del laboratorio]
        ISP[Módem ISP] --> ARC[Router doméstico]
    end
    subgraph Perimetro[Perímetro]
        FGT[FGT-LAB-01<br/>firewall + gateway de todas las VLAN<br/>DHCP · NTP · políticas]
    end
    subgraph Distribucion[Switching capa 2]
        SW1[SW-LAB-01 · switch principal<br/>STP raíz · trunks 802.1Q]
        SW2[SW-LAB-02 · switch de acceso]
    end
    subgraph Computo[Cómputo - previsto en LAB-002]
        NOD[SRV-01 y SRV-02 · clúster Proxmox<br/>SRV-03 · VMware ESXi<br/>SRV-04 · por definir]
    end
    ARC --> FGT
    FGT --> SW1 --> SW2
    SW1 -.-> NOD
```

## Topología lógica

Cada VLAN es un segmento independiente con su gateway en el firewall (`.1`). Ningún switch rutea: el tráfico entre segmentos sube por el trunk, pasa por las políticas del firewall y queda registrado (D-002).

```mermaid
flowchart LR
    ARC[Router doméstico<br/>192.168.1.0/24] -->|WAN 192.168.1.2 · NAT| FGT[FGT-LAB-01<br/>gateway .1 de cada VLAN<br/>DHCP · NTP · políticas]
    FGT --- V10[VLAN 10 · MGMT<br/>10.10.10.0/24<br/>equipos de red .1 a .3<br/>hipervisores .11 a .14]
    FGT --- V20[VLAN 20 · SRV<br/>10.10.20.0/24<br/>máquinas virtuales y servicios]
    FGT --- V30[VLAN 30 · MON<br/>10.10.30.0/24<br/>monitoreo y SOC]
    FGT --- V40[VLAN 40 · DMZ<br/>10.10.40.0/24<br/>servicios publicados]
    FGT --- V50[VLAN 50 · LAB<br/>10.10.50.0/24<br/>clientes de prueba y banco de clientes]
    FGT --- OOB[OOB · lan1 a lan4<br/>10.10.254.0/24<br/>sin internet]
```

| Segmento | Gateway | Qué vive ahí | Estado |
|---|---|---|---|
| VLAN 10 · MGMT | 10.10.10.1 | Gestión de firewall, switches e hipervisores | Activa |
| VLAN 20 · SRV | 10.10.20.1 | Máquinas virtuales y servicios internos | Activa (máquinas virtuales desde LAB-002) |
| VLAN 30 · MON | 10.10.30.1 | Monitoreo, logs y SOC | Creada, sin equipos (LAB-005/006) |
| VLAN 40 · DMZ | 10.10.40.1 | Servicios publicados | Creada, sin equipos (LAB-007) |
| VLAN 50 · LAB | 10.10.50.1 | Clientes y pruebas, incluido el banco de clientes del switch no administrable | Activa |
| OOB | 10.10.254.1 | Acceso de emergencia al firewall | Activa, sin internet |

Direccionamiento completo en [`vlan-plan.md`](vlan-plan.md).

## Topología física (enlaces)

Conexiones entre equipos, puerto a puerto. El montaje en rack, el cableado y el etiquetado están completados; su detalle físico no se publica (D-024).

```mermaid
flowchart LR
    ARC[Router doméstico] -->|LAN a wan1| FGT[FGT-LAB-01]
    FGT -->|lan5 a GE0/0/1<br/>trunk VLAN 10-50| SW1[SW-LAB-01]
    SW1 -->|GE0/0/5 a puerto 1<br/>trunk VLAN 10/20/50| SW2[SW-LAB-02]
    SW2 -->|puerto 7 · VLAN 50| BAN[Banco de clientes<br/>TL-SG108 no administrable]
    FGT -.->|lan1 a lan4| OOB[Red OOB de emergencia]
    SW1 -.->|GE0/0/2| N1[SRV-01 · Proxmox]
    SW1 -.->|GE0/0/3| N2[SRV-02 · Proxmox]
    SW1 -.->|GE0/0/4| N3[SRV-03 · ESXi]
    SW1 -.->|GE0/0/7| N4[SRV-04 · por definir]
```

Líneas punteadas: enlaces previstos o de emergencia, sin tráfico de producción hoy. El switch no administrable solo extiende la VLAN 50: no entiende VLAN ni STP, por eso cuelga de un puerto de acceso y nunca se usa para los nodos (D-026). Detalle por puerto en [`port-mapping.md`](port-mapping.md).

## Nodos de cómputo (previstos)

El laboratorio contempla **hasta cuatro nodos** Dell OptiPlex 5070 Micro. Su número real, especificaciones y estado se confirman en LAB-000 antes de asignar roles; la instalación se hace en LAB-002.

| Nodo | Rol previsto | Puerto en SW-LAB-01 | IP de gestión prevista |
|---|---|---|---|
| SRV-01 | Proxmox VE · nodo 1 del clúster | GE0/0/2 | 10.10.10.11 |
| SRV-02 | Proxmox VE · nodo 2 del clúster | GE0/0/3 | 10.10.10.12 |
| SRV-03 | VMware ESXi, sujeto a compatibilidad y licencia | GE0/0/4 | 10.10.10.13 |
| SRV-04 | Por definir | GE0/0/7 | 10.10.10.14 |

- Los nodos se conectan al **switch principal**, no al de acceso: ahí hay STP, ACL de administración y trunks gestionables (D-025).
- **Clúster Proxmox de dos nodos (D-027).** Un clúster de dos nodos no tiene quórum propio: si uno cae, el otro queda con 1 de 2 votos y bloquea los cambios. Hace falta un **tercer voto**, con un QDevice externo al clúster (por ejemplo, en SRV-04 o en una máquina virtual del nodo ESXi) o con SRV-04 como tercer nodo Proxmox. Se decide en LAB-002.
- El tráfico del clúster viaja al inicio por la VLAN 10; en LAB-012 se agrega un segundo enlace del clúster en la VLAN 70.
- La alta disponibilidad de máquinas virtuales requiere almacenamiento compartido o replicación entre los dos nodos; se evalúa con el inventario real de discos.
- El modo exacto de cada puerto (trunk con qué VLAN y cuál nativa) se define en LAB-002 según la plataforma de cada nodo.

## Principios de diseño

1. **Un solo punto de control.** Todo el tráfico entre VLAN pasa por el firewall, donde se filtra y se registra (D-002). Los switches no rutean.
2. **Gestión aislada.** Los equipos de red solo se administran desde la VLAN 10 o desde la PC de administración autorizada; el resto de segmentos no alcanza MGMT.
3. **Defensa en profundidad.** El switch principal tiene su propia ACL de administración, aunque el firewall ya filtre antes (D-008).
4. **Mínimo privilegio.** Cada acceso nuevo se agrega como política específica en lugar de ampliar una existente (D-018).
5. **Acceso de emergencia.** Una red OOB en puertos físicos dedicados del firewall permite recuperar el control si falla la red de producción (D-005).
6. **Nada transporta tráfico por defecto.** VLAN nativa sin uso (999), puertos sin uso apagados y VLAN 1 vacía o deshabilitada.

## Políticas del firewall (resumen)

| # | Nombre lógico | Origen → destino | Efecto |
|---|---|---|---|
| 1 | Bloqueo a redes domésticas | VLAN del laboratorio → 192.168.0.0/24 y 192.168.1.0/24 | Deny, con registro |
| 2 | Salida a internet | VLAN del laboratorio → WAN | Permitido con NAT (servicio pendiente de acotar en LAB-004) |
| 3 | Administración interna | MGMT → equipos y SRV | Permitido |
| 4 | Administración remota | PC de administración → MGMT (HTTPS, SSH, web de Proxmox) | Permitido, sin NAT |
| 5 | Web del switch de acceso | PC de administración → SW-LAB-02 (HTTP) | Permitido, con registro |
| — | Regla implícita | Todo lo demás | Deny |

## Limitaciones conocidas y plan

| Limitación | Se aborda en |
|---|---|
| Sin almacenamiento de logs en el firewall; registros solo en memoria | LAB-006 (syslog externo) |
| El switch de acceso no soporta SNMP, syslog ni STP | LAB-005/006 (monitoreo por ping y contadores; port mirroring para sensor) |
| Política de salida a internet con servicio amplio | LAB-004 |
| Varios niveles de NAT hacia internet | LAB-007 y LAB-010 (publicación y VPN) |
| Número de interfaces de red por nodo por confirmar: con una sola, gestión, máquinas virtuales y clúster comparten enlace | LAB-000 (inventario) y LAB-002/012 |
| Clúster Proxmox de dos nodos sin quórum propio | LAB-002 (QDevice o tercer nodo) |
