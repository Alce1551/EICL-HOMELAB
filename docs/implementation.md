# Implementación

**Laboratorio:** LAB-001 · **Versión:** 1.3 · **Fecha:** 28/10/2026

Orden y método con que se construyó la red base del laboratorio, del firewall al switch de acceso. Este documento resume el **cómo** y el **por qué del orden**; los comandos, capturas y resultados detallados están en las memorias técnicas de cada componente.

## Orden de implementación

| Fase | Componente | Resultado | Depende de |
|---|---|---|---|
| 1 | A — Firewall (FGT-LAB-01) | Gateway de todas las VLAN, DHCP, NTP, políticas, red OOB de emergencia | — |
| 2 | B — Switch principal (SW-LAB-01) | Trunk hacia el firewall, VLAN, gestión por SSH, STP, puertos de acceso | Fase 1: el trunk necesita las subinterfaces VLAN del firewall |
| 3 | C — Switch de acceso (SW-LAB-02) | VLAN 802.1Q, gestión en VLAN 10, uplink al switch principal | Fase 2: el uplink sale de un puerto del switch principal |
| 4 | D — Montaje físico | Equipos de red montados en rack, cableados y etiquetados | Fases 1–3 validadas |
| 5 | E — Topología | Mapa lógico y de enlaces final | Fases 1–4 |
| 6 | F — Validación | Pruebas V1–V8 de punta a punta | Se ejecuta al final de cada fase y completa al cierre |
| 7 | G — Entregables | Memorias técnicas y documentos de `docs/` | Todas |

El orden sigue el camino del tráfico: primero el equipo que rutea y filtra, después cada salto de capa 2 hacia los usuarios. Así cada equipo nuevo se conecta a algo que ya funciona y se puede probar de inmediato.

## Principios de ejecución

1. **Nunca quedarse sin acceso.** La red OOB de emergencia del firewall se configura y se prueba **antes** de tocar el puerto que lleva las VLAN. Al mover la gestión de un switch a otra VLAN, primero se prepara un puerto puente en la VLAN nueva.
2. **Levantamiento antes de configurar.** Cada equipo se inspecciona en su estado de llegada (versión de software, configuración previa, hardware) antes de cambiar nada.
3. **Un cambio, una prueba.** Cada paso tiene su verificación y su evidencia; no se avanza con un paso sin comprobar.
4. **Pruebas positivas y negativas.** Se comprueba que lo permitido funciona y que lo prohibido se bloquea.
5. **Guardar y respaldar.** La configuración se guarda en el equipo al terminar cada bloque y se respalda fuera de él al cerrar cada componente. Los respaldos viven en almacenamiento privado, nunca en este repositorio.
6. **Mínimo privilegio en cada acceso nuevo.** Si un equipo nuevo necesita administración remota, se crea una política específica en lugar de ampliar una existente.

## Fase 1 — Firewall (FGT-LAB-01)

| Paso | Qué se hace | Cómo se comprueba |
|---|---|---|
| 0 | Recuperación de acceso con el procedimiento del fabricante y reset de fábrica (la configuración anterior era ajena al proyecto) | Equipo en valores de fábrica |
| 1 | Hostname y zona horaria | Estado del sistema |
| 2–3 | Identificación de puertos y separación de `lan5` del switch interno del equipo | `lan5` como interfaz independiente |
| 4 | Red OOB de emergencia en `lan1`–`lan4` (10.10.254.1/24, DHCP, sin internet) | Acceso de prueba desde un equipo conectado a la OOB |
| 5 | WAN 192.168.1.2 hacia el router doméstico, ruta por defecto, DNS y NTP | Salida a internet y hora sincronizada |
| 6 | Subinterfaces VLAN 10–50 sobre `lan5` y DHCP en las VLAN 10, 20 y 50 | Interfaces y rangos DHCP |
| 7 | Objetos y políticas 1–4 (bloqueo a redes domésticas, salida a internet, administración interna y remota) | Configuración de políticas |
| 8 | Trusted hosts y administración desde la PC de administración (ruta estática hacia 10.10.0.0/16 por la WAN del firewall) | Acceso de administración desde la PC |
| 9 | Respaldo de la configuración | Archivo en almacenamiento privado |

Ajustes posteriores, hechos al integrar los switches: servidor NTP solo en VLAN 10, filtro de registros en memoria a nivel *information* (el valor de fábrica descartaba el tráfico permitido) y política 5 para la web del switch de acceso.

