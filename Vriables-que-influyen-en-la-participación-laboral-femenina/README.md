# Análisis Econométrico y Modelamiento — Participación Laboral Femenina

La finalidad de los códigos mostrados en este proyecto es identificar las variables que más influyen en la participación laboral femenina en Chile.

📄 **Informe completo:** el detalle de metodología, resultados, efectos marginales y discusión está en el archivo titulado Informe_Participacion_Laboral_Femenina.pdf. Este README es un resumen orientado a quien quiera entender o reproducir rápidamente el análisis.

## Datos

Se utiliza la encuesta **CASEN 2022** (base publicada en formato STATA 18, marzo de 2024), disponible en:
https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen-2022

La muestra se filtra a mujeres mayores de 17 años. Tras el filtrado y la eliminación de observaciones con datos faltantes en las variables del modelo, la muestra final utilizada en la estimación es de **85.132 mujeres**.

## Modelo

Se estima un modelo de regresión logística binaria (GLM, distribución binomial, función de enlace `logit`), por máxima verosimilitud, para analizar la probabilidad de que la variable dependiente `o1` tome el valor 1 (participa laboralmente):

```r
Modelo <- glm(o1 ~ ecivil + edad + edad_squared + r1a_dummy + e6a + region + tot_per_h,
              family = binomial("logit"),
              data = Base_de_datos_mujeres)
```

Para facilitar la interpretación de los coeficientes (que están en escala log-odds, no en probabilidad), se calculan además los **efectos marginales promedio** (Average Marginal Effects, AME) con `avg_slopes()` del paquete `marginaleffects`.

## Variables

| Variable en el modelo | Variable original CASEN | Descripción / recodificación |
|---|---|---|
| `o1` | `o1` | Dependiente. Participación laboral: recodificada a 1 = trabaja, 0 = no trabaja |
| `ecivil` | `ecivil` | Estado civil: recodificada a 1 = casada, 0 = soltera/otro |
| `edad` | `edad` | Edad en años |
| `edad_squared` | — | Edad al cuadrado (creada en el script: `edad^2`), captura la relación no lineal edad–participación |
| `r1a_dummy` | `r1a` | Nacionalidad: recodificada a 1 = chilena, 0 = extranjera |
| `e6a` | `e6a` | Nivel educacional alcanzado |
| `region` | `region` | Región de residencia (factor), releveled con la Región Metropolitana (código 13) como categoría de referencia |
| `tot_per_h` | `tot_per_h` | Número de personas que viven en el hogar |

## Principales hallazgos

- **Estado civil:** las mujeres casadas tienen una probabilidad ~11,7 puntos porcentuales (p.p.) menor de participar en el mercado laboral que las solteras.
- **Edad:** relación en forma de U invertida — la probabilidad de participar aumenta con la edad hasta ~44 años y luego disminuye.
- **Nacionalidad:** las mujeres extranjeras tienen una probabilidad ~8,8 p.p. menor de participar que las chilenas.
- **Nivel educativo:** efecto positivo — cada nivel educativo adicional aumenta la probabilidad de participar en ~3,1 p.p.
- **Región:** casi todas las regiones muestran menor participación que la Región Metropolitana (la más baja es Ñuble, -10,3 p.p.); Aysén es la única excepción, con un efecto positivo.
- La gran mayoría de los coeficientes son estadísticamente significativos al 5%; la única excepción es la Región 12 (Magallanes), sin diferencia significativa respecto a la Región Metropolitana.

*(Detalle completo de coeficientes, errores estándar y efectos marginales en el informe.)*

## Estructura del repositorio

```
├── README.md
├── Codigos_proyecto_de_econometria.R              # Limpieza de datos, modelo logit y efectos marginales
└── Informe_Participacion_Laboral_Femenina.docx    # Informe completo: metodología, resultados y discusión
```

## Cómo reproducir el análisis

1. Descarga la base de datos CASEN 2022 (formato STATA, .dta) desde el link indicado arriba.
2. Instala los paquetes necesarios:
   ```r
   install.packages(c("dplyr", "tidyverse", "haven", "marginaleffects"))
   ```
3. Carga la base descargada (el script asume que este objeto ya existe en el entorno; agrega esta línea antes de correr el resto):
   ```r
   Base_de_datos_Casen_2022_STATA_18_marzo_2024 <- haven::read_dta("ruta/al/archivo.dta")
   ```
4. Corre `Codigos_proyecto_de_econometria.R` completo. Al final obtendrás el `summary(Modelo)` con los coeficientes logit y `avg_slopes(Modelo)` con los efectos marginales promedio.
