# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(DIDmultiplegt)
library(DIDmultiplegtDYN)
  #ATENÇÃO: para usar esse pacote, pode ser necessário instalar o Java Development Kit (JDK)
  #https://www.oracle.com/java/technologies/downloads/
##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_stagger_did.csv")
head(df)


# Efeito médio ------------------------------------------------------------
did = did_multiplegt(
  mode = "old",
  df = df,
  Y = "y",
  G = "G",
  T = "ano",
  D = "d_x_t",
  controls = c("renda", "escolaridade", "populacao"),
  average_effect = T
)

did


# Efeito dinâmico ---------------------------------------------------------
did = did_multiplegt(
  mode = "old",
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
did

