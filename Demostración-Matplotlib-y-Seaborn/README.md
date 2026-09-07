# Visualización de Datos con Matplotlib y Seaborn

Notebook de práctica que recorre las funcionalidades principales de **Matplotlib** (visualización de bajo nivel, control total sobre la figura) y **Seaborn** (visualización estadística de alto nivel, construida sobre Matplotlib), como referencia rápida de sintaxis y opciones de cada tipo de gráfico.

No responde una pregunta de investigación específica: es una demostración de herramientas, pensada como material de consulta para futuros proyectos de análisis de datos.

## Contenidos

**Matplotlib — fundamentos de `Figure` y `Axes`**
- Creación de figuras y subplots (`plt.figure`, `fig.add_subplot`, `plt.subplots`)
- Títulos, etiquetas de ejes, grilla y leyendas (incluyendo notación LaTeX en las etiquetas)
- Estilos de línea y marcador personalizados
- Anotaciones con flechas (`ax.annotate`) para destacar puntos de interés
- Límites de ejes (`set_xlim`, `set_ylim`)

**Matplotlib — tipos de gráfico**
- Gráfico de barras con etiquetas rotadas
- Histogramas (simples, superpuestos, con transparencia)
- Boxplots (verticales, horizontales, agrupados y con estilos personalizados)
- Scatter plot
- Mapa de calor de correlaciones con `imshow`

**Seaborn — visualización estadística**
- `jointplot`: relación entre dos variables + distribuciones marginales (modos scatter y con regresión)
- `pairplot`: matriz de relaciones entre todas las variables numéricas, con color por categoría (`hue`)
- Combinación de `boxplot` + `stripplot` para comparar distribuciones por categoría, con escala logarítmica
- `heatmap`: mapas de calor sobre datos pivoteados (serie de tiempo) y sobre matrices de correlación

## Datasets utilizados

Todo el notebook es autocontenido — **no se necesita ningún archivo externo**:
- Datos sintéticos generados con `numpy.random` (distribuciones normales, uniformes) para los ejemplos de Matplotlib.
- Datasets de ejemplo incluidos en Seaborn (se descargan automáticamente la primera vez que se llama `sns.load_dataset()`, requiere conexión a internet): `tips`, `penguins`, `planets`, `flights`.

## Cómo ejecutar

```bash
pip install matplotlib seaborn numpy
```

Luego abre `Matplotlib_y_Seaborn.ipynb` en Jupyter Notebook, JupyterLab o VS Code y ejecuta las celdas en orden (algunas celdas reutilizan y modifican la figura `fig`/`ax` creada en la celda anterior, por lo que conviene correrlas en secuencia y no salteadas).

## Estructura del repositorio

```
├── README.md
└── Matplotlib_y_Seaborn.ipynb   # Notebook con la demostración de ambas librerías
```
