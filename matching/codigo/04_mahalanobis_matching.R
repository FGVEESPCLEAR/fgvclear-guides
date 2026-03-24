# ============================================================
# Guia Matching — FGV CLEAR
# Secao 5: Pareamento por Distancia de Mahalanobis
# ============================================================

library(Matching)

covs <- c("age", "educ", "black", "hisp", "marr", "nodegree",
          "re74", "re75", "u74", "u75")

dat <- cps %>%
  dplyr::select(all_of(c("treat", "re78", covs))) %>%
  tidyr::drop_na()

Y  <- dat$re78
Tr <- dat$treat
X  <- as.matrix(dat[, covs])
S <- stats::cov(X[Tr == 0, , drop = FALSE])

run_match <- function(estimand, M) {
  out <- Match(Y = Y, Tr = Tr, X = X,
    Weight.matrix = S, M = M, replace = TRUE, estimand = estimand)
  tibble(estimand = estimand, M = M, estimate = out$est, se_AI = out$se)
}

grid <- tidyr::expand_grid(estimand = c("ATT", "ATE"), M = c(1, 3, 5))
results <- purrr::pmap_dfr(list(grid$estimand, grid$M), run_match)
print(results)
