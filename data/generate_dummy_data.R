library(prodlim)
library(survival)
library(riskRegression)

# load model object to get coefficients
coefs <- readRDS("../models/final_FGR_clean.rds")$crrFit$coef
form <- readRDS("../models/final_FGR_clean.rds")$form
#print(coefs)

set.seed(99)

n <- 1000  # number of dummy observations

# Example covariates
dummy_data <- data.frame(
  patient_id = seq(1, n, 1),
  age = rnorm(n, mean = 70, sd = 15),
  sex_f = as.logical(rbinom(n, size = 1, prob = 0.5)),
  elective_adm = as.logical(rbinom(n, size = 1, prob = 0.02)),
  homelessness = as.logical(rbinom(n, size = 1, prob = 0.005)),
  peripheral_AD = as.logical(rbinom(n, size = 1, prob = 0.01)),
  coronary_AD = as.logical(rbinom(n, size = 1, prob = 0.12)),
  stroke = as.logical(rbinom(n, size = 1, prob = 0.05)),
  CHF = as.logical(rbinom(n, size = 1, prob = 0.13)),
  hypertension = as.logical(rbinom(n, size = 1, prob = 0.45)),
  COPD = as.logical(rbinom(n, size = 1, prob = 0.06)),
  CKD = as.logical(rbinom(n, size = 1, prob = 0.04)),
  malignancy = as.logical(rbinom(n, size = 1, prob = 0.11)),
  mental_illness = as.logical(rbinom(n, size = 1, prob = 0.07)),
  creatinine = rnorm(n, mean = 80, sd = 15),
  Hb_A1C = rnorm(n, mean = 7.4, sd = 1.5),
  albumin = rnorm(n, mean = 30, sd = 10),
  Hb_A1C_missing = as.logical(rbinom(n, size = 1, prob = 0.6)),
  creatinine_missing = as.logical(rbinom(n, size = 1, prob = 0.07)),
  albumin_missing = as.logical(rbinom(n, size = 1, prob = 0.02))
)

# for entries with missing lab data, set lab result to 0 (according to imputation method)
dummy_data[Hb_A1C_missing == TRUE, ]$Hb_A1C <- 0
dummy_data[creatinine_missing == TRUE, ]$creatinine <- 0
dummy_data[albumin_missing == TRUE, ]$albumin <- 0

attr(terms(form), "term.labels")

# Ensure the column order matches the order in coefs
X <- model.matrix(, data = dummy_data)[, -1]  # remove intercept
lp <- as.vector(X %*% coefs[1:3])  # linear predictor

# arbitrary baseline
# get baseline hazard = hazard when all covariates are at 0
baseline_hazard <- 0.01 

# Assume exponential baseline subdistribution hazard
# Simulated event times based on subdistribution hazard
time <- -log(runif(n)) / (baseline_hazard * exp(lp))

# Simulated event indicator (e.g., cause 1 vs. censoring)
status <- rbinom(n, size = 1, prob = 0.8)  # 80% events, 20% censored

dummy_data$time <- time
dummy_data$status <- status