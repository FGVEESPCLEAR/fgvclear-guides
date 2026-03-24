# ============================================================
# Guia Microssimulacoes — FGV CLEAR
# Secao: Bolsa Familia — Avaliacao Ex-Ante (Contrafactual)
# ============================================================

# Criar uma copia da base para o cenario contrafactual
Base_contrafactual <- Base

# Aumentar o bf_valor em 200 apenas para quem tem bf == 1
Base_contrafactual$bf_valor <- ifelse(Base$bf == 1, Base$bf_valor + 200, Base$bf_valor)

# Prever probabilidades para o cenario atual
Base$prob_atual <- predict(logit_binomial, newdata = Base, type = "response")

# Prever probabilidades para o cenario contrafactual
Base$prob_contrafactual <- predict(logit_binomial, newdata = Base_contrafactual, type = "response")

# Calcular a diferenca media das probabilidades (apenas para bf == 1)
efeito_medio <- mean(
  na.omit(Base$prob_contrafactual[Base$bf == 1] - Base$prob_atual[Base$bf == 1])
)
cat("Efeito medio do aumento de R$200 no BF:", round(efeito_medio, 4), "\n")
