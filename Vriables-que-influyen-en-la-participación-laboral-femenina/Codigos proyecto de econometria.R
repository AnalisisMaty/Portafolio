#librerias necesarias
library(dplyr)
library(tidyverse)
library(haven)
library(marginaleffects)

#La finalidad de la investigación, es ver las varibales que afectan a la inserción laboral de las mujeres,
#por lo que filtramos la base de datos unicamente por mujeres mayores de 17 años.

Base_de_datos_mujeres<- Base_de_datos_Casen_2022_STATA_18_marzo_2024 %>% filter(sexo == 2 & edad > 17 )

#Se prosigue a la posterior limpieza de datos, en el que ocupamos los comandos requeridos para cada variable

#Aquí volvemos dummy la nacionalidad
Base_de_datos_mujeres$r1a_dummy<- ifelse(Base_de_datos_mujeres$r1a == 3, 0, 1)

#Esta es la variable más importante, ya que será la variable dependiente que se usará en el modelo de regresión, la de participación laboral
Base_de_datos_mujeres$o1 <- ifelse(Base_de_datos_mujeres$o1 == 2, 0, 1)

#Transformamos a factor las regiones
Base_de_datos_mujeres$region<-as.factor(Base_de_datos_mujeres$region)

#Dejamos como referencia a la región metropolitana
Base_de_datos_mujeres$region <- relevel(Base_de_datos_mujeres$region, ref = "13")

#Calclulamos la edad al cuadrado para capturar su relación no lineal
Base_de_datos_mujeres$edad_squared <- (Base_de_datos_mujeres$edad)^2

#Se filtra el estado civil
Base_de_datos_mujeres$ecivil<- ifelse(Base_de_datos_mujeres$ecivil == 1, 1, 0)

#Tomamos unicamente las variables que nos importan
Base_de_datos_mujeres<-subset(Base_de_datos_mujeres, select=c( ecivil, edad, edad_squared, r1a_dummy, e6a, region, o1, tot_per_h))

#Se crea un modelo de regresión logistico binario
Modelo <- glm(o1 ~ ecivil + edad + edad_squared + r1a_dummy + e6a + region + tot_per_h, family = binomial("logit"), data = Base_de_datos_mujeres)

#Resultados del modelo
summary(Modelo)

#Vemos los efectos marginales para tener una comprensión más exacta de lo ocurrido
avg_slopes(Modelo)
