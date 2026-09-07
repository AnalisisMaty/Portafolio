# Movilidad Urbana y Género

Análisis de los patrones de movilidad urbana al trabajo en Chile con enfoque de género, usando datos de la Encuesta CASEN 2022. El objetivo es determinar si existen diferencias significativas en la frecuencia de viajes semanales al trabajo entre hombres y mujeres, y qué variables socioeconómicas explican esa diferencia.

📄 **Este proyecto es un informe autocontenido en R Markdown**: [`Trabajo_en_markdown.Rmd`](./Trabajo_en_markdown.Rmd) incluye a la vez el código y la redacción completa (introducción, resultados, interpretación y conclusión). Al compilarlo ("knit") genera directamente el informe en HTML — no existe un Word/PDF separado para este proyecto.

## Pregunta de investigación

¿Existen diferencias significativas en la frecuencia de viajes semanales al trabajo entre hombres y mujeres, y qué variables socioeconómicas explican esta movilidad?

## Datos

- **Fuente:** Encuesta CASEN 2022.
- **Archivo:** `movilidad.csv` (3.479 observaciones, 16 variables) — usado directamente por el `.Rmd`.
- **Diccionario de variables:** `movilidad.xlsx` contiene la descripción de cada columna del dataset (no se usa en el análisis, es solo referencia).

| Variable | Descripción |
|---|---|
| `edad` | Edad del entrevistado/a en años |
| `veces` | Veces a la semana que realiza el viaje hacia el trabajo (variable dependiente) |
| `esc` | Años de escolaridad |
| `comuna` | Código de la comuna de la Región Metropolitana |
| `n_men5c` | Número de niños menores de 5 años en el hogar |
| `n_men15c` | Número de niños entre 5 y 14 años en el hogar |
| `tiempo` | Duración del viaje al trabajo (horas) |
| `pub` | 1 = usa transporte público, 0 = no |
| `sex` | 1 = mujer, 0 = hombre |
| `c_pareja` | 1 = vive con pareja, 0 = no |
| `dependency` | Categoría laboral: 1 Empleador, 2 Autoempleado, 3 Empleado dependiente, 4 Trabajador/a doméstico |
| `sk_occ` | Calificación ocupacional (oficina/operario, alta/baja habilidad) |
| `ing_hog` | Ingreso del hogar (millones de pesos) |
| `vehiculo` | 1 = hay vehículo en el hogar, 0 = no |
| `numper_n` | Número de personas adultas que viven en el hogar |
| `score1` | Medida continua de violencia en el vecindario del entrevistado/a |

## Metodología

El análisis se divide en dos fases:

**1. Análisis probabilístico (distribución de Poisson)**
Se calcula la tasa promedio de viajes semanales (λ) por separado para hombres y mujeres, y se estiman probabilidades puntuales y acumuladas (`dpois`, `ppois`) para distintos escenarios (3 viajes, 1 a 3 viajes, más de 6 viajes a la semana), junto con gráficos de la distribución teórica completa (0 a 10 viajes).

**2. Regresión de Poisson (GLM)**
Se estima un modelo lineal generalizado de familia Poisson, **por separado para hombres y mujeres**, para identificar qué variables explican el número de viajes semanales al trabajo:

```r
glm(veces ~ edad + esc + n_men5c + n_men15c + ing_hog + factor(vehiculo),
    family = poisson("log"),
    data = movilidad[movilidad$sex == 0, ])  # y == 1 para mujeres
```

Al ser una regresión de Poisson, los coeficientes se interpretan como cambios porcentuales en la tasa esperada de viajes (no como cambios absolutos), vía `exp(coeficiente) - 1`.

## Principales hallazgos

- **Diferencia base por sexo:** los hombres parten con una tasa esperada de ~5,6 viajes semanales (constante = 1,729) frente a ~4,5 de las mujeres (constante = 1,504).
- **Ingreso del hogar** (significativo en ambos sexos, efecto negativo): por cada unidad adicional de ingreso, los viajes semanales caen ~1% en hombres y ~1,3% en mujeres — el efecto es más fuerte en mujeres, lo que sugiere mayor acceso a flexibilidad/teletrabajo en hogares de mayores ingresos.
- **Escolaridad** (significativa solo en hombres): cada año adicional de escolaridad reduce los viajes semanales en ~0,6%.
- **No significativas en ningún grupo:** presencia de hijos (menores de 5 o entre 5-14 años), tenencia de vehículo, y edad — sugiere que el viaje al trabajo está determinado por el contrato laboral más que por circunstancias del hogar.
- Las distribuciones de Poisson muestran una asimetría clara: hombres inclinados hacia mayor frecuencia de viajes, mujeres concentradas en frecuencias más bajas.

*(Interpretación completa, tablas de regresión con `stargazer` y gráficos de distribución en el informe renderizado.)*

## Estructura del repositorio

```
├── README.md
├── Trabajo_en_markdown.Rmd   # Informe completo (código + narrativa), tema rmdformats::readthedown
├── movilidad.csv             # Datos utilizados por el análisis (3.479 obs.)
└── movilidad.xlsx            # Diccionario de variables (solo referencia)
```

## Cómo reproducir / compilar el informe

1. Asegúrate de tener `movilidad.csv` en el mismo directorio que el `.Rmd` (la ruta de lectura es relativa: `read.csv("movilidad.csv")`).
2. Instala los paquetes necesarios:
   ```r
   install.packages(c("stargazer", "rmdformats", "knitr"))
   ```
3. Abre `Trabajo_en_markdown.Rmd` en RStudio y presiona **Knit** (o ejecuta `rmarkdown::render("Trabajo_en_markdown.Rmd")`). Esto genera un archivo HTML con el informe completo, tablas de regresión y gráficos incluidos.
