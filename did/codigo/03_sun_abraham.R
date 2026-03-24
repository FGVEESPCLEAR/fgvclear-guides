# ============================================================
# Guia DID — FGV CLEAR
# Secao: Sun & Abraham — Estimacao e Agregacao Manual
# ============================================================

rm(list=ls())
library(dplyr)
library(stringr)
library(lmtest)
library(sandwich)
library(stargazer)

df <- read.csv("base_stagger_did.csv")

# TWFE com interacoes grupo-tempo completas
reg_TWFE = lm(y ~ -1 + as.factor(G) + as.factor(ano)
  + d_x_t : as.factor(G):as.factor(ano) + escolaridade
  + populacao, data = df)
cov1 <- sandwich::vcovHC(reg_TWFE, type = "HC0")

# Extrair ATT(g,t)
nomes_betas = names(reg_TWFE$coefficients)
nomes_atts = nomes_betas[str_detect(nomes_betas, pattern = "d_x_t")]
ATT_gt = reg_TWFE$coefficients[nomes_atts]
ATT_gt = ATT_gt[!is.na(ATT_gt)]
grupo <- sub(".*\(G\)(\d{4}).*", "\1", names(ATT_gt))
ano <- sub(".*\(ano\)(\d{4}).*", "\1", names(ATT_gt))
names(ATT_gt) <- paste("ATT(", grupo, ",", ano, ")", sep = "")
ATT_gt

# --- Delta Method para Medias Ponderadas ---

delta_metodo = function(w, ATT_gt, VAR){
  W = matrix(w, ncol=1)
  Coef = t(W[17:40])%*%ATT_gt
  Grad = W
  VAR = t(Grad)%*%VAR%*%Grad
  dp = VAR^(1/2)
  t_value = (Coef)/dp
  p_value = 2*(1 - pnorm(abs(t_value)))
  res = c(Coef, dp, t_value, p_value)
  names(res) = c("Coef", "dp", "t", "P-Valor")
  return(res)
}

# Media simples
delta_metodo(w=c(rep(0,16),rep(1,24)/24), ATT_gt, cov1)

# --- Efeito por Periodo Calendario ---

ATT_Time = matrix(NA, nrow = length(2012:2020), ncol = 4)
rownames(ATT_Time) = 2012:2020
colnames(ATT_Time) = c("Coef", "sd", "t", "P-Valor")
for(tt in 2012:2020){
  time_att = str_sub(names(ATT_gt), start = 10, end = 13)
  weights = ifelse(time_att %in% as.character(tt), 1, 0)
  weights = weights/sum(weights)
  ATT_Time[as.character(tt),] = delta_metodo(w=c(rep(0,16),weights),
                                              ATT_gt, cov1)
}
stargazer(ATT_Time, title = "Time Effect")

# --- Efeito Dinamico (Event Study) ---

ATT_names = names(ATT_gt)
g = str_sub(ATT_names, start=5, end=8)
tt = str_sub(ATT_names, start=10, end=13)
d = as.numeric(tt) - as.numeric(g)
names(ATT_gt) = d

ATT_dynamic = matrix(NA, nrow = max(d)+1, ncol = 4)
rownames(ATT_dynamic) = unique(d)
colnames(ATT_dynamic) = c("Coef", "sd", "t", "P-Valor")
for(p in unique(d)){
  dynamic_att = names(ATT_gt)
  weights = ifelse(dynamic_att %in% as.character(d), 1, 0)
  weights = weights/sum(weights)
  ATT_dynamic[as.character(p),] = delta_metodo(w=c(rep(0,16),weights),
                                                ATT_gt, cov1)
}
stargazer(ATT_dynamic, title = "Dynamic effect")
