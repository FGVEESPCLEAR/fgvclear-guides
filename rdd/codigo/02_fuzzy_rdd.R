# ============================================================
# Guia RDD — FGV CLEAR
# Seção 4.3: Implementação Fuzzy RDD
# ============================================================

library(rdrobust)
library(AER)

# Fuzzy RDD: 'fuzzy' recebe o indicador de tratamento efetivo
rdd_fuzzy <- rdrobust(
  y        = df$freq_escolar,
  x        = df$x,
  fuzzy    = df$recebe_bolsa,   # tratamento efetivo (0/1)
  c        = 0,
  kernel   = "triangular",
  p        = 1,
  bwselect = "mserd"
)
summary(rdd_fuzzy)

# Verificacao do primeiro estagio (forca do instrumento)
h_otimo <- rdd_fuzzy$bws[1, 1]
df_jan  <- df[abs(df$x) <= h_otimo, ]

fs <- ivreg(freq_escolar ~ recebe_bolsa + x | elegivel + x,
            data = df_jan)
summary(fs, diagnostics = TRUE)
# F-stat > 10: instrumento forte (regra de bolso)
