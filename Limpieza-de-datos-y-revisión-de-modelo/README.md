# Determinantes del Subempleo por Tiempo Parcial Involuntario (TPI)

Análisis econométrico de los factores individuales, laborales y sociodemográficos asociados a la probabilidad de que una persona ocupada trabaje **involuntariamente** a tiempo parcial, utilizando un modelo probit binario sobre microdatos de encuesta de empleo.

## Pregunta de investigación

> ¿Qué características individuales, laborales o sociodemográficas están asociadas con una mayor probabilidad de que una persona ocupada se encuentre trabajando a tiempo parcial involuntariamente?

La variable dependiente es **TPI** (Tiempo Parcial Involuntario), un indicador dicotómico de subempleo (1 = la persona trabaja menos horas de las que desearía por razones ajenas a su voluntad, 0 = no se encuentra en esa condición).

## Datos

- **Archivo:** `base_2.xlsx`
- **N inicial:** 97.950 observaciones ocupadas.
- **N efectivo en el modelo:** 42.754 observaciones (55.196 fueron excluidas por valores perdidos — *listwise deletion* aplicada automáticamente por `glm()`).
- **Fuente:** microdatos de encuesta de empleo (variables como `ano_trimestre`, `mes_central` y `cae_general` corresponden a la estructura estándar de la Encuesta Nacional de Empleo, INE Chile). Si los datos provienen de otra fuente o período, actualiza esta sección con el detalle correcto (organismo, trimestre y link de descarga).

### Variables utilizadas

| Variable | Descripción | Tipo |
|---|---|---|
| `tpi` | Variable dependiente: 1 = ocupado en tiempo parcial involuntario, 0 = no | Dummy |
| `edad` | Edad de la persona encuestada | Numérica continua |
| `edadsq` | Edad al cuadrado (creada en el script, `edad^2`) | Numérica continua |
| `sexo` | Recodificada a dummy: 1 = Mujer, 0 = Hombre | Factor |
| `nivel` | Nivel educacional alcanzado (escala ordinal) | Numérica |
| `ocup_form` | Formalidad laboral, recodificada a dummy: 1 = Informal, 0 = Formal | Factor |
| `categoria_ocupacion` | Categoría ocupacional: Empleador, Cuenta Propia, Sector privado, Sector público, Personal doméstico puertas adentro/afuera | Factor (6 categorías) |
| `cae_general` | Categoría en la Actividad Económica (rama de actividad) — usada solo en la matriz de correlaciones exploratoria | Numérica/categórica |
| `habituales` | Horas habituales trabajadas — variable de contexto, no incluida en el modelo final | Numérica |

## Metodología

### 1. Limpieza de datos
El script `Limpieza_de_datos_y_prueba_de_modelos.R` recodifica las variables categóricas originales (que venían como códigos numéricos) a etiquetas legibles y luego a factores/dummies utilizables en el modelo:
- `sexo`: 1/2 → "Hombre"/"Mujer" → dummy (Mujer = 1).
- `ocup_form`: 1/2 → "Formal"/"Informal" → dummy (Informal = 1).
- `categoria_ocupacion`: 1–6 → etiquetas descriptivas → factor.
- Se construye `edadsq` para capturar una eventual relación no lineal entre edad y subempleo.

### 2. Modelo

Se estima un modelo **probit** (no logit) por máxima verosimilitud:

```r
maxv <- glm(tpi ~ edad + edadsq + sexo + nivel + ocup_form + categoria_ocupacion,
            family = binomial(link = "probit"),
            data = base_2)
```

La elección de un modelo de probabilidad binaria (frente a MCO) es apropiada porque `tpi` es una variable dicotómica: un modelo lineal podría predecir probabilidades fuera del rango [0,1] y viola los supuestos de homocedasticidad y normalidad de los errores por construcción.

### 3. Diagnósticos aplicados

El script incluye una batería de pruebas para evaluar la especificación y validez del modelo:

| Prueba | Qué evalúa | Resultado obtenido |
|---|---|---|
| `vif()` (Factor de Inflación de Varianza) | Multicolinealidad entre regresores | VIF alto en `edad`/`edadsq` (≈36), esperable por construcción (edadsq es función directa de edad); el resto de variables no presenta multicolinealidad relevante (VIF < 1.5) |
| Matriz de correlaciones | Relaciones lineales entre variables numéricas | Correlaciones bajas entre `tpi` y `edad`, `nivel`, `cae_general` (todas < 0.05 en valor absoluto), consistente con que la relación se capta mejor de forma no lineal/conjunta en el modelo que de forma bivariada |
| `bptest()` (Breusch-Pagan) | Heterocedasticidad | BP = 4188.3, p < 2.2e-16 → se rechaza homocedasticidad |
| `dwtest()` (Durbin-Watson) | Autocorrelación de los residuos | DW = 1.88, p < 2.2e-16. *Nota:* esta prueba está diseñada para datos ordenados temporalmente; al tratarse de datos de corte transversal (encuesta de hogares), su interpretación sustantiva es limitada y se reporta solo como diagnóstico complementario |
| `resettest()` (RESET de Ramsey) | Errores de especificación (formas funcionales omitidas) | RESET = 45.18, p < 2.2e-16 → sugiere posible omisión de no linealidades o interacciones relevantes |
| `shapiro.test()` sobre residuos | Normalidad de los residuos | Ejecutada sobre una muestra aleatoria de 5.000 residuos (`set.seed(123)`) por límite de tamaño muestral de la prueba |
| Gráfico Q-Q e histograma de residuos | Inspección visual de normalidad | Complementan la prueba de Shapiro-Wilk |
| `plot(maxv)` | Gráficos de diagnóstico estándar de `glm` | Apalancamiento, residuos vs. ajustados, etc. |

