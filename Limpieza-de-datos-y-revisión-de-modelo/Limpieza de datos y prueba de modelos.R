

library(readxl)
base_2 <- read_excel("base 2.xlsx")
View(base_2)


#Limpieza de datos

base_2$sexo[base_2$sexo == "1"] <- "Hombre"
base_2$sexo[base_2$sexo == "2"] <- "Mujer"
base_2$sexo <- ifelse(base_2$sexo == "Mujer", 1, 0)

base_2$ocup_form[base_2$ocup_form == "1"] <- "Formal"
base_2$ocup_form[base_2$ocup_form == "2"] <- "Informal"
base_2$ocup_form <- ifelse(base_2$ocup_form == "Informal", 1, 0)

base_2$categoria_ocupacion[base_2$categoria_ocupacion == "1"] <- "Empleador"
base_2$categoria_ocupacion[base_2$categoria_ocupacion == "2"] <- "Cuenta Propia"
base_2$categoria_ocupacion[base_2$categoria_ocupacion == "3"] <- "Sector privado"
base_2$categoria_ocupacion[base_2$categoria_ocupacion == "4"] <- "Sector público"
base_2$categoria_ocupacion[base_2$categoria_ocupacion == "5"] <- "Personal doméstico puertas afuera"
base_2$categoria_ocupacion[base_2$categoria_ocupacion == "6"] <- "Personal doméstico puertas adentro"



base_2$sexo <- as.factor(base_2$sexo)
base_2$ocup_form <- as.factor(base_2$ocup_form)
base_2$categoria_ocupacion <- as.factor(base_2$categoria_ocupacion)

base_2$edadsq <- (base_2$edad)^2


#Regresión

maxv <- glm(tpi ~ edad + edadsq + sexo + nivel + ocup_form + categoria_ocupacion, binomial(link = "probit"),
            data = base_2)
summary(maxv)
#------------------------------------
# MULTICOLINEALIDAD
#------------------------------------
library(car)
vif(maxv)
#------------------------------------
# MATRIZ DE CORRELACIONES
#------------------------------------
library(dplyr)
variables <- base_2[, c("tpi",
                        "edad",
                        "sexo",
                        "nivel",
                        "ocup_form",
                        "categoria_ocupacion",
                        "cae_general")]
variables_num <- variables %>%
  select(where(is.numeric))
cor(variables_num, use = "complete.obs")

#------------------------------------
# PRUEBA DE HETEROCEDASTICIDAD
#------------------------------------


library(lmtest)
bptest(maxv)



#------------------------------------
# PRUEBA DE AUTOCORRELACIÓN
#------------------------------------

dwtest(maxv)

#------------------------------------
# PRUEBA RESET DE RAMSEY
#------------------------------------

resettest(maxv)

#------------------------------------
# PRUEBA SHAPIRO-WILK
#------------------------------------

set.seed(123)
residuos <- sample(residuals(maxv), 5000)
shapiro.test(residuos)

#------------------------------------
# GRÁFICO Q-Q
#------------------------------------


qqnorm(residuals(maxv))
qqline(residuals(maxv), col = "red")

#------------------------------------
# HISTOGRAMA DE RESIDUOS
#------------------------------------

hist(residuals(maxv),
     main = "Histograma de los residuos",
     xlab = "Residuos")
#------------------------------------
# GRÁFICOS DE DIAGNÓSTICO
#------------------------------------

par(mfrow = c(2,2))
plot(maxv)

#------------------------------------
# CORRECCIÓN POR HETEROCEDASTICIDAD
#------------------------------------

library(sandwich)
library(lmtest)
coeftest(maxv, vcov = vcovHC(maxv, type = "HC1"))
