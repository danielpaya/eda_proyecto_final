# Guía para construir UAP_Dashboard_CRISP-DM.pbix (≈ 1,5 h)

Un .pbix es un binario propietario de Power BI Desktop y no se puede generar fuera de él. Este kit deja todo listo para armarlo rápido y que coincida con la sección 6 del informe (Tablas 15–16, Figuras 16–17).

## Contenido
| Archivo | Para qué |
|---|---|
| `data/*.csv` | 5 tablas ya procesadas (reales, de la corrida del notebook) |
| `01_power_query.m` | Carga y tipos (cultura en-US, duración en minutos, orden de franjas) |
| `02_dim_calendario.dax` | Calendario 2010–2017 |
| `03_measures.dax` | 22 medidas |
| `UAP_tema.json` | Paleta azul #1F3A5F, ámbar #F2A541, gris #8C8C8C; Segoe UI |

## Paso 1. Cargar datos
1. Power BI Desktop > Obtener datos > Consulta en blanco. Crear parámetro `RutaDatos` (Texto) = carpeta `data\` con `\` final.
2. Crear una consulta por bloque de `01_power_query.m` y nombrarlas: `fact_reportes`, `fact_pronostico`, `dim_forma`, `dim_pais`, `metricas_modelo`. Cerrar y aplicar.
3. Modelado > Nueva tabla: pegar `02_dim_calendario.dax`; renombrar `Date` a `Fecha`; Marcar como tabla de fechas. Ordenar `Mes` por `MesNum`, `DiaSemana` por `DiaSemanaNum`; en `fact_reportes`, `franja_dia` por `franja_orden` y `rango_duracion` por `rango_duracion_orden`; en `dim_forma`, `grupo_forma` por `grupo_orden`.
4. Crear tabla `_Medidas` (Entrar datos) y pegar las 22 medidas de `03_measures.dax`.

## Paso 2. Modelo (Tabla 15; filtro en una dirección, uno a varios)
| Uno (1) | Varios (*) | Llave |
|---|---|---|
| dim_calendario[Fecha] | fact_reportes[fecha] | fecha |
| dim_forma[forma] | fact_reportes[forma] | forma |
| dim_pais[pais] | fact_reportes[pais] | pais |
| dim_calendario[Fecha] | fact_pronostico[fecha] | fecha |

`metricas_modelo` sin relaciones. Acomoda la vista de modelo en estrella (hechos al centro) y toma la **captura = Figura 16**.

## Paso 3. Tema
Vista > Temas > Examinar temas > `UAP_tema.json`. Fuente Segoe UI; **títulos que enuncian el hallazgo** (p. ej. "El 65 % de los reportes ocurre entre 18 y 23 h").

## Paso 4. Páginas (Tabla 16)
1. **Resumen**: tarjetas (Total reportes, Mediana duración, % nocturnos, Variación interanual), líneas por AñoMes, barras por año.
2. **Patrones temporales (P1)**: líneas por mes, columnas por día de la semana, **matriz hora × día de la semana** con formato condicional, columna de reportes por día con `festivo_etiqueta` (multiplicador festivos).
3. **Geografía**: mapa (lat/lng de `fact_reportes` o `dim_pais`), barras por país (Top 10), anillo EE. UU. / fuera de EE. UU.
4. **Formas y duración (P2)**: barras por forma, histograma por `rango_duracion`, treemap por grupo de forma, barras 100 % apiladas forma × franja.
5. **Modelo (P3)**: líneas Real vs Pronóstico (`fact_pronostico`, eje fecha, bandas li_95/ls_95), tabla de métricas (MAE, MAPE, Mejora, Cobertura IC) y plan 2017 (conjunto = Futuro).
   - Poner filtros de página: `granularidad` = Mensual. Segmentador **de selección única** sobre `modelo` (Holt-Winters por defecto). Sin él, la medida 17 suma todos los modelos.

Tipos de visual para el criterio de la rúbrica: tarjeta, línea, columna, barra, matriz, mapa, anillo, treemap, histograma, tabla, segmentador.

## Paso 5. Interactividad
- **Segmentadores sincronizados** (Vista > Sincronizar segmentadores) en páginas 1–4: Año, Región (`dim_pais[region]`), País, Grupo de forma, Franja horaria.
- **Interacción cruzada**: Formato > Editar interacciones (desactivarla en las tarjetas KPI si no deben filtrarse).
- **Tooltip personalizado** para formas: nueva página, Tamaño de página = Información sobre herramientas, con reportes y mediana de duración; asignarla en el visual de barras por forma.
- **Obtención de detalles (drill-through)** por forma y por país: página con campo de obtención de detalles `dim_forma[forma_es]` / `dim_pais[nombre_pais]`.
- **Marcadores**: "4 de julio" (filtrar Mes = jul y Día = 4), "Fuera de EE. UU." (región <> EE. UU.), "Restablecer filtros". Botones de marcador + botones de navegación entre páginas.

## Paso 6. Control de consistencia (debe cuadrar con Python)
| Medida | Valor esperado |
|---|---|
| Total reportes (sin filtros) | 49 803 |
| Mediana duración (min, sin imputadas) | 3,0 |
| % nocturnos | 64,9 % |
| % fuera de EE. UU. | 7,7 % |
| Festivos pirotecnia (reportes / días) | 2 164 / 21 |
| Mediana diaria festivo / día común → multiplicador | 77 / 17 → ≈ 4,5 |
| Modelo = Holt-Winters: MAE / MAPE / Mejora / Cobertura IC | 87,34 / 17,23 % / 6,59 % / 92 % |
| SARIMA: MAE · Random Forest: MAE | 100,63 · 96,55 |

Si algo no cuadra, revisar la cultura en-US y los filtros de página.

## Paso 7. Entrega
1. Guardar como `UAP_Dashboard_CRISP-DM.pbix`.
2. Capturas: Figura 16 (modelo), Figura 17 (página 5) y las cinco páginas para el Anexo C; reemplazar los marcadores amarillos del informe.
3. Archivo > Exportar > PDF (opcional, como respaldo).
