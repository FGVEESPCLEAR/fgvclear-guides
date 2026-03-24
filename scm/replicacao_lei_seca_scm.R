###############################################################################
# Guia CLEAR - Controle Sintético (SCM)
# Replicação: Impacto da Lei Seca Brasileira sobre Mortalidade no Trânsito
#
# Dados: lei_seca_scm_data.csv (simulados com base em WHO/World Bank)
# Autores: FGV CLEAR
# Pacotes: Synth, augsynth, synthdid, ggplot2
###############################################################################

# ===========================================================================
# 0. INSTALAÇÃO DOS PACOTES
# ===========================================================================
install.packages(c("Synth", "augsynth", "synthdid", "ggplot2", "dplyr", "tidyr"))

library(Synth)
library(augsynth)
library(synthdid)
library(ggplot2)
library(dplyr)
library(tidyr)

# ===========================================================================
# 1. CARREGAR DADOS
# ===========================================================================
# Opção A: dados do arquivo CSV (acompanha o guia)
df <- read.csv("lei_seca_scm_data.csv")

# Opção B: baixar direto do World Bank (dados reais)
# library(WDI)
# traffic <- WDI(indicator = "SH.STA.TRAF.P5",
#                country = c("BR","AR","BO","CL","CO","CR","EC","GT",
#                            "HN","JM","MX","NI","PA","PY","PE","DO",
#                            "UY","VE"),
#                start = 2000, end = 2019)

# Verificar estrutura
str(df)
head(df)
table(df$iso2c)
table(df$year)

# Criar ID numérico para cada país (requerido pelo Synth)
df <- df %>%
  mutate(unit_num = as.numeric(factor(iso2c)))

cat("Brasil = unit_num", unique(df$unit_num[df$iso2c == "BR"]), "\n")

# ===========================================================================
# 2. SCM CLÁSSICO COM PACOTE Synth
# ===========================================================================
cat("\n========== SCM CLÁSSICO ==========\n")

br_id <- unique(df$unit_num[df$iso2c == "BR"])
control_ids <- unique(df$unit_num[df$iso2c != "BR"])

dataprep.out <- dataprep(
  foo = as.data.frame(df),
  predictors = c("gdp_pc_ppp", "vehicles_per_1000", "urban_pop_pct"),
  predictors.op = "mean",
  dependent = "mortality_traffic",
  unit.variable = "unit_num",
  time.variable = "year",
  treatment.identifier = br_id,
  controls.identifier = control_ids,
  time.predictors.prior = 2000:2007,
  time.optimize.ssr = 2000:2007,
  time.plot = 2000:2019
)

# Estimação
synth.out <- synth(dataprep.out)

# Tabelas de resultados
synth.tables <- synth.tab(dataprep.res = dataprep.out,
                          synth.res = synth.out)

cat("\n--- Pesos dos doadores ---\n")
print(round(synth.tables$tab.w[synth.tables$tab.w[,1] > 0.01, , drop=FALSE], 3))

cat("\n--- Comparação de preditores ---\n")
print(round(synth.tables$tab.pred, 2))

cat("\n--- RMSPE pré-tratamento ---\n")
pre_gaps <- dataprep.out$Y1plot[1:8] -
            (dataprep.out$Y0plot[1:8, ] %*% synth.out$solution.w)
rmspe_pre <- sqrt(mean(pre_gaps^2))
cat("RMSPE pré =", round(rmspe_pre, 3), "\n")

# Gráficos
pdf("fig_scm_path_plot.pdf", width = 10, height = 6)
path.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "Mortalidade no trânsito (por 100.000 hab.)",
          Xlab = "Ano",
          Legend = c("Brasil", "Brasil Sintético"),
          Legend.position = "topright")
abline(v = 2008, lty = 2, col = "red")
text(2008.5, max(dataprep.out$Y1plot)*0.95, "Lei Seca", col = "red", cex = 0.9)
dev.off()

pdf("fig_scm_gap_plot.pdf", width = 10, height = 6)
gaps.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "Gap (Brasil - Sintético)",
          Xlab = "Ano")
abline(v = 2008, lty = 2, col = "red")
abline(h = 0, lty = 3, col = "gray")
dev.off()

cat("\nGráficos salvos: fig_scm_path_plot.pdf, fig_scm_gap_plot.pdf\n")


# ===========================================================================
# 3. TESTES PLACEBO IN-SPACE
# ===========================================================================
cat("\n========== TESTES PLACEBO IN-SPACE ==========\n")

all_ids <- unique(df$unit_num)
store <- matrix(NA, length(2000:2019), length(all_ids))
colnames(store) <- all_ids

for (id in all_ids) {
  tryCatch({
    dp <- dataprep(
      foo = as.data.frame(df),
      predictors = c("gdp_pc_ppp", "vehicles_per_1000", "urban_pop_pct"),
      predictors.op = "mean",
      dependent = "mortality_traffic",
      unit.variable = "unit_num",
      time.variable = "year",
      treatment.identifier = id,
      controls.identifier = setdiff(all_ids, id),
      time.predictors.prior = 2000:2007,
      time.optimize.ssr = 2000:2007,
      time.plot = 2000:2019
    )
    so <- synth(dp, verbose = FALSE)
    store[, as.character(id)] <- dp$Y1plot - (dp$Y0plot %*% so$solution.w)
  }, error = function(e) {
    cat("  Unidade", id, "falhou:", conditionMessage(e), "\n")
  })
}

# Gráfico de placebos
pdf("fig_scm_placebos.pdf", width = 10, height = 6)
plot(2000:2019, store[, as.character(br_id)], type = "l", lwd = 3,
     ylim = range(store, na.rm = TRUE),
     xlab = "Ano", ylab = "Gap", main = "Testes Placebo In-Space")
