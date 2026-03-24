# ============================================================
# Guia DID — FGV CLEAR
# Secao: Callaway & Sant Anna — Pacote did
# ============================================================

rm(list=ls())
library(dplyr)
library(did)
library(ggplot2)

df <- read.csv("base_stagger_did.csv")

# Estimar ATT(g,t) com metodo duplamente robusto
ATT_gt = att_gt(yname = "y",
                tname = "ano",
                idname = "id_municipio",
                gname = "G",
                xformla = ~ 1 + renda + populacao + escolaridade,
                data = df,
                control_group = "nevertreated",
                est_method = "dr")
ATT_gt

# Media simples dos ATTs
ATT_simples = aggte(ATT_gt, type = "simple")
ATT_simples

# Efeito medio por periodo calendario
att_t = aggte(ATT_gt, type = "calendar")
summary(att_t)
ggdid(att_t)

# Efeito dinamico (event study)
att_d = aggte(ATT_gt, type = "dynamic")
summary(att_d)
ggdid(att_d)
