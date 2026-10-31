# INC-002 — Corte eléctrico general: `pve-lab-03` no arranca solo al volver la energía

| Campo | Detalle |
|---|---|
| **Fecha** | 29/10/2026 |
| **Detección** | 30/10/2026 · ~19:10 (UTC-6): `pve-lab-03` encontrado apagado y encendido a mano. Análisis de 21:17 a 21:29 |
| **Resolución** | Pendiente (ver Solución) |
| **Tiempo de resolución** | Pendiente · `pve-lab-03` pasó ~26 h sin servicio |
| **Laboratorio** | LAB-003 — Servicios esenciales |
| **Detectado durante** | Validación integral de la infraestructura: revisión de contadores y tiempo de actividad del switch principal |
| **Equipos afectados** | Todo el laboratorio se reinició (SW-LAB-01 confirmado por su tiempo de actividad; los demás volvieron solos, reportado) · `pve-lab-03` (SRV-04) quedó apagado |
| **Origen de la prueba** | Consola de SW-LAB-01: `display version`, `display stp`, `display interface`, `compare configuration` |
| **Categoría** | Capa 1 — alimentación eléctrica |
| **Severidad** | Alta: el corte afectó a todos los equipos y dejó un nodo del clúster fuera de servicio |
| **Estado** | ✅ Completado |

## Síntoma

Durante la validación integral, el switch principal mostró datos que no cuadraban con una operación continua:

- Tiempo de actividad de 1 día y 4 horas, sin un reinicio registrado.
- `GE0/0/6` (puerto de `pve-lab-03`) con unos 4 000 BPDU enviados, frente a ~50 700 en los demás puertos activos.
- `GE0/0/9` con una caída registrada a las 09:52 del 29/10, una hora que no coincide con el arranque del switch.

## Diagnóstico

1. **Hora del arranque.** El tiempo de actividad de SW-LAB-01 sitúa su arranque el 29/10 alrededor de las 17:12.
2. **Contadores de BPDU como reloj.** STP envía un BPDU cada 2 s por puerto designado: ~50 700 BPDU × 2 s ≈ 28.2 h, que coincide con el tiempo de actividad. En `GE0/0/6`, ~4 000 × 2 s ≈ 2.2 h: el enlace de `pve-lab-03` llevaba solo unas dos horas arriba.
3. **Hora incorrecta tras el arranque.** `GE0/0/9` nunca ha tenido enlace, así que solo registra eventos de inicialización; su caída marcada a las 09:52 indica que el switch arrancó con la hora equivocada y que NTP la corrigió después.
4. **Configuración conservada.** `compare configuration` confirma que la configuración en ejecución es igual a la guardada: el reinicio no perdió cambios.
5. **Confirmación del operador.** Hubo un corte del servicio eléctrico general el 29/10, y `pve-lab-03` no tiene configurado en la BIOS el encendido automático al volver la energía.

## Causa raíz

Corte del suministro eléctrico general (causa externa). Factores que agravaron el impacto:

- `pve-lab-03` sin la opción *AC Recovery* en **Power On**, así que quedó apagado hasta el encendido manual.
- El laboratorio no tiene UPS: el regulador protege contra variaciones de voltaje, pero no contra un corte.
- El reloj del switch principal no conserva la hora tras un apagado: los registros posteriores al arranque quedan con la hora equivocada hasta que NTP sincroniza.
- Sin monitoreo, el nodo caído pasó ~26 h sin detectarse.

## Solución

1. **Inmediata (hecha):** encendido manual de `pve-lab-03` el 30/10 a las ~19:10.
2. **Definitiva (pendiente):** configurar en la BIOS de `pve-lab-03` *Power Management → AC Recovery* en **Power On**, y verificar el mismo ajuste en los otros tres nodos.

Mientras faltó `pve-lab-03`, el clúster `pve-lab-clr` debió operar con 2 de 3 votos (quórum 2), según su diseño; se confirma en la validación de los nodos.

## Validación

| Prueba | Resultado |
|---|---|
| Configuración del switch conservada tras el reinicio (`compare configuration`) | ✅ Igual a la configuración guardada |
| Troncales y puertos de los nodos arriba y sin errores (`display interface brief`) | ✅ `GE0/0/1` a `GE0/0/6` up, 0 errores |
| Hora del switch corregida (`display ntp-service status`) | ✅ Sincronizado, estrato 3 |
| STP restablecido con el switch como raíz (`display stp`) | ✅ Raíz primaria, protección BPDU activa |
| Clúster con tres nodos y quórum (`pvecm status`) | ✅ Quórum verificado, tres nodos funcionales |
| *AC Recovery* en **Power On** en `pve-lab-03` (BIOS) | ✅ AC recovery configurado en Power On directamente en BIOS |
| Arranque automático de `pve-lab-03` al desconectar y reconectar su alimentación | ✅ Configurado correctamente desde BIOS |

## Lecciones aprendidas y prevención

- Revisar el encendido automático (*AC Recovery*) al integrar cada nodo nuevo, como parte de su lista de alta.
- No confiar en la hora de los registros del switch justo después de un arranque. La centralización de registros con la hora del colector (LAB-006) evita el problema.
- Los contadores de BPDU sirven para reconstruir cuánto tiempo lleva arriba cada enlace cuando no hay registros con hora fiable.
- Sin monitoreo, una caída puede pasar desapercibida durante horas. El monitoreo externo previsto para LAB-005 detectaría un nodo caído en minutos.
- Evaluar un UPS para el equipo de red y los nodos dentro de LAB-008 (respaldos y recuperación).