Memoria técnica: [lab-001-fortigate-v1.2](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-001-fortigate-v1.2).

## Fase 2 — Switch principal (SW-LAB-01)

| Paso | Qué se hace | Cómo se comprueba |
|---|---|---|
| B0–B1 | Inspección física, acceso por consola y levantamiento (software, hardware, configuración previa) | El equipo llega sin configuración guardada; no requiere reset |
| B2 | Hostname y zona horaria | Configuración vigente |
| B3 | Usuario local con AAA, llave RSA 3072, SSH habilitado, Telnet deshabilitado, ACL de administración en las líneas virtuales y en la consola | Login por consola con AAA |
| B4 | VLAN 10, 20, 30, 40, 50 y 999, con los mismos nombres que en el firewall | Lista de VLAN |
| B5 | Trunk `GE0/0/1` hacia `lan5`: VLAN 10–50 etiquetadas, nativa 999, sin VLAN 1 | Puerto a 1000/full y en *forwarding* |
| B6 | Interfaz de gestión 10.10.10.2 en VLAN 10, ruta por defecto, SSH solo en esa interfaz, NTP como cliente del firewall | SSH desde la PC de administración; hora sincronizada |
| B7 | Plan de puertos, puertos sin uso en VLAN 999 y apagados, STP con raíz primaria, protección BPDU en puertos de acceso, PoE apagado | Estado de STP y de puertos |
| B8 | Pruebas con laptop en las cinco VLAN | V1, V2 y V3 |
| B9 | SFTP limitado por la ACL y respaldo de la configuración | Archivo en almacenamiento privado (V8) |

Memoria técnica: [lab-001-huawei-v1.1](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-001-huawei-v1.1).

## Fase 3 — Switch de acceso (SW-LAB-02)

| Paso | Qué se hace | Cómo se comprueba |
|---|---|---|
| C0–C1 | Inspección y levantamiento **aislado**, con una laptop conectada directo al switch en su IP de respaldo | Acceso web; el equipo llega en estado de fábrica |
| C2 | Cuenta de administración, nombre del equipo y Loop Prevention (venía deshabilitado) | Configuración guardada |
| C3 | En el switch principal, `GE0/0/5` pasa a trunk hacia el puerto 1 del Omada (VLAN 10/20/50, nativa 999, `stp root-protection`) | Puerto en *forwarding*; MAC del Omada aprendida en VLAN 10 |
| C4 | 802.1Q en el Omada: VLAN 10, 20, 50 y 999, PVID por puerto, Ingress Checking | Tablas de VLAN y PVID |
| C5 | IP fija 10.10.10.3 y gestión en VLAN 10, con un puerto puente temporal ya ubicado en esa VLAN | `curl` a la web desde VLAN 10 → HTTP 200 |
| C6 | Puertos sin uso deshabilitados; reinicio de prueba | La configuración se conserva |
| C7 | Pruebas con laptop en los puertos 2–5 y política 5 en el firewall para la web desde la PC de administración | V1–V4 repetidas a través del switch de acceso |
| C8 | Respaldo del Omada y nuevos respaldos del firewall y del switch principal | Archivos en almacenamiento privado |
| C9 | Switch no administrable TL-SG108 en el puerto 7 como banco de clientes en VLAN 50 (D-026): puerto 7 *Untagged* en VLAN 50, PVID 50, fuera de la VLAN 999 y habilitado | Tablas de VLAN, PVID y estado de puertos; pruebas con laptop desde el TL-SG108; nuevo respaldo del Omada |

Durante C5 el primer intento dejó la web inaccesible aunque el equipo respondía al ping; se recuperó con un reinicio. El caso y su lección están en [`validacion.md`](validacion.md).

