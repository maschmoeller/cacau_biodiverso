# Step E7. Calculate dynamic crediting baseline ----

# Projecting for two years: 2024 = t=0, 2025 = t=1
t_futuro <- 2024:2025

# Loading model
modelo <- readRDS("Results/model.RData")

# Obtain intercept value
intercepto <- coef(modelo)[["(Intercept)"]]

# Future Credit Baseline
delta_C <- read_csv("Results/Credit_Baseline.csv")

C_futuro <- intercepto + delta_C$delta_C * t_futuro

# Results
anos_futuros <- 2024:2025

projecao <- data.frame(Ano = anos_futuros, t = t_futuro, Condicao_Projetada = C_futuro)

print(projecao)

# Calculating future cradit data ----

# Historic data dataframe
dados_hist <- tibble(
  Ano = 2014:2023,
  Condicao = stand_cond$stand_cond
)

# Future data dataframe
dados_fut <- tibble(Ano = 2024:2025)
dados_fut <- dados_fut %>%
  mutate(Condicao = predict(modelo, newdata = dados_fut))

# Combining historic and future dataframes
dados_completos <- bind_rows(
  dados_hist %>% mutate(Tipo = "Histórico"),
  dados_fut %>% mutate(Tipo = "Projeção")
)

t_tendencia <- tibble(Ano = 2014:2025)
linha_tendencia <- t_tendencia %>%
  mutate(Condicao = predict(modelo, newdata = t_tendencia))

# Graph ----
ggplot() +
  geom_point(data = dados_hist, aes(x = Ano, y = Condicao, color = "Historic"), size = 2) +
  geom_point(data = dados_fut, aes(x = Ano, y = Condicao, color = "Projection"), size = 3, shape = 17) +
  geom_line(data = linha_tendencia, aes(x = Ano, y = Condicao, color = "Trend"), linetype = "solid", linewidth = 1) +
  scale_color_manual(
    name = "Legend",
    values = c("Historic" = "black", "Projection" = "blue", "Trend" = "red")
  ) +
  labs(
    title = "Condition Indicator – historic and projection (Step E5–E7)",
    x = "Years",
    y = "Condition Indicator (Standardized)"
  ) +
  scale_x_continuous(breaks = 2014:2025) +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("Results/Credit_graph.jpeg")
