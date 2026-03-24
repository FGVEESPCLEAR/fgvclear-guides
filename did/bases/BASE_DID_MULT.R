################################################################################

# Requerimentos #
#
# - Libraries instaladas:
#     tidyverse, dplyr
#   se preciso usar install.packages(<Nome_da_library>)
#
# - Base de dados na mesma pasta deste arquivo:
#     base_final.csv      
# - Pasta "Bases" na pasta onde "0 - Criando bases" está. 

# Função #
#
# Este código gera a base de dados 'base_MULT_did.csv' para ser usado nos 
# códigos:
#   - ...
# 

################################################################################


rm(list = ls())

########################
#  Subindo Libraries   #
########################

library(tidyverse)
library(dplyr)

########################
# Determinando Caminho #
########################

caminho = dirname(rstudioapi::getActiveDocumentContext()$path)
caminho_base = stringr::str_remove(caminho, pattern = "0 - Criando bases")
setwd(caminho)
getwd()

########################
#    Definindo seed    # 
########################

set.seed(2023)

########################
#     Criando BASE     # 
########################

# 1. Ler a base de dados -----------------------------------------------------------------------------------------
df <- read.csv("base_final.csv")

# SeleC'C#o no tratamento : municipios com escolaridade mais alta # 
estados_seleciondos = c(3,8,9)

 library(dplyr)
  df <- df %>%
       mutate(aux = rnorm(n = nrow(df), mean = 10,sd=1),
      #        esc_aux = escolaridade-mean(escolaridade)/sd(escolaridade),
      #        esc_est = ifelse(id_estado %in% estados_seleciondos, 1, -1),
             aux = aux+20*mun_fe+ano_fe*ifelse(ano==2011, 1, 0)) %>%
      group_by(id_municipio) %>%
      mutate(aux = mean(aux)) %>%
      ungroup() %>%
      mutate(aux = ntile(aux,100)) %>%
      group_by(id_municipio) %>%
      mutate(aux = max(aux)) %>%
      ungroup() %>%
      mutate(g   = case_when(aux > 40 ~ 1,
                             TRUE ~ 0)) %>%
    dplyr::select(-aux)
  
  BETA <- matrix(0, nrow = 1, ncol = 9)
  
  # Preencha a matriz com os valores crescentes
  for (i in 1:1) {
    for (j in i:9) {
      BETA[i, j] <- (j - i + 2)
    }
  }
  
  BETA = -BETA*0.25
  df[, "beta"] = 0
  for(gg in 1:1){
    for(tt in 1:9){
      df[df$g==gg & df$ano == 2011 + tt, "beta"] <- BETA[gg, tt]
    }
  }
  
  df <- df %>%
        mutate(d = g,
               y = y+beta+0.5*d*mun_fe,
               G = ifelse(g==0, 0, 2011+g),
               Tt = ifelse(ano>=2012, 1, 0)) %>%
    dplyr::select(-beta, -ano_fe, -mun_fe, -g, -G)

########################
#    Salvando BASE     # 
########################  
   
write.csv(df,paste0(caminho_base, "Bases/","base_MULT_did.csv"),row.names = F)


