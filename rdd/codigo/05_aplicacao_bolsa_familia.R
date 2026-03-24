# ============================================================
# Guia RDD — FGV CLEAR
# Seção 6: Aplicação Empírica — Bolsa Família
# ============================================================

library(rdrobust)

# --- 6.3 Estrutura dos Dados Simulados ---

str(df)
# 'data.frame': 3000 obs. de 10 variaveis:
# $ id               : int   (identificador)
# $ renda_per_capita : num   (renda mensal per capita, R$)
# $ x                : num   (running variable: renda - 218)
# $ x2               : num   (running variable: renda - 109)
# $ elegivel         : int   (1 se renda <= 218)
# $ recebe_bolsa     : int   (1 se efetivamente beneficiario)
# $ freq_escolar     : num   (frequencia escolar, %)
# $ num_filhos       : int   (numero de filhos)
# $ escolaridade_resp: num   (anos de escolaridade do responsavel)
# $ area_urbana      : int   (1 se area urbana)

# --- 6.4.3 Múltiplos Cutoffs — Efeitos Heterogêneos ---

# Cutoff secundario: linha de extrema pobreza (R$109)
rdd_c2 <- rdrobust(
  y        = df$freq_escolar,
  x        = df$x2,          # running variable centralizada em R$109
  c        = 0,
  kernel   = "triangular",
  p        = 1,
  bwselect = "mserd"
)
summary(rdd_c2)
