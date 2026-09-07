library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

# ------------------------------------------------------
# Carga de datos
# ------------------------------------------------------
datos <- read_excel("cerveza_artesanal_71.xlsx")

# ------------------------------------------------------
# Hipótesis 1: "El precio tiene una influencia moderada en la
# decisión de compra de cervezas artesanales, siendo más
# relevantes atributos como el sabor"
# ------------------------------------------------------

summary(select(datos, Precio, Sabor))

datos %>%
  summarise(
    promedio_precio = mean(Precio, na.rm = TRUE),
    promedio_sabor = mean(Sabor, na.rm = TRUE)
  )

# Boxplot comparativo Precio vs. Sabor
datos_long <- datos %>%
  select(Precio, Sabor) %>%
  pivot_longer(cols = everything(), names_to = "atributo", values_to = "valor")

ggplot(datos_long, aes(x = atributo, y = valor, fill = atributo)) +
  geom_boxplot() +
  labs(title = "Comparación de importancia: Precio vs. Sabor")

# ------------------------------------------------------
# Hipótesis 2: "El sabor es el atributo más relevante en la
# compra de cerveza artesanal"
# ------------------------------------------------------

atributos <- datos %>%
  select(Sabor, Precio, variedad, diseno_envase, origen_maule) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  pivot_longer(everything(), names_to = "atributo", values_to = "promedio")

ggplot(atributos, aes(x = reorder(atributo, -promedio), y = promedio, fill = atributo)) +
  geom_col() +
  labs(title = "Importancia promedio de atributos en la compra", x = "Atributo", y = "Promedio")
print(arrange(atributos, desc(promedio)))

# ------------------------------------------------------
# Hipótesis 3: "El diseño del envase y el origen local del
# producto generan una percepción positiva que incrementa
# la intención de compra"
# ------------------------------------------------------

# Variable numérica de frecuencia de consumo (respeta el orden lógico)
datos <- datos %>%
  mutate(freq_num = case_when(
    `¿Con qué frecuencia consume cerveza artesanal?` == "Una vez al mes o menos" ~ 1,
    `¿Con qué frecuencia consume cerveza artesanal?` == "2-3 veces al mes" ~ 2,
    `¿Con qué frecuencia consume cerveza artesanal?` == "1 vez por semana" ~ 3,
    `¿Con qué frecuencia consume cerveza artesanal?` == "2-3 veces por semana" ~ 4,
    `¿Con qué frecuencia consume cerveza artesanal?` == "Todos los días" ~ 5
  ))

# Regresión lineal múltiple con interacciones
# Variable dependiente: recomienda_amigos (proxy de intención de compra)
modelo <- lm(recomienda_amigos ~ diseno_envase * Sabor + origen_maule * freq_num,
             data = datos)

summary(modelo)
