# ============================================================
# Guia DID — FGV CLEAR
# Secao: Pesos de Agregacao — Grupo, Periodo e Dinamico
# ============================================================

library(did)
library(dplyr)
library(ggplot2)

df <- read.csv("base_stagger_did.csv")

ATT_gt = att_gt(yname = "y", tname = "ano", idname = "id_municipio",
                gname = "G",
                xformla = ~ 1 + renda + populacao + escolaridade,
                data = df, control_group = "nevertreated",
                est_method = "dr")

G = ATT_gt$group
T = ATT_gt$t
att_gt_vals = round(ATT_gt$att, 3)

# --- Pesos por Grupo ---

w_g <- function(g, att_gt, G, T){
  W = rep(0, length(att_gt))
  W[G==g & T>=g] = 1
  W = W/sum(W)
  Gamma = W %*% att_gt
  return(list(w=W, Gamma = Gamma))
}

ATT_group = NULL
for(g in unique(G)){
  Grupo_g = w_g(g=g, G = G, T = T, att_gt = att_gt_vals)
  ATT_group = rbind(ATT_group, c(g, Grupo_g$Gamma))
}
colnames(ATT_group) <- c("g", "Gamma")
print(ATT_group)
did::aggte(ATT_gt, type = "group")

# --- Pesos por Periodo ---

w_t <- function(t, att_gt, G, T, df){
  W = rep(0, length(att_gt))
  W[G <= t & T == t] = 1
  for(g in unique(G)){
    N_g = length(df[df$ano==t & df$G == g, "id_municipio"])
    W[G == g] = W[G==g]*N_g
  }
  W = W/sum(W)
  Gamma = W %*% att_gt
  return(list(w=W, Gamma = Gamma))
}

ATT_period = NULL
for(tt in unique(T)){
  Periodo_t = w_t(t=tt, G = G, T = T, att_gt = att_gt_vals, df=df)
  ATT_period = rbind(ATT_period, c(tt, Periodo_t$Gamma))
}
colnames(ATT_period) <- c("t", "Gamma")
print(ATT_period)
did::aggte(ATT_gt, type = "calendar")

# --- Pesos Dinamicos (Event Study) ---

w_d <- function(d, att_gt, G, T, df){
  D = T - G
  W = rep(0, length(att_gt))
  W[D == d] = 1
  for(i in 1:length(D)){
    N_gt = length(df[df$G==G[i] & df$ano==T[i], "id_municipio"])
    W[i] = W[i]*N_gt
  }
  W = W/sum(W)
  Gamma = W %*% att_gt
  return(list(w=W, Gamma = Gamma))
}

ATT_dynamic = NULL
for(d in sort(unique(T-G))){
  Periodo_t = w_d(d=d, G = G, T = T, att_gt = att_gt_vals, df=df)
  ATT_dynamic = rbind(ATT_dynamic, c(d, Periodo_t$Gamma))
}
colnames(ATT_dynamic) <- c("d", "Gamma")
print(ATT_dynamic)
did::aggte(ATT_gt, type = "dynamic")

ggdid(aggte(ATT_gt, type = "dynamic"))
