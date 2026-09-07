# Análisis Geoespacial con GeoPandas — Criminalidad en Londres

Notebook de práctica sobre datos geoespaciales con **GeoPandas**: lectura de shapefiles, mapas coropléticos, combinación (*merge*) de geometrías con datos tabulares, y generación de una animación GIF mostrando la evolución de un indicador en el mapa a lo largo del tiempo.

No responde una pregunta de investigación específica: es una demostración de herramientas de análisis geoespacial, usando como caso de aplicación la evolución de delitos violentos por barrio (*borough*) en Londres entre 2008 y 2016.

## Datos

Este proyecto usa dos fuentes de datos que deben combinarse:

**1. Shapefile de los límites de los boroughs de Londres** (`London_Borough_Excluding_MHW.*`)

Un shapefile **no es un solo archivo**: es un conjunto de archivos que deben mantenerse juntos en la misma carpeta para poder leerse (GeoPandas solo necesita apuntar al `.shp`, pero internamente lee también los demás):

| Archivo | Contenido |
|---|---|
| `.shp` | Geometrías (los polígonos de cada borough) |
| `.shx` | Índice de las geometrías |
| `.dbf` | Tabla de atributos (nombre del borough, hectáreas, códigos, etc.) |
| `.prj` | Sistema de referencia de coordenadas (CRS) — en este caso, *OSGB36 / British National Grid* |
| `.sbn` / `.sbx` | Índices espaciales adicionales (búsquedas espaciales más rápidas) |
| `.atx` (x2) | Índices de atributos sobre las columnas `GSS_CODE` y `NAME` |
| `_shp.xml` | Metadatos del dataset |

Columnas relevantes de la tabla de atributos: `NAME` (nombre del borough), `GSS_CODE` (código oficial ONS), `HECTARES` (superficie).

**2. Estadísticas de criminalidad por borough** (`MPS_Borough_Level_Crime_Historic.csv`)

Publicado por la Policía Metropolitana de Londres (MPS). 1.056 filas × 111 columnas: `borough`, `major_category`, `minor_category`, y una columna por cada mes desde `200801` hasta `201612` (formato `AAAAMM`) con el número de delitos registrados ese mes.

## Contenidos del notebook

1. **Lectura y visualización básica del shapefile**: `gpd.read_file()`, exploración de la tabla de atributos, y un primer mapa coroplético coloreando cada borough según su superficie (`HECTARES`).
2. **Preparación de los datos de criminalidad**: carga del CSV, filtrado a la categoría `'Violence Against the Person'`, y agregación de los conteos mensuales por borough (`groupby('borough').sum()`).
3. **Unión de datos espaciales y tabulares**: `merge = data.set_index('NAME').join(df_new)` — combina la geometría de cada borough con sus estadísticas de criminalidad, usando el nombre del borough como llave común.
4. **Mapas coropléticos por mes específico**: comparación visual de delitos violentos en dos fechas puntuales (abril 2008 vs. enero 2016).
5. **Animación temporal**: un bucle genera un mapa coroplético (PNG) por cada año seleccionado (2008 a 2016, un mes representativo por año), con escala de color fija (`vmin`/`vmax`) para que los mapas sean comparables entre sí, y luego los combina en un GIF animado (`movie.gif`) con la librería `imageio`.

## ⚠️ Antes de ejecutar

- El notebook guarda las imágenes intermedias en una carpeta llamada `maps/` (`output_path = 'maps'`), pero **no crea esa carpeta automáticamente** — debes crearla tú antes de correr la celda del bucle, o se producirá un error al intentar guardar el primer PNG:
  ```bash
  mkdir maps
  ```
- El `merge` entre el shapefile y el CSV de criminalidad depende de que los nombres de borough coincidan exactamente entre `data['NAME']` y `df_new` (índice `borough`). Si alguno no coincide (por tildes, mayúsculas o nombres alternativos), esa fila del mapa quedará con valores nulos sin lanzar ningún error — conviene revisar `merged.isna().sum()` después del join.

## Cómo ejecutar

```bash
pip install geopandas pandas numpy matplotlib seaborn imageio
```

*Nota:* `geopandas` depende de librerías del sistema (GDAL, GEOS, PROJ). Si `pip install geopandas` falla, es más simple instalarlo con conda: `conda install -c conda-forge geopandas`.

Con `London_Borough_Excluding_MHW.*` (todos los archivos) y `MPS_Borough_Level_Crime_Historic.csv` en la misma carpeta que el notebook, y la carpeta `maps/` ya creada, ejecuta `Geopandas.ipynb` en orden.

## Estructura del repositorio

```
├── README.md
├── Geopandas.ipynb                            # Notebook con la demostración
├── MPS_Borough_Level_Crime_Historic.csv       # Estadísticas de criminalidad por borough
└── London_Borough_Excluding_MHW.*             # Shapefile completo (8 archivos, ver tabla arriba)
```