for (id in setdiff(as.character(all_ids), as.character(br_id))) {
  if (!all(is.na(store[, id]))) {
    lines(2000:2019, store[, id], col = "grey70", lwd = 0.7)
  }
}
lines(2000:2019, store[, as.character(br_id)], lwd = 3, col = "black")
abline(v = 2008, lty = 2, col = "red")
abline(h = 0, lty = 3, col = "gray")
legend("bottomleft", "Brasil", lwd = 3, col = "black", bty = "n")
dev.off()

# Razão RMSPE e p-valor
rmspe_ratios <- sapply(as.character(all_ids), function(id) {
  gaps <- store[, id]
  if (all(is.na(gaps))) return(NA)
  pre <- gaps[1:8]
  post <- gaps[9:20]
  sqrt(mean(post^2, na.rm=TRUE)) / sqrt(mean(pre^2, na.rm=TRUE))
})

br_ratio <- rmspe_ratios[as.character(br_id)]
p_valor <- mean(rmspe_ratios >= br_ratio, na.rm = TRUE)
cat("Razão RMSPE Brasil:", round(br_ratio, 2), "\n")
cat("P-valor:", round(p_valor, 3), "\n")


# ===========================================================================
# 4. ASCM COM PACOTE augsynth
# ===========================================================================
cat("\n========== ASCM (Ridge) ==========\n")

# Formato long para augsynth
df_aug <- df %>%
  mutate(treated = ifelse(iso2c == "BR" & year >= 2008, 1, 0))

# ASCM com Ridge
ascm_fit <- augsynth(
  mortality_traffic ~ treated,
  unit = iso2c, time = year,
  data = df_aug,
  progfunc = "Ridge",
  scm = TRUE
)

cat("\n--- Summary ASCM ---\n")
print(summary(ascm_fit))

pdf("fig_ascm.pdf", width = 10, height = 6)
plot(ascm_fit)
dev.off()

# SCM puro para comparação
scm_pure <- augsynth(
  mortality_traffic ~ treated,
  unit = iso2c, time = year,
  data = df_aug,
  progfunc = "None",
  scm = TRUE
)

cat("\n--- Summary SCM puro ---\n")
print(summary(scm_pure))


# ===========================================================================
# 5. SYNTHETIC DiD COM PACOTE synthdid
# ===========================================================================
cat("\n========== SYNTHETIC DiD ==========\n")

# Preparar dados no formato synthdid
setup <- panel.matrices(df_aug,
                        unit = "iso2c",
                        time = "year",
                        outcome = "mortality_traffic",
                        treatment = "treated")

tau_sdid <- synthdid_estimate(setup$Y, setup$N0, setup$T0)
tau_sc   <- sc_estimate(setup$Y, setup$N0, setup$T0)
tau_did  <- did_estimate(setup$Y, setup$N0, setup$T0)

cat("\n--- Comparação dos estimadores ---\n")
cat("SDID:", round(tau_sdid, 2), "\n")
cat("SC:  ", round(tau_sc, 2), "\n")
cat("DiD: ", round(tau_did, 2), "\n")

# Erro padrão (placebo)
se_sdid <- sqrt(vcov(tau_sdid, method = "placebo"))
cat("SE(SDID):", round(se_sdid, 2), "\n")
cat("IC 95%: [", round(tau_sdid - 1.96*se_sdid, 2), ",",
    round(tau_sdid + 1.96*se_sdid, 2), "]\n")

pdf("fig_sdid.pdf", width = 10, height = 6)
synthdid_plot(tau_sdid)
dev.off()


# ===========================================================================
# 6. ANÁLISE DE SENSIBILIDADE: LEAVE-ONE-OUT
# ===========================================================================
cat("\n========== LEAVE-ONE-OUT ==========\n")

donors <- unique(df$iso2c[df$iso2c != "BR"])
loo_results <- data.frame(removed = character(), effect = numeric(),
                          stringsAsFactors = FALSE)

for (d in donors) {
  tryCatch({
    df_loo <- df_aug %>% filter(iso2c != d)
    fit_loo <- augsynth(
      mortality_traffic ~ treated,
      unit = iso2c, time = year,
      data = df_loo,
      progfunc = "Ridge", scm = TRUE
    )
    eff <- summary(fit_loo)$average_att$Estimate
    loo_results <- rbind(loo_results,
                         data.frame(removed = d, effect = round(eff, 2)))
  }, error = function(e) {
    cat("  LOO falhou para:", d, "\n")
  })
}

cat("\n--- Resultados Leave-One-Out ---\n")
print(loo_results)
cat("Range dos efeitos:", range(loo_results$effect), "\n")


# ===========================================================================
# 7. RESUMO FINAL
# ===========================================================================
cat("\n\n")
cat("==============================================================\n")
cat("  RESUMO: IMPACTO DA LEI SECA (2008) SOBRE MORTALIDADE\n")
cat("==============================================================\n")
cat("SCM Clássico (Synth):        RMSPE pré =", round(rmspe_pre, 2), "\n")
cat("ASCM Ridge (augsynth):       ATT =", round(summary(ascm_fit)$average_att$Estimate, 2), "\n")
cat("Synthetic DiD (synthdid):    ATT =", round(as.numeric(tau_sdid), 2), "\n")
cat("P-valor (placebos):         ", round(p_valor, 3), "\n")
cat("LOO range:                  [", min(loo_results$effect), ",", max(loo_results$effect), "]\n")
cat("==============================================================\n")
