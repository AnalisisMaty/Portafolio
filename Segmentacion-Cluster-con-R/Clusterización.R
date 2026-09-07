library(tidyverse)
library(cluster)
library(factoextra)
library(readr)

Datos <- read_csv("Resultados_encuesta_2.csv")
head(Datos)
colnames(Datos)

Datos_cluster <- Datos %>%
  select(
    Frecuencia_Visita = 7,
    Disposicion_Pagar = 11,
    Valoracion_precio = 30,
    Valoracion_calidad = 31,
    Valoracion_servicio = 32,
    Valoracion_ambiente = 33,
    Valoracion_ubicacion = 34,
    Residencia = 3,
    Edad = 21,
    Genero = 22,
    Motivacion = 27,
  )



norm_txt <- function(x) x %>% str_to_lower() %>% str_squish()

# --- Frecuencia de visita ---
frec_norm <- norm_txt(Datos_cluster$Frecuencia_Visita)

Datos_cluster$Frecuencia_visita_num <- case_when(
  frec_norm == "todos los días"                ~ 6,
  frec_norm %in% c("3 veces a la semana",
                   "3 veces por semana")       ~ 5,
  frec_norm %in% c("2 vez a la semana",
                   "2 veces a la semana",
                   "2 veces por semana")       ~ 4,
  frec_norm %in% c("1 vez a la semana",
                   "1 vez por semana")         ~ 3,
  frec_norm %in% c("cada dos semanas")          ~ 2.5,
  frec_norm %in% c("2 veces al mes",
                   "2 -3 veces al mes")        ~ 2,
  frec_norm %in% c("una vez al mes", "1 vez al mes",
                   "1 al mes", "1 ves al mes")  ~ 1,
  frec_norm == "1 vez cada dos o tres meses"    ~ 0.5,
  frec_norm == "1 vez al año"                   ~ 0.2,
  # Respuestas vagas / no cuantificables (no se pueden ordenar de
  # forma fiable en la escala) o que no llenaron el campo -> NA
  TRUE                                          ~ NA_real_
)

# --- Disposición a pagar (en pesos) ---
pago_norm <- Datos_cluster$Disposicion_Pagar %>% str_to_lower() %>% str_squish()

Datos_cluster$Disposicion_Pagar_num <- case_when(
  str_detect(pago_norm, "menos de \\$?\\s*5")        ~ 5000,
  str_detect(pago_norm, "^\\$?\\s*10\\.000")          ~ 10000,
  str_detect(pago_norm, "^\\$?\\s*15\\.000")          ~ 15000,
  str_detect(pago_norm, "más de \\$?\\s*20")          ~ 20000,
  pago_norm == "entre 5.000 y 10.000"                 ~ 7500,
  str_detect(pago_norm, "15mil a 20mil")              ~ 17500,
  TRUE                                                ~ NA_real_
)



likert <- function(x) {
  x_norm <- x %>% str_to_lower() %>% str_squish()
  case_when(
    x_norm == "muy alto" ~ 5,
    x_norm == "alto"     ~ 4,
    x_norm == "medio"    ~ 3,
    x_norm == "bajo"     ~ 2,
    x_norm == "muy bajo" ~ 1,
    TRUE                 ~ NA_real_
  )
}

Datos_cluster$Valoriacion_precio_num  <- likert(Datos_cluster$Valoracion_precio)
Datos_cluster$Valoracion_calidad_num  <- likert(Datos_cluster$Valoracion_calidad)
Datos_cluster$Valoracion_servicio_num <- likert(Datos_cluster$Valoracion_servicio)
Datos_cluster$Valoracion_ambiente_num <- likert(Datos_cluster$Valoracion_ambiente)
Datos_cluster$Valoracion_ubicacion_num <- likert(Datos_cluster$Valoracion_ubicacion)

# --- Residencia ---
resid_norm <- Datos_cluster$Residencia %>% str_to_lower() %>% str_squish()

Datos_cluster$Residencia_num <- case_when(
  str_detect(resid_norm, "constituci")  ~ 1,
  str_detect(resid_norm, "visitante")   ~ 0,   # cubre "visitante" y "visitantes"
  TRUE                                  ~ NA_real_
)

# --- Edad ---
datos_limpios_con_edad <- Datos_cluster %>%
  mutate(
    columna_Edad = Edad,
    Edad_limpia = columna_Edad %>%
      str_remove_all("[^0-9\\.]") %>%
      as.numeric() %>%
      floor()
  )

