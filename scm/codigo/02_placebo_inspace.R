# ============================================================
# Guia SCM — FGV CLEAR
# Seção 2.4: Testes Placebo In-Space
# ============================================================

library(Synth)

# Testes placebo in-space
# Loop sobre todas as unidades de controle
store <- matrix(NA, length(1970:2000), length(c(2, 4:39)))
colnames(store) <- c(2, 4:39)

for (i in c(2, 4:39)) {
  tryCatch({
    dataprep.placebo <- dataprep(
      foo = smoking,
      predictors = c("lnincome", "retprice", "age15to24"),
      predictors.op = "mean",
      dependent = "cigsale",
      unit.variable = "unit.num",
      time.variable = "year",
      treatment.identifier = i,
      controls.identifier = setdiff(c(2:39), i),
      time.predictors.prior = 1980:1988,
      time.optimize.ssr = 1980:1988,
      time.plot = 1970:2000
    )
    synth.placebo <- synth(dataprep.placebo)
    store[, as.character(i)] <-
      dataprep.placebo$Y1plot - (dataprep.placebo$Y0plot
        %*% synth.placebo$solution.w)
  }, error = function(e) { cat("Unidade", i, "falhou\n") })
}

# Gráfico: gaps da Califórnia (preto) vs placebos (cinza)
plot(1970:2000, store[, "3"], type = "l", lwd = 2,
     ylim = range(store, na.rm = TRUE),
     xlab = "Ano", ylab = "Gap (maços per capita)")
for (i in setdiff(colnames(store), "3")) {
  lines(1970:2000, store[, i], col = "grey70")
}
lines(1970:2000, store[, "3"], lwd = 2)  # Califórnia por cima
abline(v = 1988, lty = 2, col = "red")
abline(h = 0, lty = 3)
