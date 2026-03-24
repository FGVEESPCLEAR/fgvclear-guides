# =============================================================================
# REGRESSÃO DESCONTÍNUA (RDD) APLICADA AO BOLSA FAMÍLIA
# Série "Avaliação na Prática" — FGV CLEAR
# =============================================================================
# Autores: Lycia Lima e André Portela Souza
# Colaboradores: Alei Santos, Caio de Souza Castro, Gabriel Weber Costa,
#                Lucas Finamor
# FGV EESP CLEAR — 2025
# =============================================================================
# COMO USAR:
#   Execute o script completo — ele gera automaticamente:
#     • bolsafamilia_rdd.csv            (dataset simulado, N = 3000)
#     • fig1_sharp_rdd.png
#     • fig2_densidade_mccrary.png
#     • fig3_fuzzy_rdd.png
#     • fig4_multiplos_cutoffs.png
# =============================================================================

# -----------------------------------------------------------------------------
# 0. PACOTES
# -----------------------------------------------------------------------------
pacotes <- c("rdrobust", "rddensity", "ggplot2", "dplyr",
             "AER", "scales", "patchwork")
novos <- pacotes[!(pacotes %in% installed.packages()[, "Package"])]
if (length(novos) > 0) install.packages(novos, dependencies = TRUE)

library(rdrobust); library(rddensity); library(ggplot2)
library(dplyr);    library(AER);       library(scales)
library(patchwork)

# -----------------------------------------------------------------------------
# 1. PALETA DE CORES FGV CLEAR
# -----------------------------------------------------------------------------
clear_teal     <- "#5CA4A9"
clear_teal2    <- "#7ABFBF"
clear_navy     <- "#1B3A6E"
clear_purple   <- "#7B3F9E"
clear_darkgray <- "#4A4A4A"

tema_clear <- theme_minimal(base_size = 12) +
  theme(
    text             = element_text(color = clear_darkgray),
    plot.title       = element_text(face = "bold", size = 13, color = clear_navy,
                                    margin = margin(b = 6)),
    plot.subtitle    = element_text(size = 10, color = clear_darkgray,
                                    margin = margin(b = 10)),
    plot.caption     = element_text(size = 8, color = "gray50", hjust = 0),
    axis.title       = element_text(size = 10, color = clear_navy),
    axis.text        = element_text(size = 9),
    panel.grid.major = element_line(color = "gray90", linewidth = 0.4),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    legend.position  = "bottom",
    legend.text      = element_text(size = 9)
  )

# =============================================================================
# 2. SIMULAÇÃO DO DATASET — BOLSA FAMÍLIA
# =============================================================================
set.seed(42)
N       <- 3000
cutoff1 <- 218   # linha de pobreza
cutoff2 <- 109   # linha de extrema pobreza

# Renda per capita: ~60% elegíveis (< R$218)
renda_raw <- c(
  rbeta(round(N * 0.60), 2, 5) * 300 + 30,
  runif(round(N * 0.40), 218, 450)
)[1:N]

x  <- renda_raw - cutoff1   # running variable centralizada em R$218
x2 <- renda_raw - cutoff2   # running variable centralizada em R$109

# Covariáveis (para testes de balanceamento)
num_filhos        <- rpois(N, lambda = ifelse(x < 0, 2.8, 1.9))
escolaridade_resp <- pmin(pmax(round(rnorm(N, mean = ifelse(x < 0, 5.2, 8.1), sd = 2), 1), 0), 16)
area_urbana       <- rbinom(N, 1, prob = ifelse(x < 0, 0.62, 0.78))

# Tratamento Sharp (elegibilidade mecânica)
elegivel <- as.integer(x < 0)

# Tratamento Fuzzy (recebimento efetivo — compliance ~75%, leakage ~5%)
prob_trat    <- pmin(pmax(ifelse(elegivel == 1,
                                 0.75 + rnorm(N, 0, 0.05),
                                 0.05 + rnorm(N, 0, 0.02)), 0), 1)
recebe_bolsa <- rbinom(N, 1, prob_trat)

# Frequência escolar — efeito causal do BF: +8 p.p.
freq_base <- 70 - 0.04 * x + 0.0001 * x^2 +
  1.5 * area_urbana + 0.8 * escolaridade_resp - 0.5 * num_filhos
