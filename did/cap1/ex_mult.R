# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)
library(lmtest)
library(sandwich)

##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_MULT_did.csv")


#Criando uma dummy (Tt) que indica se o ano da observação é maior ou igual a 2012
df <- df %>% mutate(Tt = ifelse(ano >= 2012, 1, 0))

#Estimando a regressão
Reg_did <- lm(y ~ d * Tt, data = df)

#Calculando erros padrões robustos a heteroscedasticidade e realizando testes de
#hipótese sobre os coeficientes
cov1 <- sandwich::vcovHC(Reg_did, type = "HC0")
sd = sqrt(diag(cov1))
stargazer(Reg_did, type = "latex", se = list(sd),
          title = "Regressão Linear com Erros Padrão Robustos")

