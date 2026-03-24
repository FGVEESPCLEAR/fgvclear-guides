# ============================================================
# Guia DID — FGV CLEAR
# Secao: DID com Multiplos Periodos (Diferencas de Medias e
#        Regressao com Dummies de Tempo)
# ============================================================

library(dplyr)
library(stargazer)
library(ggplot2)
library(lmtest)
library(sandwich)

df <- read.csv("base_MULT_did.csv")

# --- Diferencas de Medias ---

Bary_inf = c()
Bary_1 = c()
for(t in 2011:2020){
  Bary_inf[as.character(t)] = mean(df$y[df$d==0 & df$ano == t])
  Bary_1[as.character(t)] = mean(df$y[df$d==1 & df$ano == t])
}
round(Bary_inf, 3)
round(Bary_1, 3)

ATT = c()
for(t in 2012:2020){
  t = as.character(t)
  ATT[t] = (Bary_1[t] - Bary_1["2011"]) - (Bary_inf[t] - Bary_inf["2011"])
}
round(ATT, 3)

ggplot(data = data.frame(x=2012:2020, y=ATT), aes(x=x, y=y)) +
  geom_line() + geom_point() +
  geom_line(y = 0, linetype = "dashed") +
  ylim(-3, 1) + ylab("ATT") + xlab("Ano") +
  theme_classic()

mean(ATT)

# --- Regressao DID Simples ---

df <- df %>% mutate(Tt = ifelse(ano>=2012, 1, 0))
Reg_did <- lm(y ~ d*Tt, data = df)
cov1 <- sandwich::vcovHC(Reg_did, type = "HC0")
sd = sqrt(diag(cov1))
stargazer(Reg_did, type = "text", se = list(sd),
          title = "MQO com Erros Padrao Robustos")

# --- Regressao com Dummies de Tempo ---

df <- df %>% mutate(Tt = ifelse(ano >= 2012, 1, 0),
                    ano = as.factor(ano))
Reg_did <- lm(y ~ as.factor(d) + ano + ano:d:Tt, data = df)
cov1 <- sandwich::vcovHC(Reg_did, type = "HC0")
sd_robust = sqrt(diag(cov1))

ATT = Reg_did$coefficients[paste0("ano", 2012:2020, ":d:Tt")]

# ATT medio via Delta Method
wt = 1/9
Gamma = sum(wt*ATT)
Grad = matrix(c(rep(0, 12), rep(wt,8)), ncol = 1)
Sd_Gamma = sqrt(t(Grad)%*%cov1%*%Grad)
valor_t <- (Gamma)*sqrt(12000)/Sd_Gamma
gl <- Reg_did$df.residual
valor_p <- 2 * pt(abs(valor_t), df=gl, lower.tail=FALSE)
print(c(Gamma, Sd_Gamma, valor_p))

# Contraste longo prazo vs curto prazo
wt = c(rep(-1/4, 4), rep(1/4, 5))
Gamma = sum(wt*ATT)
Grad = matrix(c(rep(0, 12), wt), ncol = 1)
Sd_Gamma = sqrt(t(Grad)%*%cov1%*%Grad)
valor_t <- (Gamma)*sqrt(12000)/Sd_Gamma
gl <- Reg_did$df.residual
valor_p <- 2 * pt(abs(valor_t), df=gl, lower.tail=FALSE)
print(c(Gamma, Sd_Gamma, valor_p))
