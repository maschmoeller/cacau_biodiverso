# Step E5. Calculate linear rate of change of Condition indicator over time ----
library(tidyverse)
dir_out <- "./Results/"

stand_cond <- read_csv("Results/Stand_cond_Una.csv")

# Data from Step E4 (composite standardized Condition indicator)

dados_hist <- stand_cond %>%
  mutate(Ano = 2014:2023) %>%
  select(Ano, Condicao = stand_cond)

# Modeling 
modelo <- lm(Condicao ~ Ano, data = dados_hist)
saveRDS(modelo, "Results/model.RData")

# Model results
summary(modelo)

# Extracting estimated annual rate of change 

delta_C <- coef(modelo)[["Ano"]]

cat("ΔĈ (estimated annual rate of change ):", delta_C, "\n")

# Line graph
plot(Condicao ~ Ano, data = dados_hist, pch = 19, main = "Step E5: Linear Regression of Condition Indicator",
     xlab = "Time (years before the beginning)", ylab = "Condition Indicator")
abline(modelo, col = "blue", lwd = 2)

# Step E6. Set estimated crediting baseline ----

cred_base <- as.data.frame(delta_C)
format(cred_base$delta_C, scientific = F)
write_csv(cred_base, paste0(dir_out, "Credit_Baseline.csv"))


