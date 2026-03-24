# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)
library(lmtest)
library(sandwich)

##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_stagger_did.csv")

#CASO 3: TRATAMENTO HETEROGÊNEO EM TODAS AS DIMENSÕES
##TWFE regresssão
reg_TWFE = lm(y ~ as.factor(G) + as.factor(ano) + d_x_t + escolaridade + populacao, data = df)


##t-test Robusto
cov1 <- sandwich::vcovHC(reg_TWFE, type = "HC0")
sd_robust = sqrt(diag(cov1))

##Gere a tabela usando stargazer
stargazer(reg_TWFE, type = "latex", se = list(sd_robust),
          title = "OLS com Erros Padrao Robustos")
