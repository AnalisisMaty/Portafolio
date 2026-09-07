# Librerías de Análisis Exploratorio de Datos (EDA) en Python

Notebook de demostración que compara distintas librerías de Python para automatizar el Análisis Exploratorio de Datos (EDA), aplicadas sobre un dataset de registros de pozo (*well log*).

A diferencia de un proyecto de investigación, el objetivo aquí **no es responder una pregunta específica**, sino mostrar de forma práctica qué ofrece cada herramienta, para tenerlas como referencia rápida a la hora de explorar un dataset nuevo.

## Librerías demostradas

| Librería | Qué hace | Salida |
|---|---|---|
| [`ydata-profiling`](https://github.com/ydataai/ydata-profiling) | Genera un reporte automático con estadísticas descriptivas, distribuciones, valores faltantes, correlaciones y alertas de calidad de datos para cada columna | Reporte HTML interactivo (`reporte_xeek_well.html`) |
| [`D-Tale`](https://github.com/man-group/dtale) | Abre el DataFrame en una interfaz web interactiva tipo Excel: permite filtrar, ordenar, graficar y describir columnas sin escribir código adicional | App web interactiva (en el notebook o en el navegador) |
| [`Sweetviz`](https://github.com/fbdesignpro/sweetviz) | Similar a ydata-profiling, pero orientado a comparar distribuciones (por ejemplo, train vs. test, o por variable objetivo) con un diseño muy visual | Reporte HTML |
| [`missingno`](https://github.com/ResidentMario/missingno) | Visualiza patrones de datos faltantes: gráfico de barras, matriz, dendrograma de correlación de nulos y mapa de calor | Gráficos (matplotlib) |
| [`sketch`](https://github.com/approximatelabs/sketch) | Permite hacerle preguntas en lenguaje natural a un DataFrame (ej. "¿cuáles son los valores máximos de cada columna numérica?"), usando un modelo de lenguaje | Respuesta en texto |

## Dataset

El notebook usa un archivo llamado `Xeek_Well_15-9-15.csv` (datos de registros de pozo/well log). El archivo biene incluido en el repositorio.

## ⚠️ Nota de seguridad importante

La celda que usa `sketch` incluye una línea para asignar una API Key de OpenAI:

```python
os.environ["OPENAI_API_KEY"] = "sk-proj-tu-api-key-aqui..."
```

**Nunca subas tu API Key real a GitHub.** Antes de compartir o subir este notebook:
- Si alguna vez reemplazaste el placeholder por tu clave real y ejecutaste el notebook, revisa el historial de commits — una key expuesta debe revocarse desde tu cuenta de OpenAI, no basta con borrarla en un commit posterior.
- Usa variables de entorno externas (por ejemplo, un archivo `.env` agregado a `.gitignore`) en lugar de escribir la clave directamente en el código.

## Cómo ejecutar

1. Coloca `Xeek_Well_15-9-15.csv` en la misma carpeta que el notebook.
2. Instala las librerías (cada una se instala también dentro del propio notebook con `!pip install`):
   ```bash
   pip install ydata-profiling dtale sweetviz missingno sketch
   ```
3. Abre `Análisis_Exploratorio_de_datos.ipynb` en Jupyter Notebook, JupyterLab o VS Code y ejecuta las celdas en orden.
4. Si vas a usar la celda de `sketch`, define tu propia API Key de OpenAI como variable de entorno antes de correr esa celda (ver nota de seguridad arriba).

*Nota:* `D-Tale` abre un servidor local interactivo (`dt.show(df)`), por lo que su salida no se puede "ver" en el HTML exportado del notebook — hay que ejecutarlo en vivo para explorarlo.

## Estructura del repositorio

```
├── README.md
├── Análisis_Exploratorio_de_datos.ipynb   # Notebook con la demostración de las 5 librerías
└── Xeek_Well_15-9-15.csv                  # Dataset (no incluido — debes agregarlo tú)
```
