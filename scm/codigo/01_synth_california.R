# ============================================================
# Guia SCM — FGV CLEAR
# Seção 2.3: Estimação com pacote Synth (Exemplo Califórnia)
# ============================================================

# Instalação e carregamento
install.packages("Synth")
library(Synth)

# Dados: vendas de cigarro per capita por estado, 1970-2000
# NOTA: O dataset "synth.data" do pacote Synth é um conjunto simulado
# para exemplos genéricos. Para replicar o exemplo da Califórnia
# (Proposição 99), use os dados disponíveis em:
#   https://web.stanford.edu/~jhain/synthpage.html
# Abaixo, assumimos que o dataset foi carregado como "smoking",
# que contém: state, year, cigsale, lnincome, beer, age15to24, retprice

# Preparação dos dados
dataprep.out <- dataprep(
  foo = smoking,
  predictors = c("lnincome", "retprice", "age15to24"),
  predictors.op = "mean",
  dependent = "cigsale",
  unit.variable = "unit.num",
  time.variable = "year",
  treatment.identifier = 3,         # California
  controls.identifier = c(2, 4:39), # demais estados
  time.predictors.prior = 1980:1988,
  time.optimize.ssr = 1980:1988,
  time.plot = 1970:2000
)

# Estimação dos pesos ótimos
synth.out <- synth(dataprep.out)

# Tabela de pesos: quais estados compõem a Califórnia Sintética?
synth.tables <- synth.tab(dataprep.res = dataprep.out,
                          synth.res = synth.out)
print(synth.tables$tab.w)  # pesos por estado
print(synth.tables$tab.v)  # pesos dos preditores (V)
print(synth.tables$tab.pred) # comparação de preditores

# Gráfico de trajetória (path plot)
path.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "Vendas de cigarro per capita (maços)",
          Xlab = "Ano",
          Legend = c("Califórnia", "Califórnia Sintética"),
          Legend.position = "bottomleft")
abline(v = 1988, lty = 2, col = "red")  # linha do tratamento

# Gap plot (efeito ao longo do tempo)
gaps.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "Gap (Califórnia - Sintética)",
          Xlab = "Ano")
abline(v = 1988, lty = 2, col = "red")
abline(h = 0, lty = 3)
