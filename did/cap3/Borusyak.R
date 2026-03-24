# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)
library(stringr)

##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_stagger_did.csv")
head(df)



# PASSO 1 - estimar \lambda_i e \gamma entre as obs.não tratadas ---------------
##Criando o dataframe df0 que contém apenas obs. não tratadas
df$d_x_t = ifelse(df$ano <= df$G | df$G == 0, 0, 1)
df0 = df[df$d_x_t == 0,]

##Estimando a regressão
reg0 = lm(y ~ as.factor(ano) + as.factor(G) + escolaridade + populacao, 
          data = df0)

stargazer(reg0, title = "Passo 1", type = "text")




# PASSO 2 - obtendo predições de y(0) -------------------------------------
##Calculando y0 com o modelo anterior
df$y0_hat = predict(reg0, df)



# PASSO 3 - estimando \tau_{it} por imputação ----------------------------------
##Calculando Tau via imputation
df$tau = 0
df[df$d_x_t==1, 'tau'] = df[df$d_x_t==1, 'y'] - df[df$d_x_t==1, 'y0_hat']



# PASSO 4 - agregando os efeitos \tau_{it} -------------------------------------
v0 <- function(Z0, Z1, w){
  
  if(dim(Z0)[2] != dim(Z1)[2]) {
    print('ERROR: Z0 e Z1 precisam ter o mesmo número de colunas.')
    return('')
  }
  
  dim(Z0 %*% solve(t(Z0) %*% Z0))
  
  v0 = - Z0 %*% solve(t(Z0) %*% Z0) %*% t(Z1) %*% t(w)
  return(v0)
  
}

summarize_tau <- function(df, id_name, G_name, D_name, formula, restrict = FALSE){
  
  library(dplyr)
  names_var = names(df)
  
  for (var in c('tau', id_name, G_name, D_name)){
    if(!var %in% names_var){
      print(c('ERRO: df precisa conter', var))
      return('')
    }
  }
  
  df$G   = df[,G_name]
  df$id  = df[,id_name]
  df$D   = df[,D_name]
  
  df1 = df[df$D==1,]
  df0 = df[df$D==0,]
  
  # Calculando Tau
  df1$w = rep(1/length(df1$tau), length(df1$tau))
  w = matrix(df1$w, nrow = 1)
  tau_it = matrix(df1$tau, ncol = 1)
  
  TAU = w %*% tau_it
  
  #Calculando variância de Tau
  
  if(restrict){
    #Calculating tau_g
    df_sum <- df1 %>% group_by(id, G) %>% 
      summarise(w = sum(w),
                wtau = sum(w*tau))
    
    df_g <- df_sum %>% group_by(G) %>%
      summarise(numerador = sum(w*wtau),
                denominador = sum(w^2))
    
    df_g$tau_g = df_g$numerador/df_g$denominador
    
    df_res = merge(df, df_g[,c('G', 'tau_g')], by = 'G', all.x = T)
    df_res[is.na(df_res$tau_g), 'tau_g'] = 0
    df_res$res = df_res$y - df_res$y0_hat - df_res$d_x_t * df_res$tau_g
    
  } else {
    df_g = NULL
    df_res = df
    df_res$res = df_res$y - df_res$y0_hat - df_res$d_x_t * df_res$tau
    
  }
  
  #Calculando os pesos implícitos vit
  Z = model.matrix(formula, data = df)
  Z0 = Z[df$D == 0,]
  Z1 = Z[df$D == 1,]
  
  v = rep(NA, dim(Z)[1])
  
  v[df$D == 1] = w
  v[df$D == 0] = v0(Z0, Z1, w)
  
  df_res$v = v
  
  #Calculando a variância via eq 7 borusyak et al.
  
  #Clusterizando no tempo
  df_clustered = df_res %>% group_by(id, G) %>%
    summarise(v_e = sum(v*res))
  
  
  var = sum(df_clustered$v_e^2)
  dp = var^(1/2)
  
  t = sqrt(dim(df_clustered)[1]) * TAU/dp
  p_value = pnorm(abs(t), lower.tail = F)
  
  return(c(list(TAU=TAU, Sigma2 = var, Sigma = dp, t = t, p_value=p_value, df = list(df_input = df, df_res = df_res, df_clustered = df_clustered))))
  
}

RES = summarize_tau(df, 
                    id_name = 'id_municipio', 
                    G_name = 'G', 
                    D_name = "d_x_t", 
                    formula = y ~ as.factor(ano) + as.factor(G) + escolaridade + populacao,
                    restrict = TRUE)


TAU = str_pad(round(RES$TAU, 4), 8, side = 'both')
VAR = str_pad(round(RES$Sigma2, 4), 8, side = 'both')
t   = str_pad(round(RES$t, 2), 8, side = 'both')
P_v = str_pad(round(RES$p_value, 4), 8, side = 'both')

N1 = str_pad('TAU', 8, side = 'both')
N2 = str_pad('VAR', 8, side = 'both')
N3 = str_pad('t', 8, side = 'both')
N4 = str_pad('P-Valor', 8, side = 'both')

cat( N1, "|", N2, '|', N3, "|", N4,  "\n")
cat(TAU, "|", VAR, '|', t, "|", P_v,  "\n")