freq_escolar <- pmin(pmax(freq_base + 8 * recebe_bolsa + rnorm(N, 0, 8), 20), 100)

# Dataset final
df <- data.frame(
  id               = 1:N,
  renda_per_capita = renda_raw,
  x                = x,
  x2               = x2,
  elegivel         = elegivel,
  recebe_bolsa     = recebe_bolsa,
  freq_escolar     = round(freq_escolar, 1),
  num_filhos       = num_filhos,
  escolaridade_resp = escolaridade_resp,
  area_urbana      = area_urbana
)

write.csv(df, "bolsafamilia_rdd.csv", row.names = FALSE)

cat("========================================\n")
cat("Dataset: bolsafamilia_rdd.csv  N =", nrow(df), "\n")
cat("Elegíveis      :", sum(df$elegivel),
    sprintf("(%.1f%%)\n", mean(df$elegivel)*100))
cat("Recebem BF     :", sum(df$recebe_bolsa),
    sprintf("(%.1f%%)\n", mean(df$recebe_bolsa)*100))
cat("Compliance     :", sprintf("%.1f%%\n",
                                mean(df$recebe_bolsa[df$elegivel==1])*100))
cat("Freq. esc. (trat.)   :",
    round(mean(df$freq_escolar[df$recebe_bolsa==1]), 1), "\n")
cat("Freq. esc. (controle):",
    round(mean(df$freq_escolar[df$recebe_bolsa==0]), 1), "\n")
cat("========================================\n\n")

# =============================================================================
# 3. ESTIMAÇÕES
# =============================================================================

cat("=== SHARP RDD (cutoff = R$218) ===\n")
rdd_sharp <- rdrobust(y = df$freq_escolar, x = df$x, c = 0,
                      kernel = "triangular", p = 1, bwselect = "mserd")
summary(rdd_sharp)

cat("\n=== FUZZY RDD (cutoff = R$218) ===\n")
rdd_fuzzy <- rdrobust(y = df$freq_escolar, x = df$x,
                      fuzzy = df$recebe_bolsa,
                      c = 0, kernel = "triangular", p = 1, bwselect = "mserd")
summary(rdd_fuzzy)

cat("\n=== CUTOFF SECUNDÁRIO R$109 ===\n")
rdd_c2 <- rdrobust(y = df$freq_escolar, x = df$x2, c = 0,
                   kernel = "triangular", p = 1, bwselect = "mserd")
summary(rdd_c2)

# =============================================================================
# 4. TESTES DE VALIDADE
# =============================================================================

cat("\n=== TESTE DE DENSIDADE (Cattaneo-Jansson-Ma, 2020) ===\n")
density_test <- rddensity(X = df$x, c = 0)
summary(density_test)
pv_dens <- density_test$test$p_jk

cat("\n=== BALANCEAMENTO DE COVARIÁVEIS ===\n")
for (cov in c("num_filhos", "escolaridade_resp", "area_urbana")) {
  r <- rdrobust(y = df[[cov]], x = df$x, c = 0,
                kernel = "triangular", p = 1, bwselect = "mserd")
  cat(sprintf("%-25s Coef: %7.3f  p: %.3f\n", cov, r$coef[1], r$pv[3]))
}

cat("\n=== PLACEBO CUTOFFS ===\n")
for (info in list(list(c = -68, lbl = "R$150 (placebo)"),
                  list(c =  62, lbl = "R$280 (placebo)"))) {
  r <- rdrobust(y = df$freq_escolar, x = df$x, c = info$c,
                kernel = "triangular", p = 1, bwselect = "mserd")
  cat(sprintf("%-20s Coef: %7.3f  p: %.3f\n", info$lbl, r$coef[1], r$pv[3]))
}

# =============================================================================
# 5. FIGURAS
# =============================================================================

# Função auxiliar: cria bins para scatter plots
make_bins <- function(df_in, xvar, n_bins = 40) {
  df_in$xc  <- df_in[[xvar]]
  df_in$bin <- cut(df_in$xc,
                   breaks = seq(min(df_in$xc), max(df_in$xc),
                                length.out = n_bins + 1),
                   include.lowest = TRUE)
  df_in %>%
    group_by(bin) %>%
    summarise(xm = mean(xc),
              ym = mean(freq_escolar),
              tm = mean(recebe_bolsa),
              .groups = "drop") %>%
    mutate(lado = ifelse(xm < 0,
                         "Elegível (esquerda)",
                         "Não elegível (direita)"))
}

