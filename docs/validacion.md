# Validaciones

Cada prueba incluye casos positivos (lo permitido funciona) y negativos (lo prohibido se bloquea). Las evidencias completas están en las memorias técnicas de cada componente.

## LAB-001

| ID | Prueba | Resultado | Cómo se comprobó |
|---|---|---|---|
| V1 | Un equipo en cada VLAN con DHCP recibe IP, alcanza su gateway y sale a internet | ✅ Aprobada | Laptop en VLAN 10, 20 y 50: IP .100, gateway, DNS y dominio `eicl.internal`, navegación y resolución. VLAN 30 y 40 con IP fija. Repetida a través del switch de acceso (puertos 2–5) |
| V2 | Ninguna VLAN alcanza las redes domésticas (192.168.0.0/24 y 192.168.1.0/24) | ✅ Aprobada | Sin respuesta desde las cinco VLAN; los bloqueos quedan registrados en el firewall. Repetida a través del switch de acceso |
| V3 | SRV no alcanza MGMT; MGMT sí alcanza SRV | ✅ Aprobada | VLAN 20 → 10.10.10.2 bloqueado; switch → 10.10.20.100 con éxito (TTL 63, confirma el paso por el firewall). MON, DMZ y LAB tampoco alcanzan MGMT. En el switch de acceso: `curl` desde SRV y LAB → sin respuesta; desde MGMT → HTTP 200 |
| V4 | La PC de administración alcanza MGMT a través del firewall | ✅ Aprobada | SSH al switch principal y web del switch de acceso desde `<IP-PC-ADMIN>`. El ping falla por diseño: la política de administración no incluye ICMP |
| V5 | Los registros y contadores de cada política coinciden con las pruebas | ✅ Aprobada | Contadores por política y registros de la política de bloqueo |
| V6 | La política de bloqueo hacia redes domésticas tiene acción *deny* | ✅ Aprobada | `show full-configuration firewall policy 1` |
| V7 | Trunks con VLAN etiquetadas y VLAN 999 nativa | ✅ Aprobada | Firewall ↔ switch principal (VLAN 10–50) y switch principal ↔ switch de acceso (VLAN 10/20/50) |
| V8 | Respaldo de la configuración del switch principal | ✅ Aprobada | Respaldo por SFTP (archivo en almacenamiento privado) |

### Lección aprendida (componente C)

Al mover la gestión del Omada a la VLAN 10, el switch quedó inaccesible por web aunque **seguía respondiendo al ping**: el puerto usado para el acceso no había quedado en la VLAN nueva. Se recuperó con un reinicio, que restauró la última configuración guardada.

Conclusión: un ping exitoso no garantiza acceso de administración. Desde entonces la verificación se hace con `curl` (`curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 http://IP`) y el cambio de VLAN de gestión se hace con un puerto puente temporal ya ubicado en la VLAN nueva.

## LAB-002

En curso. Pruebas de la red de los nodos y de la instalación de los hipervisores; el clúster y las máquinas virtuales se agregan al avanzar.

| ID | Prueba | Resultado | Cómo se comprobó |
|---|---|---|---|
| V1 | Los puertos de los nodos quedan en trunk con la VLAN 10 sin etiqueta y las VLAN 20–50 etiquetadas | ✅ Aprobada | `display port vlan` en GE0/0/2–4: trunk, PVID 10, VLAN 10 20 30 40 50. Los enlaces hacia el firewall y el switch de acceso siguen arriba |
| V2 | La gestión web de los tres hipervisores es accesible desde la PC de administración | ✅ Aprobada | Proxmox en `https://10.10.10.11:8006` y `https://10.10.10.12:8006`; ESXi en `https://10.10.10.13` |
| V3 | Los hipervisores salen a internet para actualizarse | ✅ Aprobada | Actualización completa de los dos Proxmox con el repositorio *No-Subscription* |
| V4 | Los tres hipervisores sincronizan la hora con el firewall | ✅ Aprobada | `chronyc sources` con `^* 10.10.10.1` en los Proxmox; NTP del ESXi con hora UTC correcta |
| V5 | Los nodos Proxmox se resuelven y alcanzan por nombre dentro de la VLAN 10 | ✅ Aprobada | `getent hosts` en ambos nodos y `ping` por FQDN con TTL 64 (sin pasar por el firewall) |
| V6 | ESXi reconoce la interfaz de red del equipo | ✅ Aprobada | Un adaptador de red activo con la IP de gestión |
| V7 | Las demás VLAN no alcanzan la gestión de los nodos | ⏳ Pendiente | — |
| V8 | El clúster Proxmox mantiene quórum con un nodo apagado | ⏳ Pendiente | — |
| V9 | El puerto del cuarto nodo queda en trunk como los demás | ✅ Aprobada | `display this` en `GE0/0/6`: trunk, PVID 10, VLAN 10 20 30 40 50, sin VLAN 1, edge; configuración guardada |
| V10 | `pve-lab-03` alcanza a los demás nodos por la VLAN 10 | ✅ Aprobada | `ping` a `pve-lab-01` correcto, después de resolver [INC-001](../incidentes/INC-001-nodo-sin-enlace-fisico.md) |
| V11 | El acceso de gestión reubicado en `GE0/0/9` funciona en la VLAN 10 | ✅ Aprobada | `display vlan`: `GE0/0/9` sin etiqueta en la VLAN 10 y `GE0/0/6` sin etiqueta en la 10 y etiquetado en la 20–50. `display interface brief`: `GE0/0/9` up/up con el equipo de administración conectado. Configuración guardada |

### Lección aprendida (instalación)

El reloj del ESXi quedó adelantado seis horas: durante la instalación tomó la hora local como si fuera UTC. ESXi siempre trabaja en UTC, así que el error no se ve a simple vista. Se corrigió apuntando su cliente NTP al firewall; las marcas anteriores (fecha de instalación e historial) quedaron corridas. Desde entonces, la hora se verifica en cada equipo nuevo antes de darlo por instalado.
