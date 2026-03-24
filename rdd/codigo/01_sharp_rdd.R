# ============================================================
# Guia RDD — FGV CLEAR
# Seção 3.2: Estimação Sharp RDD com rdrobust
# Seção 3.4: Gráfico RDD
# ============================================================

install.packages(c("rdrobust", "rddensity", "ggplot2",
                   "dplyr", "patchwork", "AER"))
library(rdrobust); library(rddensity)

# Carregar dados (gerados por Cap_RDD_BolsaFamilia.R)
df <- read.csv("bolsafamilia_rdd.csv")

# Sharp RDD: x = renda_per_capita - 218 (elegivel quando x < 0)
rdd_sharp <- rdrobust(
  y        = df$freq_escolar,
  x        = df$x,
  c        = 0,              # cutoff na running variable centralizada
  kernel   = "triangular",  # kernel triangular (padrao)
  p        = 1,              # polinomio linear (Gelman-Imbens, 2019)
  bwselect = "mserd"         # bandwidth MSE-otimo (CCT, 2014)
)
summary(rdd_sharp)

# Grafico RDD com rdplot
rdplot(y = df$freq_escolar, x = df$x, c = 0,
       title = "Sharp RDD: Bolsa Familia",
       x.label = "Renda per capita centralizada (R$ - R$ 218)",
       y.label = "Frequencia escolar (%)")
