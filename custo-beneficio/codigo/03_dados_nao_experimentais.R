# ============================================================
# Guia Matching — FGV CLEAR
# Secao 2: Vies de Selecao com Dados Nao-Experimentais (CPS)
# ============================================================

library(estimatr)

cps <- baixar_dados("cps_mixtape.dta")
nsw_treat <- nsw %>% filter(treat == 1)

cps <- cps %>%
  bind_rows(nsw_treat) %>%
  mutate(
    agesq   = age^2,
    agecube = age^3,
    educsq  = educ * educ,
    u74     = case_when(re74 == 0 ~ 1, TRUE ~ 0),
    u75     = case_when(re75 == 0 ~ 1, TRUE ~ 0),
    re74sq  = re74^2,
    re75sq  = re75^2
  )

fit_nswcps <- lm_robust(re78 ~ treat, se_type = "stata", data = cps)
summary(fit_nswcps)

fit_nsw_cov <- lm_robust(re78 ~ treat + age + agesq + educ + nodegree +
                           marr + black + hisp + re74 + re75 + u74 + u75,
                         se_type = "stata", data = nsw)

fit_nsw_lin <- lm_lin(re78 ~ treat,
                      covariates = ~ age + agesq + educ + nodegree +
                                    marr + black + hisp + re74 + re75 + u74 + u75,
                      se_type = "stata", data = nsw)

fit_nswcps_cov <- lm_robust(re78 ~ treat + age + agesq + educ + nodegree +
                              marr + black + hisp + re74 + re75 + u74 + u75,
                            se_type = "stata", data = cps)

fit_nswcps_lin <- lm_lin(re78 ~ treat,
                         covariates = ~ age + agesq + educ + nodegree +
                                       marr + black + hisp + re74 + re75 + u74 + u75,
                         se_type = "stata", data = cps)
