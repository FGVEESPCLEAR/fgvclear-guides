# ============================================================
# Guia MDE/Poder — FGV CLEAR
# Secao 5: Estratificacao (Block Randomization)
# ============================================================

rm(list=ls())
library(tidyverse)
library(randomizr)
library(lfe)

set.seed(42)
base_rct_block <- read.csv("Base/base_rct_block.csv")

se_block <- c(rep(NA, 100))

for (i in 1:100) {
  df <- base_rct_block %>%
    mutate(D = block_ra(blocks=id_mun, prob=0.5))
  reg_block <- felm(y~D|id_mun|0|id_escola,data=df)
  se_block[i] <- reg_block$se[1]
}

MDE_block = 2.8*mean(se_block)
print(MDE_block)
