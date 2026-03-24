# ============================================================
# Guia SCM — FGV CLEAR
# Seção 4.4: SCM e Machine Learning (CausalImpact / BSTS)
# Seção 5.2: Replicação Completa — Lei Seca Brasileira
# ============================================================

# --- CausalImpact (Google) - BSTS como alternativa ao SCM ---

install.packages("CausalImpact")
library(CausalImpact)

# Dados: série temporal do Brasil + séries de controle
# Formato: zoo object com colunas (tratado, controle1, controle2, ...)
impact <- CausalImpact(data, pre.period, post.period)
summary(impact)
plot(impact)
summary(impact, "report")  # relatório em texto

# --- Replicação: Lei Seca Brasileira ---

# 1. Carregar dados do World Bank (WDI)
install.packages("WDI")
library(WDI)
library(dplyr)

# Mortalidade no trânsito por 100k hab (SH.STA.TRAF.P5)
traffic <- WDI(indicator = "SH.STA.TRAF.P5",
               country = c("BR", "AR", "BO", "CL", "CO",
                           "CR", "EC", "GT", "HN", "JM",
                           "MX", "NI", "PA", "PY", "PE",
                           "DO", "SR", "UY", "VE"),
               start = 2000, end = 2019)

# Covariáveis
gdp <- WDI(indicator = "NY.GDP.PCAP.PP.KD",
            country = c("BR","AR","BO","CL","CO","CR",
                        "EC","GT","HN","JM","MX","NI",
                        "PA","PY","PE","DO","SR","UY","VE"),
            start = 2000, end = 2019)

# 2. Preparar painel
panel <- traffic %>%
  left_join(gdp, by = c("iso2c", "year")) %>%
  rename(mortality = SH.STA.TRAF.P5,
         gdp_pc = NY.GDP.PCAP.PP.KD) %>%
  mutate(treated = ifelse(iso2c == "BR" & year >= 2008, 1, 0))

# 3. SCM com Synth
library(Synth)
# [adaptar dataprep, synth, plots conforme seção 2.3]

# 4. ASCM com augsynth
library(augsynth)
ascm_brazil <- augsynth(
  mortality ~ treated,
  unit = country, time = year,
  data = panel,
  progfunc = "Ridge",
  scm = TRUE
)
summary(ascm_brazil)
plot(ascm_brazil)

# 5. SDID como robustez
library(synthdid)
# [adaptar panel.matrices e synthdid_estimate]
