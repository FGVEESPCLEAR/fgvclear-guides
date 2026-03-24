# ============================================================
# Guia DID — FGV CLEAR
# Secao: Borusyak, Jaravel & Spiess — Estimador de Imputacao
# ============================================================

rm(list=ls())
library(dplyr)
library(stargazer)
library(stringr)

df <- read.csv("base_stagger_did.csv")

# --- Passo 1: Estimar y(0) nos nao-tratados ---

df$d_x_t = ifelse(df$ano <= df$G | df$G == 0, 0, 1)
df0 = df[df$d_x_t == 0,]

reg0 = lm(y ~ as.factor(ano) + as.factor(G) + escolaridade + populacao,
          data = df0)

# --- Passo 2: Predizer contrafactual para todos ---

df$y0_hat = predict(reg0, df)

# --- Passo 3: Calcular tau individual ---

df$tau = 0
df[df$d_x_t==1, "tau"] = df[df$d_x_t==1, "y"] - df[df$d_x_t==1, "y0_hat"]

# --- Passo 4: Agregar com variancia clusterizada ---

v0 <- function(Z0, Z1, w){
  if(dim(Z0)[2] != dim(Z1)[2]) {
    print("ERROR: Z0 e Z1 precisam ter o mesmo numero de colunas.")
    return("")
  }
  v0 = - Z0 %*% solve(t(Z0) %*% Z0) %*% t(Z1) %*% t(w)
  return(v0)
}

summarize_tau <- function(df, id_name, G_name, D_name, formula, restrict = FALSE){
  df$D = df[[D_name]]
  df$id = df[[id_name]]
  df1 = df[df$D==1,]
  df0 = df[df$D==0,]
  df1$w = rep(1/length(df1$tau), length(df1$tau))
  w = matrix(df1$w, nrow = 1)
  tau_it = matrix(df1$tau, ncol = 1)
  TAU = w %*% tau_it

  if(restrict){
    df_sum <- df1 %>% group_by(id, G) %>% summarise(w = sum(w), wtau = sum(w*tau))
    df_g <- df_sum %>% group_by(G) %>% summarise(numerador = sum(w*wtau), denominador = sum(w^2))
    df_g$tau_g = df_g$numerador/df_g$denominador
    df_res = merge(df, df_g[,c("G", "tau_g")], by = "G", all.x = T)
    df_res[is.na(df_res$tau_g), "tau_g"] = 0
    df_res$res = df_res$y - df_res$y0_hat - df_res$d_x_t * df_res$tau_g
  } else {
    df_res = df
    df_res$res = df_res$y - df_res$y0_hat - df_res$d_x_t * as.numeric(TAU)
  }

  Z = model.matrix(formula, data = df)
  Z0 = Z[df$D == 0,]; Z1 = Z[df$D == 1,]
  v = rep(0, nrow(df))
  v[df$D == 1] = w; v[df$D == 0] = v0(Z0, Z1, w)

  df_res$v = v
  df_clustered = df_res %>% group_by(id, G) %>% summarise(v_e = sum(v*res))
  var = sum(df_clustered$v_e^2)
  dp = var^(1/2)
  t = sqrt(dim(df_clustered)[1]) * TAU/dp
  p_value = pnorm(abs(t), lower.tail = F)
  return(c(list(TAU=TAU, Sigma2 = var, Sigma = dp, t = t, p_value=p_value)))
}

RES = summarize_tau(df,
     id_name = "id_municipio",
     G_name = "G",
     D_name = "d_x_t",
     formula = y ~ as.factor(ano) + as.factor(G) + escolaridade + populacao,
     restrict = TRUE)

cat("TAU:", round(RES$TAU, 4),
    "| VAR:", round(RES$Sigma2, 4),
    "| t:", round(RES$t, 2),
    "| P-Valor:", round(RES$p_value, 4), "\n")