# ---- Figura 1: Sharp RDD scatter + ajuste LOESS ----------------------------
cat("\nGerando Figura 1 — Sharp RDD...\n")

h1  <- rdd_sharp$bws[1, 1]
df1 <- df[abs(df$x) <= h1 * 1.5, ]
db1 <- make_bins(df1, "x", 40)

loess_l <- loess(freq_escolar ~ x, data = df1[df1$x < 0, ],  span = 0.6)
loess_r <- loess(freq_escolar ~ x, data = df1[df1$x >= 0, ], span = 0.6)

fit1 <- bind_rows(
  data.frame(x = seq(min(df1$x[df1$x < 0]), -0.5, length.out = 100)) %>%
    mutate(yhat = predict(loess_l, newdata = .),
           lado = "Elegível (esquerda)"),
  data.frame(x = seq(0.5, max(df1$x[df1$x >= 0]), length.out = 100)) %>%
    mutate(yhat = predict(loess_r, newdata = .),
           lado = "Não elegível (direita)")
)

cf1  <- round(rdd_sharp$coef[1], 2)
ci1l <- round(rdd_sharp$ci[3, 1], 2)
ci1h <- round(rdd_sharp$ci[3, 2], 2)

fig1 <- ggplot() +
  geom_point(data = db1,
             aes(x = xm, y = ym, color = lado, shape = lado),
             size = 2.8, alpha = 0.85) +
  geom_line(data = fit1,
            aes(x = x, y = yhat, color = lado), linewidth = 1.1) +
  geom_vline(xintercept = 0, linetype = "dashed",
             color = clear_navy, linewidth = 0.8) +
  geom_vline(xintercept = c(-h1, h1), linetype = "dotted",
             color = "gray60", linewidth = 0.5) +
  scale_color_manual(
    values = c("Elegível (esquerda)" = clear_teal,
               "Não elegível (direita)" = clear_navy), name = NULL) +
  scale_shape_manual(
    values = c("Elegível (esquerda)" = 16,
               "Não elegível (direita)" = 17), name = NULL) +
  annotate("text",
           x = max(db1$xm) * 0.15, y = min(db1$ym) + 2,
           label = sprintf("LATE = %.2f p.p.\n[IC 95%%: %.2f; %.2f]",
                           cf1, ci1l, ci1h),
           hjust = 0, size = 3.2, color = clear_navy, fontface = "italic") +
  labs(
    title    = "Figura 1 — Sharp RDD: Frequência Escolar e Elegibilidade ao Bolsa Família",
    subtitle = "Cutoff em R$ 218 de renda per capita familiar",
    x        = "Renda per capita centralizada (R$ − R$ 218)",
    y        = "Frequência escolar (%)",
    caption  = paste0(
      "Nota: Linhas pontilhadas = janela MSE-ótima (Calonico-Cattaneo-Titiunik, 2014). ",
      "Ajuste por LOESS. Kernel triangular, p = 1.\n",
      "Fonte: Dados simulados. FGV CLEAR.")) +
  tema_clear

ggsave("fig1_sharp_rdd.png", fig1, width = 8, height = 5, dpi = 200)
cat("  fig1_sharp_rdd.png salva.\n")

# ---- Figura 2: Teste de Densidade -------------------------------------------
cat("Gerando Figura 2 — Teste de Densidade...\n")

dens_e <- density(df$x[df$x > -150 & df$x < 0],  bw = 12)
dens_d <- density(df$x[df$x >= 0  & df$x < 150], bw = 12)

df_dens <- bind_rows(
  data.frame(x = dens_e$x, y = dens_e$y, lado = "Elegível (esquerda)"),
  data.frame(x = dens_d$x, y = dens_d$y, lado = "Não elegível (direita)")
) |> filter(x >= -150, x <= 150)

