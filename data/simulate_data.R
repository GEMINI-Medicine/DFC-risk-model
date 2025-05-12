simulate_data <- function(n = 10000, save_data = FALSE) {
  
  library(data.table)
  library(truncnorm)
  library(rms)
  set.seed(99)
  
  # load model object
  FGR <- readRDS("model/final_FGR_clean.rds")
  coefs <- FGR$crrFit$coef
  
  coefs_death <- -coefs / 10
  #coefs_death <- c(0.03, -0.12, -0.24, 0.18, -0.03, -0.02, -0.1, 0.5, -0.04, 0.33, 0.17, 0.64, 0.12, 0, -0.04, -0.03, -0.21, -0.01, -1.25)
  
  
  # Example covariates
  dummy_data <- data.table(
    age = rtruncnorm(n = n, a = 18, b = 105, mean = 70, sd = 15),
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
    creatinine = rtruncnorm(n = n, a = 1, b = 1000, mean = 80, sd = 20),
    Hb_A1C = rtruncnorm(n = n, a = 5, b = 15, mean = 7.4, sd = 2),
    albumin = rtruncnorm(n = n, a = 10, b = 100, mean = 30, sd = 10),
    Hb_A1C_missing = as.logical(rbinom(n, size = 1, prob = 0.6)),
    creatinine_missing = as.logical(rbinom(n, size = 1, prob = 0.02)),
    albumin_missing = as.logical(rbinom(n, size = 1, prob = 0.3))
  )
  
  # for entries with missing lab data, set lab result to 0 (in lince with imputation approach)
  dummy_data[Hb_A1C_missing == TRUE, Hb_A1C := 0]
  dummy_data[creatinine_missing == TRUE, creatinine := 0]
  dummy_data[albumin_missing == TRUE, albumin := 0]
  
  # add non-linear components to estimate linear predictors below
  age_splines <- rcs(dummy_data$age, FGR$splines$age_knots)
  creatinine_splines <- rcs(dummy_data$creatinine, FGR$splines$creatinine_knots)
  Hb_A1C_splines <- rcs(dummy_data$Hb_A1C, FGR$splines$hba1c_knots)
  albumin_splines <- rcs(dummy_data$albumin, FGR$splines$albumin_knots)
  dummy_data[, age1 := age_splines[, 2]]
  dummy_data[, age2 := age_splines[, 3]]
  dummy_data[, creatinine1 := creatinine_splines[, 2]]
  dummy_data[, creatinine2 := creatinine_splines[, 3]]
  dummy_data[, albumin1 := albumin_splines[, 2]]
  dummy_data[, Hb_A1C1 := Hb_A1C_splines[, 2]]
  dummy_data[, Hb_A1C2 := Hb_A1C_splines[, 3]]
  
  X <- model.matrix(as.formula("~ age + sex_f + elective_adm + homelessness + 
    peripheral_AD + coronary_AD + stroke + CHF + hypertension + 
    COPD + CKD + malignancy + mental_illness + creatinine + Hb_A1C + 
    albumin + Hb_A1C_missing + creatinine_missing + albumin_missing + 
    age1 + age2 + creatinine1 + creatinine2 + albumin1 + Hb_A1C1 + 
    Hb_A1C2"), data = dummy_data)[, -1]  # remove intercept
  
  
  # Generate indicator for cause
  fstatus <- 1 + rbinom(n, 1, prob = (9.9e-13)^exp(X %*% coefs))
  
  # Conditional on cause indicators, simulate model
  ftime <- numeric(n)
  eta1 <- X[fstatus == 1, ] %*% coefs #linear predictor for cause of interest
  eta2 <- X[fstatus == 2, ] %*% coefs_death #linear predictor for competing risk
  
  t1 <- -log(1 - (1 - (1 - runif(length(eta1)) * (1 - (1 - 0.5)^exp(eta1)))^(1 / exp(eta1))) / 0.5)
  t2 <- rexp(length(eta2), rate = exp(eta2)) * 2
  
  ftime[fstatus == 1] <- t1
  ftime[fstatus == 2] <- t2
  
  # censor some observations
  ci <- -log(runif(n)) / (.95)
  #hist(ci)
  
  ftime <- pmin(ftime, ci)
  fstatus[ftime == ci] <- 0
  
  dummy_data$time   <- round(ftime * 15 * 365.25, 2)
  dummy_data$status <- fstatus
  
  ## finalize table
  # for entries with missing lab data, set lab result to NA for illustration purposes
  dummy_data[Hb_A1C_missing == TRUE, Hb_A1C := NA]
  dummy_data[creatinine_missing == TRUE, creatinine := NA]
  dummy_data[albumin_missing == TRUE, albumin := NA]
  # remove non-linear components to illustrate how to derive them for new cohort
  dummy_data <- dummy_data[, -c("age1", "age2", "creatinine1", "creatinine2", "albumin1", "Hb_A1C1", "Hb_A1C2", "Hb_A1C_missing", "creatinine_missing", "albumin_missing")]
  
  if (save_data == TRUE) {
    saveRDS(dummy_data, "data/dummy_data.rds")
  }
  
  return(dummy_data)
  
}





