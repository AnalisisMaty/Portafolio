# Características Determinantes en la Compra de Cerveza Artesanal

Estudio de mercado sobre los atributos que más influyen en la decisión de compra de cerveza artesanal entre estudiantes universitarios de la Región del Maule, Chile.

📄 **Informe completo:** [`Informe_2_-_Inteligencia_de_Marketing_-_Sección_A.pdf`](./Informe_2_-_Inteligencia_de_Marketing_-_Sección_A.pdf) — incluye marco teórico, diseño metodológico completo (incluyendo el cálculo del tamaño muestral) y la discusión detallada de resultados. Este README resume el proyecto y documenta cómo reproducir el análisis.

## Pregunta de investigación

¿Cómo influyen variables como el precio, el sabor, el diseño del envase y el origen del producto en la decisión de compra de cerveza artesanal por parte de estudiantes universitarios?

## Objetivo e hipótesis

**Objetivo general:** analizar la influencia del precio, el sabor, el diseño del envase y el origen del producto en la decisión de compra de cerveza artesanal en estudiantes universitarios de la Región del Maule.

| # | Hipótesis | Resultado |
|---|---|---|
| H1 | El precio tiene una influencia moderada en la decisión de compra, siendo más relevantes atributos como el sabor | ✅ Confirmada |
| H2 | El sabor es el atributo más relevante en la compra de cerveza artesanal | ✅ Confirmada |
| H3 | El diseño del envase y el origen local del producto generan una percepción positiva que incrementa la intención de compra | ⚠️ Confirmada parcialmente (solo el origen local resultó significativo) |

## Datos

- **Instrumento:** encuesta estructurada (Google Forms), con preguntas cerradas, de opción múltiple y escalas Likert (1 a 5) para medir la importancia percibida de cada atributo de compra.
- **Muestreo:** no probabilístico por conveniencia. Universo estimado en ~30.000 estudiantes matriculados en instituciones de educación superior de la Región del Maule (Universidad de Talca, UCM, Universidad Autónoma, INACAP, Santo Tomás, CFT San Agustín).
- **Tamaño muestral objetivo:** 68 observaciones, calculado con la fórmula para poblaciones infinitas (Z=1,645 al 90% de confianza, p=0,5, error=10%).
- **Muestra final obtenida:** 71 respuestas (`cerveza_artesanal_71.xlsx`).

### Variables principales

| Variable en el script | Descripción |
|---|---|
| `Precio`, `Sabor` | Importancia percibida de cada atributo (escala Likert 1–5) |
| `variedad`, `diseno_envase`, `origen_maule` | Importancia percibida de variedad, diseño del envase y origen regional (escala 1–5, ya recodificadas) |
| `paga_mas` | Disposición a pagar más por cerveza artesanal (variable dependiente descartada, ver Metodología) |
| `recomienda_amigos` | Disposición a recomendar el producto — variable dependiente usada como proxy de intención de compra |
| `¿Con qué frecuencia consume cerveza artesanal?` | Frecuencia de consumo (texto ordinal), recodificada a `freq_num` en el script |

## Metodología

Todo el procesamiento se realizó en R (`readxl`, `dplyr`, `ggplot2`, `tidyr`).

- **H1** (precio vs. sabor): estadística descriptiva (media, mediana, desviación estándar) y boxplot comparativo.
- **H2** (atributo más relevante): promedio de los 5 atributos evaluados (sabor, precio, variedad, diseño del envase, origen) y gráfico de barras.
- **H3** (diseño de envase y origen local → intención de compra): regresión lineal múltiple con interacciones.
  - La variable dependiente originalmente elegida (`paga_mas`) no mostró asociaciones significativas con los predictores, por lo que se reemplazó por `recomienda_amigos`.
  - La frecuencia de consumo (texto ordinal) se recodificó a la variable numérica `freq_num` (1 a 5).
  - Modelo final:
    ```r
    lm(recomienda_amigos ~ diseno_envase * Sabor + origen_maule * freq_num, data = datos)
    ```

## Resultados de la regresión (H3)

| Variable | Coef. | Error Est. | t | p |
|---|---|---|---|---|
| Intercepto | 0.847 | 1.334 | 0.635 | 0.528 |
| Diseño del envase | -0.280 | 0.635 | -0.440 | 0.661 |
| Sabor | -0.023 | 0.234 | -0.099 | 0.921 |
| **Origen Maule** | **0.649** | 0.261 | **2.484** | **0.016 \*** |
| Frecuencia de consumo | 0.114 | 0.270 | 0.423 | 0.674 |
| Diseño del envase × Sabor | 0.041 | 0.136 | 0.301 | 0.765 |
| Origen Maule × Frecuencia | -0.192 | 0.137 | -1.399 | 0.167 |

Modelo global significativo: F(6, 56) = 3.159, p = 0.0097. R² = 0.253 (el modelo explica un 25,3% de la variabilidad en la intención de recomendar). El único predictor individualmente significativo es el **origen local del producto**: recomendar una cerveza artesanal del Maule se asocia a una mayor valoración de su origen regional, independiente del diseño del envase.

## Estructura del repositorio

```
├── README.md
├── Analisis_cerveza_artesanal.R                        # Script R: limpieza, H1, H2 y H3
├── Informe_2_-_Inteligencia_de_Marketing_-_Sección_A.pdf  # Informe completo
└── cerveza_artesanal_71.xlsx                           # Base de datos (71 respuestas)
```

## Cómo reproducir el análisis

```r
install.packages(c("readxl", "dplyr", "ggplot2", "tidyr"))
```

Con `cerveza_artesanal_71.xlsx` en el mismo directorio, ejecuta `Analisis_cerveza_artesanal.R` completo. El script reproduce, en orden, las tres hipótesis del informe (estadística descriptiva y boxplot de H1, tabla y gráfico de barras de H2, y la regresión de H3).

**Nota metodológica:** la recodificación de `freq_num` en el script original solo contempla las etiquetas de texto `"Una vez al mes o menos"`, `"2-3 veces al mes"`, `"1 vez por semana"`, `"2-3 veces por semana"` y `"Todos los días"`. Como la encuesta real solo registró la categoría `"Más de una vez por semana"` para la frecuencia más alta (sin distinguir "2-3 veces por semana" de "todos los días"), esas 2 respuestas quedan como `NA` en `freq_num` y son excluidas de la regresión de H3 — de ahí que el modelo final use 63 observaciones en vez de las 69 con datos completos en el resto de variables. No afecta las conclusiones del informe, pero es un ajuste pendiente si se retoma este análisis en el futuro.
