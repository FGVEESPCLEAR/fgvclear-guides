rm(list = ls())
library(tidyverse)
library(dplyr)
#library(lfe)

set.seed(2023)

caminho = dirname(rstudioapi::getActiveDocumentContext()$path)
caminho = stringr::str_remove(caminho, "1 - Codigos")
caminho_base = stringr::str_remove(caminho, pattern = "5 - Empirico")
setwd(caminho)
getwd()
  
  # 1. Ler a base de dados -----------------------------------------------------------------------------------------
  df <- read.csv("base_final.csv")
  
  # teste <- function(i){
  #  library(dplyr)
  #  library(did)
    df <- df %>%
         mutate(aux = rnorm(n = nrow(df), mean = 10,sd=1),
        #        esc_aux = escolaridade-mean(escolaridade)/sd(escolaridade),
        #        esc_est = ifelse(id_estado %in% estados_seleciondos, 1, -1),
                aux = aux+20*mun_fe+ano_fe*ifelse(ano==2011, 1, 0)+escolaridade
                ) %>%
        group_by(id_municipio) %>%
        mutate(aux = mean(aux)) %>%
        ungroup() %>%
        mutate(aux = ntile(aux,100)) %>%
        group_by(id_municipio) %>%
        mutate(aux = max(aux)) %>%
        ungroup() %>%
        mutate(g   = case_when(aux > 80 ~ 1,
                               aux > 70 ~ 3,
                               aux > 55 ~ 5,
                               aux > 40 ~ 7,
                               TRUE ~ 0)) %>%
      dplyr::select(-aux)
    
     BETA <- matrix(0, nrow = 4, ncol = 9)
    
    # Preencha a matriz com os valores crescentes
    for (i in 1:4) {
      for (j in i:9) {
        BETA[i, j] <- ifelse(j >= 2*i -1, (j - 2*i) + 2,0)
      }
    }
     
    BETA = -BETA*0.2
    
    df[, "beta"] = 0
    for(i in 1:4){
      for(tt in 1:9){
        gg = seq(from = 1, to = 7, by =2)
        df[df$g==gg[i] & df$ano == 2011 + tt, "beta"] <- BETA[i, tt]
      }
    }
    
    df <- df %>%
          mutate(d = ifelse(g>0,1,0),
                 y = y+beta+0.5*d*mun_fe,
                 G = ifelse(g==0, 0, 2011+g),
                 Tt = ifelse(ano>=2012, 1, 0)) %>%
      dplyr::select(-beta, -ano_fe, -mun_fe, G, -g)
    
  #   reg = did::att_gt(yname = "y", tname = "ano",
  #               idname = "id_municipio",
  #               gname = "G", data = df
  #               )
  # 
  #     att <- did::aggte(reg, type = "dynamic")
  #     res = c(att$overall.att, att$att.egt)
  #     names(res) <- c("ATT", paste0("ATT_", -7:7))
  # 
  #   return(res)
  # }
  #   
  #  library(parallel)
  #  cl <- makeCluster(11)
  #  clusterExport(cl = cl, ls())
  #  A <- pbapply::pbsapply(1:1000, teste, cl = cl)
  #  stopCluster(cl)
  # 
  #  apply(A, 1, mean)
  
   # my_0 = c()
   # my_1 = c()
   # for(t in 2011:2020){
   #   
   #   my_0[as.character(t)] = mean(df$y[df$d==0 & df$ano == t])
   #   my_1[as.character(t)] = mean(df$y[df$d==1 & df$ano == t])
   #   
   # }
   # 
   # print(my_0)
   # print(my_1) 
    
df <- df %>% mutate(d_x_t = case_when(G == 0 ~ 0,
                                        ano >= G ~ 1,
                                        TRUE ~ 0))


prop.table(table(df$G))
prop.table(table(df$G, df$ano))
  
reg = lm(y ~ as.factor(G) + as.factor(ano) + d_x_t+ escolaridade, data = df)
 
attgt = did::att_gt(yname = 'y', tname = 'ano', idname = 'id_municipio', gname = 'G', xformla = ~escolaridade, data = df)
did::aggte(attgt, type = 'dynamic')
summary(reg)

write.csv(df,"base_stagger_did.csv",row.names = F)


