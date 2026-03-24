# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)


##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_stagger_did.csv")


##Observando o tamanho de cada coorte
table(df$G, df$ano)

##Calculando e visualizando cada ATT(g,t)
All_G = sort(unique(df$G))[-1]
All_t = sort(unique(df$ano))[-1]

ATT <- matrix(ncol = length(All_G),
              nrow = length(All_t))

rownames(ATT) = All_t
colnames(ATT) = All_G

for(g in 1:length(All_G)){
  for(t in 1:length(All_t)){
    gg = All_G[g]
    tt = All_t[t]
    if(tt >= gg){
      ATT[t, g] = (mean(df$y[df$G==gg & df$ano == tt]) - mean(df$y[df$G==gg & df$ano == 2011])) - 
        (mean(df$y[df$G==0 & df$ano == tt]) - mean(df$y[df$G==0 & df$ano == 2011]))
    } 
  }
}

ATT