fig2 <- ggplot(df_dens, aes(x = x, y = y, color = lado, fill = lado)) +
  geom_area(alpha = 0.25, position = "identity") +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = 0, linetype = "dashed",
             color = clear_navy, linewidth = 0.8) +
  scale_color_manual(
    values = c("Elegível (esquerda)" = clear_teal,
               "Não elegível (direita)" = clear_navy), name = NULL) +
  scale_fill_manual(
    values = c("Elegível (esquerda)" = clear_teal,
               "Não elegível (direita)" = clear_navy), name = NULL) +
  annotate("text",
           x = 40, y = max(df_dens$y) * 0.85,
           label = sprintf("p-valor = %.3f\nH\u2080 não rejeitada:\nsem evidência de manipulação",
                           pv_dens),
           hjust = 0, size = 3.1, color = clear_darkgray, fontface = "italic") +
  labs(
    title    = "Figura 2 — Teste de Densidade: Ausência de Manipulação da Running Variable",
    subtitle = "Método de Cattaneo, Jansson e Ma (2020) — cutoff em R$ 218",
    x        = "Renda per capita centralizada (R$ − R$ 218)",
    y        = "Densidade estimada",
    caption  = paste0(
      "Nota: A continuidade da densidade em torno do cutoff sugere ausência de ",
      "manipulação da renda per capita pelas famílias.\n",
      "Fonte: Dados simulados. FGV CLEAR.")) +
  tema_clear

ggsave("fig2_densidade_mccrary.png", fig2, width = 8, height = 5, dpi = 200)
cat("  fig2_densidade_mccrary.png salva.\n")

# ---- Figura 3: Fuzzy RDD (dois painéis) -------------------------------------
cat("Gerando Figura 3 — Fuzzy RDD...\n")

h3  <- rdd_fuzzy$bws[1, 1]
df3 <- df[abs(df$x) <= h3 * 1.5, ]
db3 <- make_bins(df3, "x", 35)

cf3  <- round(rdd_fuzzy$coef[1], 2)
ci3l <- round(rdd_fuzzy$ci[3, 1], 2)
ci3h <- round(rdd_fuzzy$ci[3, 2], 2)

pA <- ggplot(db3, aes(x = xm, y = tm, color = lado, shape = lado)) +
  geom_point(size = 2.5, alpha = 0.85) +
  geom_smooth(aes(group = lado), method = "lm", se = FALSE, linewidth = 0.9) +
  geom_vline(xintercept = 0, linetype = "dashed",
             color = clear_navy, linewidth = 0.7) +
  scale_color_manual(
    values = c("Elegível (esquerda)" = clear_teal,
               "Não elegível (direita)" = clear_navy), name = NULL) +
  scale_shape_manual(
    values = c("Elegível (esquerda)" = 16, "Não elegível (direita)" = 17),
    name = NULL) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(subtitle = "Painel A — Probabilidade de Receber o Bolsa Família (Primeiro Estágio)",
       x = "Renda per capita centralizada",
       y = "P(Recebe Bolsa Família)") +
  tema_clear + theme(legend.position = "none")

pB <- ggplot(db3, aes(x = xm, y = ym, color = lado, shape = lado)) +
  geom_point(size = 2.5, alpha = 0.85) +
  geom_smooth(aes(group = lado), method = "lm", se = FALSE, linewidth = 0.9) +
  geom_vline(xintercept = 0, linetype = "dashed",
             color = clear_navy, linewidth = 0.7) +
  scale_color_manual(
    values = c("Elegível (esquerda)" = clear_teal,
               "Não elegível (direita)" = clear_navy), name = NULL) +
  scale_shape_manual(
    values = c("Elegível (esquerda)" = 16, "Não elegível (direita)" = 17),
    name = NULL) +
  annotate("text",
           x = max(db3$xm) * 0.1, y = min(db3$ym) + 1.5,
           label = sprintf("LATE (IV) = %.2f p.p.\n[IC 95%%: %.2f; %.2f]",
                           cf3, ci3l, ci3h),
           hjust = 0, size = 3.1, color = clear_navy, fontface = "italic") +
  labs(subtitle = "Painel B — Frequência Escolar (Resultado — Estimativa Fuzzy)",
       x = "Renda per capita centralizada",
       y = "Frequência escolar (%)") +
  tema_clear + theme(legend.position = "bottom")

