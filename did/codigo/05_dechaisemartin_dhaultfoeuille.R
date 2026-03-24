# ============================================================
# Guia DID — FGV CLEAR
# Secao: de Chaisemartin & D Haultfoeuille — DIDmultiplegt
# ============================================================

rm(list=ls())
library(dplyr)
library(DIDmultiplegt)

df <- read.csv("base_stagger_did.csv")

# Efeito medio
did = did_multiplegt(
  df = df,
  Y = "y",
  G = "G",
  T = "ano",
  D = "d_x_t",
  controls = c("renda", "escolaridade", "populacao"),
  average_effect = TRUE
)
did

# Efeitos dinamicos e placebos
did_dynamic = did_multiplegt(
  df = df,
  Y = "y",
  G = "G",
  T = "ano",
  D = "d_x_t",
  controls = c("renda", "escolaridade", "populacao"),
  placebo = 6,
  dynamic = 8,
  brep = 2
)
