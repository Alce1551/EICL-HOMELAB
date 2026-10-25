# Validaciones de LAB-001

Cada prueba incluye casos positivos (lo permitido funciona) y negativos (lo prohibido se bloquea). Las evidencias completas están en las memorias técnicas de cada componente.

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

## Lección aprendida (componente C)

Al mover la gestión del Omada a la VLAN 10, el switch quedó inaccesible por web aunque **seguía respondiendo al ping**: el puerto usado para el acceso no había quedado en la VLAN nueva. Se recuperó con un reinicio, que restauró la última configuración guardada.

Conclusión: un ping exitoso no garantiza acceso de administración. Desde entonces la verificación se hace con `curl` (`curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 http://IP`) y el cambio de VLAN de gestión se hace con un puerto puente temporal ya ubicado en la VLAN nueva.