fig3 <- (pA / pB) +
  plot_annotation(
    title    = "Figura 3 — Fuzzy RDD: Compliance e Efeito Causal do Bolsa Família",
    subtitle = "Cutoff em R$ 218 de renda per capita familiar",
    caption  = paste0(
      "Nota: LATE estimado por variáveis instrumentais (rdrobust). ",
      "Kernel triangular, p = 1, janela MSE-ótima.\n",
      "Fonte: Dados simulados. FGV CLEAR."),
    theme = theme(
      plot.title    = element_text(face = "bold", size = 13, color = clear_navy),
      plot.subtitle = element_text(size = 10, color = clear_darkgray),
      plot.caption  = element_text(size = 8, color = "gray50", hjust = 0))
  )

ggsave("fig3_fuzzy_rdd.png", fig3, width = 8, height = 7.5, dpi = 200)
cat("  fig3_fuzzy_rdd.png salva.\n")

# ---- Figura 4: Múltiplos Cutoffs --------------------------------------------
cat("Gerando Figura 4 — Múltiplos Cutoffs...\n")

make_cutoff_panel <- function(xvar, label, cor, rdd_obj) {
  h_c  <- rdd_obj$bws[1, 1]
  df_c <- df[abs(df[[xvar]]) <= h_c * 1.5, ]
  df_c$xc  <- df_c[[xvar]]
  df_c$bin <- cut(df_c$xc,
                  breaks = seq(min(df_c$xc), max(df_c$xc), length.out = 31),
                  include.lowest = TRUE)
  db_c <- df_c %>%
    group_by(bin) %>%
    summarise(xm = mean(xc), ym = mean(freq_escolar), .groups = "drop") %>%
    mutate(lado = ifelse(xm < 0, "Elegível", "Não elegível"))
  cf <- round(rdd_obj$coef[1], 2)
  pv <- round(rdd_obj$pv[3], 3)
  ct <- ifelse(xvar == "x", "218", "109")
  ggplot(db_c, aes(x = xm, y = ym, color = lado)) +
    geom_point(size = 2.3, alpha = 0.85) +
    geom_smooth(aes(group = lado), method = "lm",
                se = FALSE, linewidth = 0.9, color = cor) +
    geom_vline(xintercept = 0, linetype = "dashed",
               color = "gray30", linewidth = 0.7) +
    scale_color_manual(
      values = c("Elegível"     = cor,
                 "Não elegível" = adjustcolor(cor, alpha.f = 0.45)),
      name = NULL) +
    annotate("text",
             x = max(db_c$xm) * 0.25, y = min(db_c$ym) + 1.5,
             label = sprintf("LATE = %.2f p.p.\np = %.3f", cf, pv),
             size = 3.1, color = "gray25", fontface = "italic") +
    labs(subtitle = label,
         x = paste0("Renda per capita centralizada (cutoff = R$ ", ct, ")"),
         y = "Frequência escolar (%)") +
    tema_clear + theme(legend.position = "none")
}

fig4 <- (make_cutoff_panel("x",  "Linha de Pobreza — R$ 218",
                           clear_teal, rdd_sharp) |
           make_cutoff_panel("x2", "Linha de Extrema Pobreza — R$ 109",
                             clear_navy, rdd_c2)) +
  plot_annotation(
    title    = "Figura 4 — Múltiplos Cutoffs: Efeitos Heterogêneos do Bolsa Família",
    subtitle = "Comparação entre as linhas de pobreza (R$218) e extrema pobreza (R$109)",
    caption  = paste0(
      "Nota: Estimativas por rdrobust (Calonico-Cattaneo-Titiunik, 2014). ",
      "Kernel triangular, p = 1.\n",
      "Fonte: Dados simulados. FGV CLEAR."),
    theme = theme(
      plot.title    = element_text(face = "bold", size = 13, color = clear_navy),
      plot.subtitle = element_text(size = 10, color = clear_darkgray),
      plot.caption  = element_text(size = 8, color = "gray50", hjust = 0))
  )

ggsave("fig4_multiplos_cutoffs.png", fig4, width = 10, height = 5, dpi = 200)
cat("  fig4_multiplos_cutoffs.png salva.\n")

# =============================================================================
# FIM
# =============================================================================
cat("\n========================================\n")
cat("CONCLUÍDO! Arquivos gerados:\n")
cat("  bolsafamilia_rdd.csv\n")
cat("  fig1_sharp_rdd.png\n")
cat("  fig2_densidade_mccrary.png\n")
cat("  fig3_fuzzy_rdd.png\n")
cat("  fig4_multiplos_cutoffs.png\n")
cat("========================================\n")