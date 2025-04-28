# diabetes-larp
Diabetes foot complications: Risk prediction models

## Overview

This repository contains model objects, dummy data, and R code allowing users to generate predictions for the risk prediction models reported by Roberts & Loeffler et al. (in preparation). Briefly, the paper reports two models predicting the risk of diabetic foot complications (e.g., ulcers, gangrene, infections etc.) in hospitalized patients with diabetes who are discharged from General Internal Medicine (GIM). Two different types of prognostic models were developed and validated in an internal-external cross-validation framework:

1) [Fine-Gray Regression (FGR)](https://www.tandfonline.com/doi/abs/10.1080/01621459.1999.10474144)
2) [Random Survival Forest for Competing Risk (RSF-CR)](https://pubmed.ncbi.nlm.nih.gov/24728979/)

Both models are designed to estimate the cumulative incidence function (CIF) for diabetic foot complications while accounting for the competing risk of death. The Fine-Gray model is a semi-parametric regression approach that directly models the subdistribution hazard, enabling interpretation of covariate effects on the CIF. In contrast, the RSF-CR model is an ensemble-based machine learning method that captures non-linear relationships and interactions without requiring strong modeling assumptions.

The model building process was extensively validated in a nested internal-external cross-validation approach to evaluate generalizability across different health institutions in Ontario. This repository contains the final models that were trained on the full cohort as described in Roberts & Loeffler et al. (in preparation). The Fine-Gray regression model is currently deployed at a single hospital, where patients' predicted risk of foot complications is calculated upon discharge, and patients with the highest risk scores are referred to chiropody clinics for specialized screening.

## Data

A dummy dataset can be found in the `data/`, which also contains a [data dictionary](/data/data_dictionary.csv) with definitions for all relevant predictor and outcome variables.


## Generating predictions in R

For a demo on how to generate risk predictions, please see [predict_risk.md](predict_risk.md)

## Validating predictions

If you want to check how well our models perform on a new test dataset, we recommend following the methods reported in [van Geloven et al., 2022](https://www.bmj.com/content/377/bmj-2021-069249). Example code can be found in the [survival-lumc repository](https://github.com/survival-lumc/ValidationCompRisks).

