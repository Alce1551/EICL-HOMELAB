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

Completado (25/10/2026 – 28/10/2026). Pruebas de la red de los nodos, de la instalación de los hipervisores, del clúster Proxmox de tres nodos y de una máquina virtual por plataforma.

| ID | Prueba | Resultado | Cómo se comprobó |
|---|---|---|---|
| V1 | Los puertos de los nodos quedan en trunk con la VLAN 10 sin etiqueta y las VLAN 20–50 etiquetadas | ✅ Aprobada | `display port vlan` en GE0/0/2–4: trunk, PVID 10, VLAN 10 20 30 40 50. Los enlaces hacia el firewall y el switch de acceso siguen arriba |
| V2 | La gestión web de los tres hipervisores es accesible desde la PC de administración | ✅ Aprobada | Proxmox en `https://10.10.10.11:8006` y `https://10.10.10.12:8006`; ESXi en `https://10.10.10.13` |
| V3 | Los hipervisores salen a internet para actualizarse | ✅ Aprobada | Actualización completa de los dos Proxmox con el repositorio *No-Subscription* |
| V4 | Los tres hipervisores sincronizan la hora con el firewall | ✅ Aprobada | `chronyc sources` con `^* 10.10.10.1` en los Proxmox; NTP del ESXi con hora UTC correcta |
| V5 | Los nodos Proxmox se resuelven y alcanzan por nombre dentro de la VLAN 10 | ✅ Aprobada | `getent hosts` en ambos nodos y `ping` por FQDN con TTL 64 (sin pasar por el firewall) |
| V6 | ESXi reconoce la interfaz de red del equipo | ✅ Aprobada | Un adaptador de red activo con la IP de gestión |
| V7 | Las demás VLAN no alcanzan la gestión de los nodos | ✅ Aprobada | Desde las VM de la VLAN 20 en ambas plataformas: sin respuesta de `pve-lab-01` (10.10.10.11), del switch principal (10.10.10.2) ni del router doméstico (100 % de pérdida). Desde la VLAN 50 no se repitió con un hipervisor como destino; la política es la misma que bloquea LAB → MGMT en LAB-001 |
| V8 | El clúster Proxmox mantiene quórum con un nodo apagado | ✅ Aprobada | `pvecm status` con `pve-lab-03` apagado: 2 nodos, 2 de 3 votos, quórum 2, *Quorate: Yes*. Al encenderlo, el nodo se reincorporó solo en unos dos minutos y volvieron los 3 votos |
| V9 | El puerto del cuarto nodo queda en trunk como los demás | ✅ Aprobada | `display this` en `GE0/0/6`: trunk, PVID 10, VLAN 10 20 30 40 50, sin VLAN 1, edge; configuración guardada |
| V10 | `pve-lab-03` alcanza a los demás nodos por la VLAN 10 | ✅ Aprobada | `ping` a `pve-lab-01` correcto, después de resolver [INC-001](../incidentes/INC-001-nodo-sin-enlace-fisico.md) |
| V11 | El acceso de gestión reubicado en `GE0/0/9` funciona en la VLAN 10 | ⏳ Pendiente (corregida el 28/10) | La configuración es correcta: `display vlan` muestra `GE0/0/9` sin etiqueta en la VLAN 10 y `GE0/0/6` sin etiqueta en la 10 y etiquetado en la 20–50. Pero `GE0/0/9` es un puerto SFP **sin módulo instalado** (`display interface`: *transceiver is absent*, sin enlace desde el arranque), así que el «up/up» registrado antes era incorrecto. Mientras se decide el acceso de gestión del switch principal, la VLAN 10 sigue disponible desde la PC de administración (a través del firewall) y desde el puerto 2 del switch de acceso |
| V12 | Los tres Proxmox tienen la misma versión, la hora sincronizada y resolución por nombre correcta antes de formar el clúster | ✅ Aprobada | `pveversion` y `uname -r` iguales en los tres nodos; `chronyc sources` con `^* 10.10.10.1`; `getent hosts` devuelve .11, .12 y .14 para los seis nombres (corto y FQDN) y `ping` por nombre 3/3 |
| V13 | Los tres nodos forman un clúster con quórum propio | ✅ Aprobada | `pvecm status` y `pvecm nodes` en `pve-lab-03`: clúster `pve-lab-clr`, transporte `knet`, autenticación segura, 3 nodos, 3 votos, quórum 2, *Quorate* |
| V14 | Los bridges con VLAN no afectan la gestión ni el clúster | ✅ Aprobada | En los tres nodos: `bridge vlan show` con la VLAN 1 sin etiqueta (la VLAN 10 del switch) y las VLAN 20–50 en `nic0`; después del cambio, ping al gateway correcto y clúster con 3 votos |
| V15 | Una VM en Proxmox obtiene red en su VLAN y sale a internet | ✅ Aprobada | `deb-lab-01` (etiqueta 20 en `vmbr0`): IP 10.10.20.101/24 por DHCP, ruta por 10.10.20.1, DNS 1.1.1.1 y 8.8.8.8 por DHCP, ping 3/3 al gateway, a 1.1.1.1 y a `debian.org` |
| V16 | Una VM en ESXi obtiene red en su VLAN y sale a internet | ✅ Aprobada | `deb-lab-02` (*port group* `VLAN20-SRV`): IP 10.10.20.103/24 por DHCP, ruta por 10.10.20.1, DNS 1.1.1.1 y 8.8.8.8 por DHCP, ping 3/3 al gateway, a 1.1.1.1 y a `debian.org` |

### Lección aprendida (instalación)

El reloj del ESXi quedó adelantado seis horas: durante la instalación tomó la hora local como si fuera UTC. ESXi siempre trabaja en UTC, así que el error no se ve a simple vista. Se corrigió apuntando su cliente NTP al firewall; las marcas anteriores (fecha de instalación e historial) quedaron corridas. Desde entonces, la hora se verifica en cada equipo nuevo antes de darlo por instalado.

### Lección aprendida (clúster)

Un ping por nombre que responde no prueba que se llegó al equipo correcto. En uno de los nodos, `pve-lab-03` quedó escrito en `/etc/hosts` con la IP del ESXi, y el ping respondía igual, desde el equipo equivocado. Si el clúster se hubiera creado así, habría apuntado al ESXi. Desde entonces la resolución se verifica con `getent hosts`, revisando la IP de cada nombre, y no solo con que el ping conteste.

### Lección aprendida (red virtual)

Si el switch entrega la VLAN de gestión sin etiqueta, esa VLAN no se puede usar etiquetada dentro de las VM: en Proxmox una VM con etiqueta 10 no recibiría las respuestas, y en ESXi el *port group* `VM Network` (VLAN 0) la deja en la VLAN 10 sin que se note. Por eso los bridges solo permiten las VLAN 20 a 50 y cada VLAN de ESXi tiene su propio *port group* (D-038, D-041).
