Development, internal-external validation, and use of a prognostic model
to predict future foot complications among people with diabetes recently
discharged from hospital in Ontario, Canada
================

- <a href="#overview" id="toc-overview">Overview</a>
- <a href="#set-up" id="toc-set-up">Set-up</a>
- <a href="#model-objects" id="toc-model-objects">Model objects</a>
- <a href="#model-parameters" id="toc-model-parameters">Model
  parameters</a>
  - <a href="#fgr" id="toc-fgr">FGR</a>
  - <a href="#rsf-cr" id="toc-rsf-cr">RSF-CR</a>
- <a href="#dummy-data" id="toc-dummy-data">Dummy data</a>
- <a href="#generate-new-predictions"
  id="toc-generate-new-predictions">Generate new predictions</a>

## Overview

This file contains R code illustrating how to:  
1. Obtain all relevant model information (parameters, coefficients etc.)
from the model objects shared in this repository. 2. Use the model
objects to generate predictions on new test data. 3. Assess model
performance on the new test data.

## Set-up

The following R libraries are used in this file, the code chunk below
will a) check whether you already have them installed, b) install them
for you if not already present, and c) load the packages into the
session.

``` r
library(riskRegression)
library(randomForestSRC)
library(rms)
library(prodlim)
```

## Model objects

``` r
## load model objects
FGR <- readRDS("models/final_FGR_clean.rds")
# RSF <-

## FGR is a list with 7 items
# crrFit = model fit obtained with riskRegression::FGR()
# cause = 1 (status identifying event of interest = foot complication)
names(FGR)
```

    ## [1] "crrFit"  "terms"   "coef"    "splines" "form"    "call"    "cause"

## Model parameters

### FGR

### RSF-CR

## Dummy data

## Generate new predictions

``` r
## create new test data
new_data <- data.frame(
  age = 67,
  sex_f = 1,
  elective_adm = 1,
  homelessness = 0,
  peripheral_AD = 0,
  coronary_AD = 1,
  stroke = 0,
  CHF = 0,
  hypertension = 1,
  COPD = 0,
  CKD = 0,
  malignancy = 0,
  mental_illness = 0,
  creatinine = 140.0,
  Hb_A1C = 8.5,
  albumin = 32.1,
  Hb_A1C_missing = 0,
  creatinine_missing = 0,
  albumin_missing = 0
)

## add splines to data
# derive splines based on knot locations
age_splines <- rcs(new_data$age, FGR$splines$age_knots)
creatinine_splines <- rcs(new_data$creatinine, FGR$splines$creatinine_knots)
Hb_A1C_splines <- rcs(new_data$Hb_A1C, FGR$splines$hba1c_knots)
albumin_splines <- rcs(new_data$albumin, FGR$splines$albumin_knots)

## add non-linear components to new_data
new_data$age1 <- age_splines[, 2]
new_data$age2 <- age_splines[, 3]
new_data$creatinine1 <- creatinine_splines[, 2]
new_data$creatinine2 <- creatinine_splines[, 3]
new_data$Hb_A1C1 <- Hb_A1C_splines[, 2]
new_data$Hb_A1C2 <- Hb_A1C_splines[, 3]
new_data$albumin1 <- albumin_splines[, 2]

# predicted risk at 1 year
predict(FGR, newdata = new_data, times = 365.25)[1] # 0.0171758
```

    ##  [1] "age"                "sex_f"              "elective_adm"      
    ##  [4] "homelessness"       "peripheral_AD"      "coronary_AD"       
    ##  [7] "stroke"             "CHF"                "hypertension"      
    ## [10] "COPD"               "CKD"                "malignancy"        
    ## [13] "mental_illness"     "creatinine"         "Hb_A1C"            
    ## [16] "albumin"            "Hb_A1C_missing"     "creatinine_missing"
    ## [19] "albumin_missing"    "age1"               "age2"              
    ## [22] "creatinine1"        "creatinine2"        "albumin1"          
    ## [25] "Hb_A1C1"            "Hb_A1C2"

    ## [1] 0.0171758

``` r
# # to plot CIF, we need to extract predicted values at multiple time points
# time <- seq(1, 365 * 5, 5) # predict up to 5 years in steps of 5 days
# p <- predict(model, newdata = new_data, times = time)
# plot(time, p, type = "l")
```