# --- Género ---
genero_norm <- datos_limpios_con_edad$Genero %>% str_to_lower() %>% str_squish()

datos_limpios_con_edad$Genero_num <- case_when(
  genero_norm == "masculino" ~ 0,
  genero_norm == "femenino"  ~ 1,
  # "Otro" y "Prefiero no decirlo" no encajan en una codificación
  # binaria 0/1 sin imponer un orden arbitrario -> se dejan como NA
  TRUE                       ~ NA_real_
)

# --- Motivación ---
# Se usa coincidencia por palabra clave (str_detect) en vez de
# comparación exacta, para capturar variantes con o sin espacio
# ("Relajarse/disfrutar" vs "Relajarse /disfrutar") y errores de
# tipeo menores ("Trabajar o estudie y regarse").
motiv_norm <- datos_limpios_con_edad$Motivacion %>% str_to_lower() %>% str_squish()

datos_limpios_con_edad$Motivacion_num <- case_when(
  str_detect(motiv_norm, "compartir")                    ~ 1,
  str_detect(motiv_norm, "trabajar|estudi")               ~ 2,
  str_detect(motiv_norm, "relajar|ambiente")               ~ 3,
  str_detect(motiv_norm, "probar")                        ~ 4,
  # Respuestas realmente idiosincráticas ("Tiempo de pareja",
  # "No vista", ".", etc.) no se pueden asignar de forma confiable
  # a ninguna de las 4 categorías -> NA
  TRUE                                                     ~ NA_real_
)

# Seleccionar solo las variables numéricas para el clustering
Datos_final <- datos_limpios_con_edad %>%
  select(Frecuencia_visita_num, Valoriacion_precio_num, Disposicion_Pagar_num, Valoracion_calidad_num, Valoracion_ambiente_num, Valoracion_ubicacion_num,
         Residencia_num, Edad_limpia, Genero_num, Motivacion_num, Valoracion_servicio_num)


n_antes <- nrow(Datos_final)
Datos_final <- na.omit(Datos_final)
cat("Observaciones antes de eliminar NA:", n_antes,
    "| después:", nrow(Datos_final),
    "| eliminadas:", n_antes - nrow(Datos_final), "\n")

Datos_escalados <- scale(Datos_final)
head(Datos_escalados)

fviz_nbclust(Datos_escalados, kmeans, method = "wss")

set.seed(123)
k_optimo <- 4
km_result_4 <- kmeans(Datos_escalados, centers = k_optimo, nstart = 25)

fviz_cluster(km_result_4, data = Datos_escalados,
             palette = "jco", # Una paleta de colores
             geom = "point",
             ellipse.type = "convex",
             ggtheme = theme_minimal(),
             main = "Clustering K-Means (k=4)"
)

Datos_caracterizacion <- Datos_final %>%
  mutate(Cluster = km_result_4$cluster)

# Analizar los promedios de cada variable por clúster
caracterizacion_cluster <- Datos_caracterizacion %>%
  group_by(Cluster) %>%
  summarise(
    N_Miembros = n(),
    Tamanio_Relativo = N_Miembros / nrow(Datos_caracterizacion) * 100,
    F_Visita_media = mean(Frecuencia_visita_num),
    V_precio_media = mean(Valoriacion_precio_num),
    V_servicio_media = mean(Valoracion_servicio_num),
    Dispo_pagar_media = mean(Disposicion_Pagar_num),
    V_calidad_media = mean(Valoracion_calidad_num),
    V_ambiente_media = mean(Valoracion_ambiente_num),
    V_ubicacion_media = mean(Valoracion_ubicacion_num),
    Residencia_media = mean(Residencia_num),
    Edad_media = mean(Edad_limpia),
    Genero = mean(Genero_num),
    Motivacion_num = mean(Motivacion_num)
  )

print(caracterizacion_cluster)

write_csv(
  Datos_caracterizacion,
  "Datos_Caracterizacion_FINAL.csv"
)

distancia_datos <- dist(Datos_escalados, method = "euclidean")
hc_resultado <- hclust(distancia_datos, method = "ward.D2")

fviz_dend(
  hc_resultado,
  k = 4,
  cex = 0.5,
  palette = "jco",
  rect = TRUE,
  main = "Dendograma de Clientes (Clustering Jerárquico)"
)
