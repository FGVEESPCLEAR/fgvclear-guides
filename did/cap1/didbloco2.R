# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)
library(ggplot2)

##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_MULT_did.csv")


# Calculando as médias amostrais  -----------------------------------------
##Criando dois vetores para armazenar as médias de y para grupos tratado/controle
Bary_inf = c()
Bary_1 = c()

##Calcula as médias para cada grupo e período e armazena nos vetores criados
for(t in 2011:2020){
  
  Bary_inf[as.character(t)] = mean(df$y[df$d==0 & df$ano == t])
  Bary_1[as.character(t)] = mean(df$y[df$d==1 & df$ano == t])
  
}

##Visualizando as médias calculadas para cada período/grupo (com 3 casas decimais)
round(Bary_inf, 3)
round(Bary_1, 3)



# Calculando ATT(t) -------------------------------------------------------
##Criando vetor para armazenar os ATT(t)
ATT = c()

##Para cada t, estima ATT(t) e armazena no vetor ATT
for( t in 2012:2020){
  t = as.character(t)
  ATT[t] = (Bary_1[t] - Bary_1["2011"]) - (Bary_inf[t] - Bary_inf["2011"])
}

##Visualizando as estimativas
round(ATT, 3)



# Plotando ATT(t) ---------------------------------------------------------
ggplot(data = data.frame(x=2012:2020, y=ATT), aes(x=x, y=y)) + geom_line() + geom_point() + 
  geom_line(y = 0, linetype = "dashed") +
  ylim(-3, 1) + ylab("ATT") + xlab("Ano") +
  theme_classic()

##Média ponderada dos ATT(t)
mean(ATT)
