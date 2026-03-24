# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)
library(lmtest)
library(sandwich)

##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_MULT_did.csv")


##Criando as dummies: (Tt) que indica se o ano da observação >= a 2012
## e as dummies correspondentes a cada ano observado
df <- df %>% mutate(Tt = ifelse(ano >= 2012, 1, 0),
                   ano = as.factor(ano) #para criar automaticamente as Dummies
)

##Estimando a regressão
Reg_did <- lm(y ~ as.factor(d) + ano + ano:d:Tt, data = df)

##Estimando erros padrões robustos a heteroscedasticidade
cov1 <- sandwich::vcovHC(Reg_did, type = "HC0")
sd_robust = sqrt(diag(cov1))


##Extraindo os coeficientes relevantes para gerar a tabela de resultados
coef_names <- names(coef(Reg_did))
vars_to_include <- grep(paste0("ano\\d{4}:d:Tt"), coef_names, value = TRUE)


stargazer(Reg_did, type = "latex", se = list(sd_robust), 
          title = "Regressão Linear com Erros Padrão Robustos")

##Armazenando os ATTs num vetor
ATT = Reg_did$coefficients[paste0("ano", 2012:2020, ":d:Tt")]


# Agregando ATTs ----------------------------------------------------------
##Calculando uma média simples ("Gamma") dos ATTs
wt = 1/9 #(1/T)

Gamma = sum(wt*ATT)

##Calculado desvio padrão via Delta method
Grad = matrix(c(rep(0, 11), rep(wt,9)), ncol = 1)
Sd_Gamma = sqrt(t(Grad)%*%cov1%*%Grad)
##Calculando o p-valor
valor_t <- (Gamma)*sqrt(12000) /Sd_Gamma
gl <- Reg_did$df.residual
valor_p <- 2 * pt(abs(valor_t), df=gl, lower.tail=FALSE)

print(c("Gamma", "Sd", "P_valor"))
print(c(Gamma, Sd_Gamma, valor_p))


##Calculando estatística-teste para a hipótese de que os efeitos de curto prazo
##(4 primeiros períodos)são iguais aos de médio e longo ("Gamma" = 0)
wt = c(rep(-1/4, 4), rep(1/4,5))

Gamma = sum(wt*ATT)

##Calculado desvio padrão via Delta method
Grad = matrix(c(rep(0, 11), wt), ncol = 1)
Sd_Gamma = sqrt(t(Grad)%*%cov1%*%Grad)
##Calculando o p-valor
valor_t <- (Gamma)*sqrt(12000) /Sd_Gamma
gl <- Reg_did$df.residual
valor_p <- 2 * pt(abs(valor_t), df=gl, lower.tail=FALSE)

print(c("Gamma", "Sd", "P_valor"))
print(c(Gamma, Sd_Gamma, valor_p))