### 4. Corrección por heterocedasticidad

Dado que el test de Breusch-Pagan detecta heterocedasticidad, los errores estándar se recalculan con una matriz de varianza-covarianza robusta (HC1):

```r
coeftest(maxv, vcov = vcovHC(maxv, type = "HC1"))
```

Los resultados robustos son los que deben reportarse e interpretarse como definitivos; los del `summary(maxv)` original quedan solo como referencia del ajuste base.

## Resultados principales (coeficientes probit, errores robustos HC1)

| Variable | Coeficiente | Error robusto | z | p | Significancia |
|---|---|---|---|---|---|
| Intercepto | -1.9208 | 0.1430 | -13.43 | < 0.001 | *** |
| Edad | -0.0060 | 0.0042 | -1.41 | 0.159 | n.s. |
| Edad² | -0.00005 | 0.00005 | -1.04 | 0.301 | n.s. |
| Sexo (Mujer=1) | 0.2468 | 0.0205 | 12.03 | < 0.001 | *** |
| Nivel educacional | 0.0072 | 0.0024 | 3.04 | 0.002 | ** |
| Ocupación informal | 0.7017 | 0.0246 | 28.54 | < 0.001 | *** |
| Cuenta Propia (vs. ref.) | 0.7655 | 0.1071 | 7.15 | < 0.001 | *** |
| Empleador (vs. ref.) | 0.4306 | 0.1231 | 3.50 | < 0.001 | *** |
| Personal doméstico puertas adentro | -0.4445 | 0.3135 | -1.42 | 0.156 | n.s. |
| Personal doméstico puertas afuera | 0.5302 | 0.1175 | 4.51 | < 0.001 | *** |
| Sector privado | 0.1325 | 0.1084 | 1.22 | 0.221 | n.s. |
| Sector público | -0.1133 | 0.1141 | -0.99 | 0.321 | n.s. |

*Categoría de referencia de `categoria_ocupacion`: definida por el nivel base del factor en R (la primera categoría alfabética/de codificación, no explícita en la salida). Deviance nula: 22.183 (42.753 g.l.); deviance residual: 18.814 (42.742 g.l.); AIC: 18.838; n = 42.754.*

### Interpretación resumida

- **Sexo:** ser mujer se asocia con una mayor probabilidad de estar en tiempo parcial involuntario, efecto positivo y altamente significativo — coherente con la literatura sobre brechas de género en la calidad del empleo.
- **Informalidad laboral:** es el predictor con mayor magnitud de efecto en el modelo; la ocupación informal está fuertemente asociada a una mayor probabilidad de subempleo por tiempo parcial involuntario.
- **Categoría ocupacional:** trabajar por Cuenta Propia, como Empleador o como Personal doméstico puertas afuera se asocia a una mayor probabilidad de TPI respecto a la categoría de referencia; Sector privado, Sector público y Personal doméstico puertas adentro no muestran diferencias significativas.
- **Nivel educacional:** tiene un efecto positivo pero de magnitud pequeña.
- **Edad y edad²:** no resultan significativas una vez controlado por el resto de variables (con errores robustos), es decir, no hay evidencia de una relación etaria clara con el TPI en este modelo.

### Limitaciones del modelo

- El test RESET y el de Breusch-Pagan indican posibles problemas de especificación y heterocedasticidad; esta última ya fue corregida mediante errores estándar robustos, pero la primera sugiere que podrían faltar términos no lineales o interacciones (p. ej., entre `sexo` y `categoria_ocupacion`) que mejorarían el ajuste.
- El VIF elevado de `edad`/`edadsq` es estructural (una variable es función de la otra) y no indica un problema real de colinealidad entre regresores independientes.
- El test de Durbin-Watson no tiene una interpretación causal clara en datos de corte transversal y se incluye solo por completitud metodológica.

## Estructura del repositorio

```
├── README.md
├── Limpieza_de_datos_y_prueba_de_modelos.R   # Script completo: limpieza, modelo probit y diagnósticos
└── base_2.xlsx                                # Microdatos utilizados (ver nota de fuente más arriba)
```

## Requisitos y reproducibilidad

Paquetes de R utilizados:

```r
install.packages(c("readxl", "car", "dplyr", "lmtest", "sandwich"))
```

Para reproducir el análisis completo:

```r
source("Limpieza_de_datos_y_prueba_de_modelos.R")
```

El script asume que `base_2.xlsx` se encuentra en el directorio de trabajo activo (`getwd()`).

## Autoría

Proyecto desarrollado como parte de un curso/trabajo de econometría aplicada.

Matías Orellana
Econometría - Ingeniería Comercial 
