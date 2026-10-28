# INC-001 — Nodo Proxmox sin enlace físico con el switch principal

| Campo | Detalle |
|---|---|
| **Fecha** | 27/10/2026 |
| **Detección** | 27/10/2026 · 23:47 (UTC-6) |
| **Resolución** | 28/10/2026 · 00:04 (UTC-6) |
| **Tiempo de resolución** | 17 min |
| **Laboratorio** | LAB-002 — Proxmox y VMware |
| **Detectado durante** | Pruebas de conectividad entre los nodos Proxmox, antes de formar el clúster |
| **Equipos afectados** | `pve-lab-01` (SRV-01, 10.10.10.11) · SW-LAB-01 puerto `GE0/0/2` |
| **Origen de la prueba** | `pve-lab-03` (SRV-04, 10.10.10.14), cuarto nodo, recién integrado y con conexión correcta |
| **Categoría** | Capa 1 — conexión física |
| **Severidad** | Media: un nodo sin red; todavía sin clúster ni servicios en uso |
| **Estado** | ✅ Resuelto |

## Síntoma

Desde `pve-lab-03`, el `ping` hacia `pve-lab-01` no obtuvo respuesta:

```text
Destination Host Unreachable
```

Este mensaje lo genera el propio equipo de origen cuando no recibe respuesta ARP del destino: el destino no es alcanzable dentro del segmento local. Como ambos nodos están en la VLAN 10, el tráfico no pasa por el firewall, así que la falla apunta a capa 1 o 2 del lado del destino (cable, puerto, interfaz de red o VLAN) y no a ruteo ni a políticas.

## Diagnóstico

1. Estado del puerto del nodo en el switch principal:

   ```text
   display interface brief
   display interface GigabitEthernet0/0/2
   ```

2. Resultado: `GE0/0/2` con **PHY down / Protocol down**. Con la capa física caída no tiene sentido revisar la configuración (VLAN, trunk, IP); se pasa a revisión física.
3. Inspección del cableado:
   - Lado del switch: conector bien insertado.
   - Lado de `pve-lab-01`: **conector RJ45 sin insertar por completo**, sin el seguro enganchado.

## Causa raíz

Cable de red mal insertado en la interfaz de `pve-lab-01`: no había enlace eléctrico con el switch.

## Solución

1. Se insertó el conector en `pve-lab-01` hasta enganchar el seguro.
2. Se esperó cerca de un minuto a que el enlace negociara.
3. Se verificó en el switch con `display interface brief`: `GE0/0/2` con **PHY up / Protocol up**.

## Validación

| Prueba | Resultado |
|---|---|
| `GE0/0/2` en PHY up / Protocol up | ✅ Correcto |
| `ping` desde `pve-lab-03` hacia `pve-lab-01` | ✅ Correcto |
| Estado del clúster con `pvecm status` | No aplica todavía: los nodos aún no forman el clúster. Se comprobará al crearlo (LAB-002, componente E) |

## Lecciones aprendidas y prevención

- Ante `Destination Host Unreachable` entre equipos del mismo segmento, **empezar por la capa 1 del lado del destino**: estado de su puerto en el switch y de su enlace.
- Comprobaciones rápidas en el nodo sospechoso (Proxmox):

  ```bash
  ip -br link                    # estado UP/DOWN de las interfaces
  ethtool <interfaz>             # "Link detected", velocidad y dúplex
  journalctl -k | grep -i link   # eventos de enlace del kernel
  ```

- En el switch principal, el historial de caídas del puerto se revisa con `display logbuffer`.
- Después de manipular el rack, comprobar que cada conector tenga el seguro enganchado con un tirón suave, y revisar `display interface brief` antes de dar el trabajo por terminado.
