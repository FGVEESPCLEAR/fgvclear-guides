# ============================================================
# Guia Microssimulacoes — FGV CLEAR
# Secao: Cadeia de Markov Homogenea (Simulacao de Saude)
# ============================================================

states <- c("Saudavel", "Doente", "Hospitalizado")

alpha <- c(Saudavel = 0.6, Doente = 0.3, Hospitalizado = 0.1)

P <- matrix(c(
  0.8, 0.1, 0.1,
  0.2, 0.5, 0.3,
  0.1, 0.3, 0.6
), nrow = 3, byrow = TRUE)

rownames(P) <- states
colnames(P) <- states

n <- 5

set.seed(123)
X <- character(n + 1)

X[1] <- sample(states, 1, prob = alpha)
cat("Passo 0 (Estado inicial):", X[1], "\n")

for (i in 2:(n + 1)) {
  current_state <- X[i - 1]
  transition_prob <- P[current_state, ]
  X[i] <- sample(states, 1, prob = transition_prob)
  cat("Passo", i-1, ":", X[i], "\n")
}

print(X)
