# ============================================================
# Guia Matching — FGV CLEAR
# Secao 5: Propensity Score — Estimacao e NN Matching
# ============================================================

library(Matching)
library(ggplot2)

covs <- c("age", "educ", "black", "hisp", "marr", "nodegree",
          "re74", "re75", "u74", "u75")

dat_ps <- cps %>%
  dplyr::select(all_of(c("treat", covs))) %>%
  tidyr::drop_na() %>%
  mutate(treat = as.integer(treat))

fml_ps <- as.formula(paste("treat ~", paste(covs, collapse = " + ")))
ps_model <- glm(fml_ps, data = dat_ps, family = binomial("logit"))

dat_ps <- dat_ps %>%
  mutate(pscore = predict(ps_model, type = "response"),
         grupo  = ifelse(treat == 1, "Tratados (NSW)", "Controles (CPS)"))

ggplot(dat_ps, aes(x = pscore)) +
  geom_histogram(bins = 40, alpha = 0.6) +
  facet_wrap(~grupo, ncol = 2, scales = "free_y") +
  labs(x = "Propensity score estimado: P(D=1 | X)", y = "Frequencia") +
  theme_classic()

# --- NN pelo Propensity Score ---

dat <- cps %>%
  dplyr::select(all_of(c("treat", "re78", covs))) %>%
  tidyr::drop_na() %>%
  mutate(treat = as.integer(treat))

ps_model <- glm(fml_ps, data = dat, family = binomial("logit"))
dat <- dat %>% mutate(pscore = predict(ps_model, type = "response"))

Y   <- dat$re78
Tr  <- dat$treat
Xps <- as.matrix(dat$pscore)

run_nn_ps <- function(M, estimand = c("ATT", "ATE")) {
  estimand <- match.arg(estimand)
  out <- Match(Y = Y, Tr = Tr, X = Xps,
               M = M, replace = TRUE, estimand = estimand)
  tibble(estimand = estimand, M = M, estimate = out$est, se_AI = out$se)
}

results_ps <- bind_rows(
  lapply(c(1, 3, 5), run_nn_ps, estimand = "ATT"),
  lapply(c(1, 3, 5), run_nn_ps, estimand = "ATE")
)
print(results_ps)
