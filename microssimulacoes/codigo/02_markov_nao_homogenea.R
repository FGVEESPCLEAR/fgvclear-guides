# ============================================================
# Guia Microssimulacoes — FGV CLEAR
# Secao: Cadeia de Markov Nao Homogenea
# ============================================================

states <- c("Saudavel", "Doente", "Hospitalizado")
alpha <- c(Saudavel = 0.6, Doente = 0.3, Hospitalizado = 0.1)

P1 <- matrix(c(
  0.8, 0.1, 0.1,
  0.2, 0.5, 0.3,
  0.1, 0.3, 0.6
), nrow = 3, byrow = TRUE, dimnames = list(states, states))

P2 <- matrix(c(
  0.7, 0.2, 0.1,
  0.3, 0.4, 0.3,
  0.2, 0.3, 0.5
), nrow = 3, byrow = TRUE, dimnames = list(states, states))

P3 <- matrix(c(
  0.6, 0.3, 0.1,
  0.4, 0.3, 0.3,
  0.3, 0.2, 0.5
), nrow = 3, byrow = TRUE, dimnames = list(states, states))

P4 <- matrix(c(
  0.5, 0.3, 0.2,
  0.5, 0.2, 0.3,
  0.4, 0.2, 0.4
), nrow = 3, byrow = TRUE, dimnames = list(states, states))

P5 <- matrix(c(
  0.4, 0.4, 0.2,
  0.6, 0.2, 0.2,
  0.5, 0.1, 0.4
), nrow = 3, byrow = TRUE, dimnames = list(states, states))

P_list <- list(P1, P2, P3, P4, P5)
n <- 5

set.seed(123)
X <- character(n + 1)

X[1] <- sample(states, 1, prob = alpha)
cat("Passo 0 (Estado inicial):", X[1], "\n")

for (i in 1:n) {
  current_state <- X[i]
  transition_prob <- P_list[[i]][current_state, ]
  X[i + 1] <- sample(states, 1, prob = transition_prob)
  cat("Passo", i, "com matriz P_", i, ":", X[i + 1], "\n")
}

cat("Sequencia final de estados:", X, "\n")
