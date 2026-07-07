# ============================================================
# Guia Matching — FGV CLEAR
# Secao 2: Setup e Preparacao dos Dados (NSW + CPS)
# ============================================================

rm(list = ls())

library(tidyverse)
library(haven)
library(sandwich)
library(lmtest)
library(estimatr)
library(modelsummary)
library(kableExtra)

baixar_dados <- function(dados) {
  link <- paste("https://github.com/scunning1975/mixtape/raw/master/",
                dados, sep = "")
  df <- read_dta(link)
  return(df)
}

nsw <- baixar_dados("nsw_mixtape.dta")

nsw <- nsw %>%
  mutate(
    agesq    = age^2,
    agecube  = age^3,
    educsq   = educ^2,
    u74      = case_when(re74 == 0 ~ 1, TRUE ~ 0),
    u75      = case_when(re75 == 0 ~ 1, TRUE ~ 0),
    re74sq   = re74^2,
    re75sq   = re75^2
  )
