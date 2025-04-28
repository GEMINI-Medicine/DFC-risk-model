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
1. Load the model objects for the Fine-Gray Regression and Random
Survival Forest-Competing Risk models. 2. Generate predictions on new
test data. 3. Assess model performance on the new test data.

## Set-up

The following R libraries are used in this file, the code chunk below
will a) check whether you already have them installed, b) install them
for you if not already present, and c) load the packages into the
session.

    ## riskRegression version 2023.12.21

    ## 
    ##  randomForestSRC 3.3.1 
    ##  
    ##  Type rfsrc.news() to see new features, changes, and bug fixes. 
    ## 

    ## Loading required package: Hmisc

    ## 
    ## Attaching package: 'Hmisc'

    ## The following object is masked from 'package:randomForestSRC':
    ## 
    ##     impute

    ## The following objects are masked from 'package:base':
    ## 
    ##     format.pval, units

## Model objects

    ## [1] "crrFit"  "terms"   "coef"    "splines" "form"    "call"    "cause"

## Model parameters

### FGR

### RSF-CR

## Dummy data

## Generate new predictions

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
