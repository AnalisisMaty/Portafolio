# Segmentación de Clientes — Análisis Cluster para Cafetería (Pan Canela, Constitución)

Análisis de clusterización (K-Means y jerárquico) realizado como parte de una asesoría de investigación de mercado para **Pan Canela**, una cafetería ubicada en Constitución, Región del Maule. El objetivo es segmentar a los encuestados en grupos con comportamientos y preferencias similares, para apoyar decisiones de estrategia comercial (evaluar una nueva sucursal, ampliar la carta, definir formatos de atención, etc.).

## Contexto

Como parte de una asesoría más amplia a la cafetería, se aplicó una encuesta de opinión (420 respuestas, vía Google Forms) sobre hábitos de consumo, valoración de atributos (precio, calidad, servicio, ambiente, ubicación), disposición a pagar y variables sociodemográficas. Este repositorio documenta el **análisis cluster** realizado sobre esos resultados para identificar perfiles de cliente.

## Datos

- **Archivo:** `Resultados_encuesta_2.csv` (respuestas exportadas directamente desde Google Forms, 420 filas × 45 columnas).
- El script selecciona 11 columnas relevantes **por posición** (los nombres de columna que exporta Google Forms son extremadamente largos y poco prácticos para trabajar):

| Variable en el script | Columna original (resumen) |
|---|---|
| `Residencia` | ¿Reside en Constitución o es visitante? |
| `Frecuencia_Visita` | Frecuencia con que visita una cafetería |
| `Disposicion_Pagar` | Cuánto está dispuesto a pagar al consumir en una cafetería |
| `Valoracion_precio` | Importancia del precio al elegir cafetería (Muy Bajo–Muy Alto) |
| `Valoracion_calidad` | Importancia de la calidad del producto |
| `Valoracion_servicio` | Importancia del servicio y atención |
| `Valoracion_ambiente` | Importancia del ambiente y comodidad |
| `Valoracion_ubicacion` | Importancia de la ubicación |
| `Edad` | Edad del encuestado (texto libre) |
| `Genero` | Género del encuestado |
| `Motivacion` | Motivación principal para visitar una cafetería |

## Metodología

Paquetes usados: `tidyverse`, `cluster`, `factoextra`, `readr`.

### 1. Limpieza y recodificación robusta de texto

Al tratarse de respuestas de una encuesta abierta en varios campos, el texto llega con variaciones naturales de redacción (mayúsculas/minúsculas, "por semana" vs. "a la semana", con o sin espacios, pequeños errores de tipeo). En vez de mapear cada variante a mano, el script normaliza el texto (minúsculas + espacios limpios con `str_squish()`) y usa `str_detect()` con expresiones regulares para capturar todas las formas en que una misma respuesta puede aparecer — por ejemplo, `"2 veces por semana"` y `"2 veces a la semana"` se reconocen como la misma categoría.

Las respuestas genuinamente ambiguas o en blanco (texto libre no clasificable, como "Rara vez" o "Depende si voy sola o acompañada") se codifican explícitamente como `NA`, en vez de asignarles un valor numérico arbitrario — esto es clave para que `na.omit()` las excluya correctamente del clustering más adelante, sin que una respuesta faltante se confunda con un valor real bajo de la escala.

### 2. Variables construidas

- **`Frecuencia_visita_num`**: escala numérica de 0,2 (una vez al año) a 6 (todos los días), construida a partir del texto libre de frecuencia de visita.
- **`Disposicion_Pagar_num`**: monto en pesos chilenos, extraído de las distintas formas en que se expresó el monto (con/sin signo peso, con/sin espacio).
- **Valoraciones de atributos** (`Valoricion_precio_num`, `_calidad_num`, `_servicio_num`, `_ambiente_num`, `_ubicacion_num`): escala Likert de 1 (Muy Bajo) a 5 (Muy Alto).
- **`Residencia_num`**: 1 = reside en Constitución, 0 = visitante.
- **`Edad_limpia`**: edad numérica, extraída con expresiones regulares del campo de texto libre.
- **`Genero_num`**: 0 = Masculino, 1 = Femenino (las respuestas "Otro" y "Prefiero no decirlo" se excluyen de esta codificación binaria en vez de forzarlas a un valor arbitrario).
- **`Motivacion_num`**: 1 = Compartir con amigos/familia, 2 = Trabajar o estudiar, 3 = Relajarse/disfrutar del ambiente, 4 = Probar productos.

