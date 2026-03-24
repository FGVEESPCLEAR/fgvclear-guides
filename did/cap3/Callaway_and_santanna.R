# Carregando pacotes necessários e base-----------------------------------------
##Se os pacotes não estiverem instalados, usar install.packages("pacote")
library(dplyr)
library(stargazer)
library(did)

##Carregando a base de dados: se o arquivo não estiver no diretório de trabalho,
##será necessário copiar o caminho do arquivo para a função read.csv
df <- read.csv("base_stagger_did.csv")
head(df)


# Rodando Callaway and Sant'Anna pelo método 'dr' -------------------------
ATT_gt = att_gt(yname = 'y', 
                tname = 'ano', 
                idname = 'id_municipio', 
                gname = 'G', 
                xformla = ~ 1 + renda + populacao + escolaridade,
                
                data = df, 
                control_group = 'nevertreated', 
                est_method = 'dr'
)

ATT_gt



# Média dos ATTs (ponderada pelo tamanho do grupo) ------------------------
ATT_simples = aggte(ATT_gt, type = 'simple')

ATT_simples



# Efeito médio por período -----------------------------------------------
att_t = aggte(ATT_gt, type = 'calendar')

summary(att_t)

ggdid(att_t)



# Efeito dinâmico ---------------------------------------------------------
att_d = aggte(ATT_gt, type = 'dynamic')

summary(att_d)

ggdid(att_d)
