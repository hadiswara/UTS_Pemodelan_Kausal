if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# 1. Install dependencies dari Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", ask = FALSE, update = FALSE)
if (!require("graph")) BiocManager::install("graph", update = FALSE, ask = FALSE)
if (!require("RBGL")) BiocManager::install("RBGL", update = FALSE, ask = FALSE)
if (!require("Rgraphviz")) BiocManager::install("Rgraphviz", update = FALSE, ask = FALSE)

# 2. Install pcalg dan causaldata dari CRAN
if (!require("causaldata")) install.packages("causaldata", ask = FALSE, update = FALSE)
if (!require("pcalg")) install.packages("pcalg", dependencies = TRUE, ask = FALSE, update = FALSE)

library(causaldata)
library(pcalg)

data("abortion")

# Preprocessing: mengambil subset data numerik
df_numeric <- na.omit(abortion[, sapply(abortion, is.numeric)])
df_subset <- df_numeric[, 1:min(10, ncol(df_numeric))]
V <- colnames(df_subset)

# Mendefinisikan sufficient statistics
suffStat <- list(C = cor(df_subset), n = nrow(df_subset))

# 1. PC Algorithm
pc_fit <- pc(suffStat = suffStat, indepTest = gaussCItest, 
             alpha = 0.05, labels = V, verbose = FALSE)

pdf("Output_PC_Algorithm.pdf", width = 8, height = 8)
plot(pc_fit, main = "Estimasi Kausal - PC Algorithm")
dev.off()

png("Output_PC_Algorithm.png", width = 800, height = 800, res = 100)
plot(pc_fit, main = "Estimasi Kausal - PC Algorithm")
dev.off()

# 2. GES Algorithm (BIC score / L0-penalized)
score <- new("GaussL0penObsScore", as.matrix(df_subset))
ges_fit <- ges(score)

pdf("Output_GES_Algorithm.pdf", width = 8, height = 8)
plot(ges_fit$essgraph, main = "Estimasi Kausal - GES Algorithm")
dev.off()

png("Output_GES_Algorithm.png", width = 800, height = 800, res = 100)
plot(ges_fit$essgraph, main = "Estimasi Kausal - GES Algorithm")
dev.off()

print("Eksekusi PC Algorithm dan GES selesai. File PDF dan PNG berhasil dibuat.")