### 3. Preparación para clustering

- Se descartan las filas con datos incompletos (`na.omit()`) antes de escalar.
- Todas las variables se estandarizan con `scale()` (media 0, varianza 1), para que variables en escalas muy distintas (como el monto en pesos frente a un puntaje Likert 1–5) no dominen el cálculo de distancias.
- El número óptimo de clusters se evalúa con el método del codo (`fviz_nbclust(..., method = "wss")`); se trabaja con **k = 4**.

### 4. Clustering

- **K-Means** (`kmeans()`, 25 inicializaciones con `nstart = 25`, semilla fija `set.seed(123)` para reproducibilidad), visualizado con `fviz_cluster()`.
- **Clustering jerárquico** (`hclust`, método de Ward, distancia euclidiana) como validación cruzada del método, visualizado como dendrograma cortado en 4 grupos.
- Caracterización final: promedio de cada variable por cluster, para describir el perfil de cada segmento.

## Resultados: los 4 segmentos de clientes

| | Cluster 1 | Cluster 2 | Cluster 3 | Cluster 4 |
|---|---|---|---|---|
| **Tamaño** | 69 (22,0%) | 69 (22,0%) | 97 (30,9%) | 79 (25,2%) |
| Frecuencia de visita | 4,14 (alta) | 3,52 (media) | 3,80 (media-alta) | 3,80 (media-alta) |
| Importancia del precio | 3,59 | 2,84 (baja) | 3,24 | 3,11 |
| Importancia del servicio | 4,09 | 4,93 (muy alta) | 4,04 | 4,08 |
| Disposición a pagar | \$10.797 | \$12.790 (la más alta) | \$11.985 | \$11.772 |
| Importancia de la calidad | 4,19 | 4,91 (muy alta) | 3,98 | 4,14 |
| Importancia del ambiente | 4,13 | 4,87 (muy alta) | 3,92 | 4,16 |
| Importancia de la ubicación | 2,75 | 3,33 | 3,01 | 2,82 |
| % residentes de Constitución | 100% | 81% | 100% | **0%** |
| Edad promedio | 33,4 | 35,5 | 32,8 | 33,5 |
| % mujeres | 0% | 70% | 98% | 60% |
| Motivación principal | Trabajar/Estudiar | Compartir con amigos/familia | Trabajar/Estudiar–Relajarse | Relajarse/disfrutar |

**Interpretación de los segmentos:**

- **Cluster 2 — "Clientes premium, poco sensibles al precio"**: la mayor disposición a pagar y las valoraciones más altas en calidad, servicio y ambiente, junto con la menor importancia relativa al precio. Mayoritariamente mujeres (70%), algo mayores en edad, motivadas por compartir con otros. Es el segmento ideal para productos o experiencias de mayor valor agregado.
- **Cluster 3 — "Clientas locales frecuentes" (el segmento más grande, 31%)**: casi enteramente residentes de Constitución (100%) y mujeres (98%), las más jóvenes en promedio, motivadas principalmente por trabajar/estudiar. Es el núcleo de la base de clientes habituales.
- **Cluster 1 — "Clientes locales frecuentes, masculino"**: también 100% residentes de Constitución, pero exclusivamente hombres, con la frecuencia de visita más alta de los cuatro segmentos y menor disposición a pagar que el resto.
- **Cluster 4 — "Visitantes/turistas" (25%)**: el hallazgo más relevante para la estrategia de expansión — **el 100% de este segmento son visitantes**, no residentes de Constitución. Dado que la asesoría contempla evaluar una sucursal cerca de la playa, este segmento es clave: representa a un cuarto de la muestra y su motivación principal es relajarse/disfrutar del ambiente, coherente con un perfil turístico.

## Estructura del repositorio

```
├── README.md
├── codigo_cluster_final.R           # Script completo: limpieza, K-Means y clustering jerárquico
└── Resultados_encuesta_2.csv        # Datos de la encuesta (420 respuestas, 45 columnas)
```

## Cómo reproducir el análisis

```r
install.packages(c("tidyverse", "cluster", "factoextra"))
```

Con `Resultados_encuesta_2.csv` en el mismo directorio, ejecuta `codigo_cluster_final.R` completo. El script genera automáticamente `Datos_Caracterizacion_FINAL.csv` con la asignación de cluster para cada encuestado, además de los gráficos del método del codo, la visualización de clusters y el dendrograma.
