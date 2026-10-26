# Registro de decisiones

Cada decisión de diseño se registra con un identificador permanente. Si una decisión se revierte, se crea una nueva que la reemplaza; nunca se borra.

| ID | Fecha | Decisión | Motivo |
|---|---|---|---|
| D-001 | 23/10/2026 | Rango 10.10.0.0/16, tercer octeto = ID de VLAN | Lectura inmediata de la VLAN a partir de la IP |
| D-002 | 23/10/2026 | Ruteo inter-VLAN en el firewall (*router-on-a-stick*); switch principal en capa 2 | Todo el tráfico entre segmentos pasa por políticas y queda registrado |
| D-003 | 23/10/2026 | WAN del firewall conectada al router doméstico | Aísla el laboratorio de la red de casa sin cambiar el equipo del ISP |
| D-004 | 23/10/2026 | VLAN 30 = MON/SOC, 40 = DMZ, 50 = LAB | Separa monitoreo, servicios publicados y clientes de prueba |
| D-005 | 23/10/2026 | lan1–lan4 del firewall como red OOB de emergencia | Acceso garantizado aunque falle el trunk o la configuración de VLAN |
| D-006 | 24/10/2026 | El Huawei se denomina «switch principal», no «core» | No rutea; se reevalúa si asume ruteo inter-VLAN |
| D-007 | 24/10/2026 | NTP interno: el firewall sirve hora solo en MGMT y el switch es su cliente | Hora coherente en los registros sin exponer NTP a otras VLAN |
| D-008 | 24/10/2026 | La administración del switch se limita con una ACL que replica los trusted hosts del firewall | Defensa en profundidad: el switch no depende solo del firewall |
| D-009 | 24/10/2026 | PoE apagado en todos los puertos del switch | Sin dispositivos PoE previstos; evita riesgos con cable no verificado |
| D-010 | 24/10/2026 | SFTP habilitado en el switch para respaldos, limitado por la ACL a nivel del servidor SSH | Respaldos cifrados sin abrir servicios adicionales |
| D-011 | 24/10/2026 | Evidencias opcionales del componente B cerradas como no necesarias | No aportaban información nueva a la memoria |
| D-012 | 24/10/2026 | LAB-000 en pausa; se actualiza al cerrar LAB-001 | Evita reescribir el inventario varias veces |
| D-013 | 24/10/2026 | Omada ES208G en modo standalone, sin controlador ni gestión en la nube | Sin dependencias externas para la gestión |
| D-014 | 24/10/2026 | Plan de puertos del Omada; VLAN 30 y 40 no se extienden a él por ahora | Solo se transportan las VLAN con equipos conectados (mínima exposición) |
| D-015 | 24/10/2026 | Loop Prevention habilitado en el Omada | Es su única protección ante bucles, porque no soporta STP |
| D-016 | 24/10/2026 | Nombres cortos de VLAN en el Omada | Límite de caracteres del campo; el ID es lo que une las VLAN |
| D-017 | 24/10/2026 | La VLAN 1 del Omada conserva solo un puerto deshabilitado | El equipo no permite dejarla vacía |
| D-018 | 24/10/2026 | Política dedicada solo para HTTP de la PC de administración al Omada | Mínimo privilegio, en lugar de ampliar la política general de administración. Riesgo aceptado: el Omada solo ofrece HTTP sin cifrar |
| D-024 | 25/10/2026 | El montaje en rack, el cableado y el etiquetado se cierran sin publicar fotos, plan de cables ni etiquetas | Seguridad física: el detalle del montaje revela equipos y ubicación sin aportar al diseño. Las conexiones se documentan puerto a puerto en `port-mapping.md` |
| D-025 | 25/10/2026 | Capacidad para hasta cuatro nodos en el switch principal: SRV-01 a SRV-03 en GE0/0/2–4 y SRV-04, si se incorpora, en GE0/0/7; gestión prevista en 10.10.10.11–.14 | Los hipervisores necesitan STP, ACL y trunks gestionables, que solo ofrece el switch principal. Las pruebas en VLAN 20 pasan al puerto 3 del switch de acceso, que ya cumple esa función, y no hacen falta módulos SFP |
| D-026 | 25/10/2026 | El switch no administrable TL-SG108 se conecta al puerto 7 del switch de acceso como banco de clientes en VLAN 50 | No entiende VLAN ni STP: solo puede extender un segmento desde un puerto de acceso. Se usa para clientes de prueba y nunca para los nodos |
| D-027 | 25/10/2026 | Roles de los nodos: SRV-01 y SRV-02 con Proxmox VE en clúster, SRV-03 con VMware ESXi y SRV-04 por definir | Un clúster de dos nodos permite practicar migración y alta disponibilidad. Requiere un tercer voto (QDevice externo o tercer nodo), que se define en LAB-002 |
| D-028 | 25/10/2026 | Puertos de los hipervisores en trunk: VLAN 10 sin etiqueta (PVID 10) para la gestión y VLAN 20–50 etiquetadas para las máquinas virtuales; sin VLAN 1 y como puerto *edge* | El hipervisor tiene gestión desde la instalación sin configurar VLAN, y cada máquina virtual sale por su VLAN hacia el firewall. Excepción consciente a la VLAN nativa sin uso, que aplica a enlaces entre switches; riesgo aceptado: un equipo conectado ahí cae en la VLAN de gestión (puertos dentro del rack) |
| D-029 | 25/10/2026 | Hostnames de los nodos: `pve-lab-01`, `pve-lab-02` y `esx-lab-01`, con dominio `eicl.internal` | Misma convención `TIPO-LAB-NN` que el resto del laboratorio; cambiar el nombre de un nodo de clúster después es costoso |