Memoria técnica: [lab-001-omada-v1.1](https://github.com/Alce1551/EICL-HOMELAB/releases/tag/lab-001-omada-v1.1).

## Fase 4 — Montaje físico

El montaje en rack, el cableado y el etiquetado de los equipos de red están completados. Su detalle (fotos, plan de cables y etiquetas) no se publica por seguridad física (D-024). Las conexiones se documentan puerto a puerto en [`port-mapping.md`](port-mapping.md).

## Fases 5 a 7 — Topología, validación y entregables

- Topología lógica y de enlaces: [`architecture.md`](architecture.md).
- Puertos de cada equipo: [`port-mapping.md`](port-mapping.md).
- Direccionamiento: [`vlan-plan.md`](vlan-plan.md).
- Pruebas V1–V8: [`validacion.md`](validacion.md).
- Decisiones: [`decisiones.md`](decisiones.md).

## Respaldos

| Equipo | Método | Cuándo |
|---|---|---|
| FGT-LAB-01 | Respaldo de configuración desde la interfaz de administración | Al cerrar cada componente que lo modifica |
| SW-LAB-01 | Descarga por SFTP del archivo de configuración y copia en texto | Al cerrar cada componente que lo modifica |
| SW-LAB-02 | *Configuration Backup* desde la web (el equipo no ofrece otro método) | Al cerrar cada componente que lo modifica |

Nombre de los archivos: `HOSTNAME_AAAA-MM-DD_descripcion.ext`. Los respaldos contienen credenciales cifradas y la configuración completa: se guardan solo en almacenamiento privado y el repositorio bloquea esos tipos de archivo. La automatización se aborda en LAB-008.

## Procedimiento para incorporar un equipo nuevo

Se aplicará a los nodos de LAB-002 y a cualquier equipo posterior.

1. **Levantamiento aislado:** conectar el equipo fuera de la red de producción, registrar modelo, software y configuración de llegada.
2. **Identidad:** hostname según la convención `TIPO-LAB-NN` e IP de gestión en VLAN 10 según la convención por /24 (.2–.9 equipos de red, .10–.49 servidores e hipervisores).
3. **Puerto:** el puerto reservado del switch principal pasa de VLAN 999 apagado a la configuración definida; nunca se usa un puerto sin uso sin documentarlo en `port-mapping.md`.
4. **Acceso:** si necesita administración desde la PC, se crea una política específica en el firewall (mínimo privilegio) y, si aplica, se amplía la ACL del switch.
5. **Validación:** pruebas positivas y negativas desde la VLAN del equipo y hacia ella.
6. **Respaldo:** de cada equipo cuya configuración cambió.
7. **Registro:** decisión nueva en `decisiones.md`, pruebas en `validacion.md` y memoria técnica del componente.

## Estado final de LAB-001

| Equipo | Función | Gestión | Respaldo |
|---|---|---|---|
| FGT-LAB-01 · FortiGate 50E | Firewall y gateway de todas las VLAN | HTTPS y SSH limitados por trusted hosts; OOB de emergencia | Sí |
| SW-LAB-01 · Huawei S5735 | Switch principal, capa 2, raíz STP | SSH en 10.10.10.2, limitado por ACL | Sí |
| SW-LAB-02 · Omada ES208G | Switch de acceso | Web HTTP en 10.10.10.3, solo desde VLAN 10 y la PC de administración | Sí |

## Pendientes que pasan a otros laboratorios

| Pendiente | Laboratorio |
|---|---|
| Clúster Proxmox de tres nodos (`pve-lab-01` a `pve-lab-03`), redes virtuales por VLAN y una máquina virtual por plataforma | LAB-002 |
| Acotar el servicio de la política de salida a internet; caducidad de contraseñas del switch | LAB-004 |
| Monitoreo del switch principal por SNMP y prueba negativa propia de su ACL | LAB-005 |
| Syslog externo y registro de la regla implícita del firewall | LAB-006 |
| Automatización de respaldos | LAB-008 |

## Protección de la información

| Dato | Tratamiento | Motivo de protección |
|---|---|---|
| IP de la PC de administración y orígenes autorizados | No aparecen; se nombra como «PC de administración» | Indican desde dónde atacar la administración |
| Credenciales y usuarios de administración | No aparecen | Acceso directo a los equipos |
| Versiones de software de los equipos | Omitidas (regla D-022) | Orientan la búsqueda de vulnerabilidades |
| Montaje físico: fotos, plan de cables y etiquetas | No se publica (D-024) | Seguridad física del laboratorio |
| Nombres de los archivos de respaldo | Solo el formato genérico | Los respaldos nunca se publican |
| Plan de direccionamiento, hostnames y modelos del laboratorio | Visibles | Son el objeto del laboratorio; rangos privados |

Revisados los tres canales: texto, comandos (no se incluyen salidas de consola) e imágenes (el documento no contiene imágenes).
