# DFC-risk-model [![Tests](https://github.com/GEMINI-Medicine/DFC-risk-model/actions/workflows/run-tests.yaml/badge.svg)](https://github.com/GEMINI-Medicine/DFC-risk-model/actions/workflows/run-tests.yaml)

Diabetes Foot Complications: Risk Prediction Model


## Overview

This repository contains detailed documentation about the Fine-Gray Regression (FGR) model reported in Roberts & Loeffler et al. (in preparation).

The model predicts the risk of foot complications (e.g., ulcers, gangrene, infections etc.) in hospitalized patients with diabetes who are discharged from General Internal Medicine (GIM). 

Cross-validated model performance (discrimination and calibration) of the FGR model were highly comparable to a Random Survival Forest for Competing Risks (not included here because the model object requires patient-level time-to-event training data, which can't be shared publicly).   

This repository contains the final FGR model, which was trained on a total of 107,836 patients from 20 institutions in Ontario, Canada. The model is currently deployed at one hospital, where patients with the highest risk scores are referred to chiropody clinics after discharge from hospital.

Here, we share the model object, dummy data, and R code allowing users to generate predictions on new data and validate model performance in a different cohort of patients.


## Fine-Gray Regression

Briefly, the FGR model reported here estimates the cumulative incidence function (CIF) for diabetic foot complications while accounting for the competing risk of death. FGR is a semi-parametric regression approach that directly models the subdistribution hazard, enabling interpretation of covariate effects on the CIF ([Fine & Gray, 1997](https://www.tandfonline.com/doi/abs/10.1080/01621459.1999.10474144)).

Predictor variables were selected a priori and include patient-level characteristics like age, sex, admission urgency, comorbidities, homelessness, and lab results (see [here](/data/data_dictionary.csv) for a complete list). Restricted cubic splines were used to relax linearity assumptions for continuous predictors (age, hemoglobin A1C, creatinine, and albumin). The number of knots for each variable (max. 5) was treated as a hyperparameter and was selected based on a nested cross-validation approach. Knot locations for the final model can be found in the model object (see `model/final_FGR_clean.rds`).


## Repository Content

1) **Model object**: 
	- `model/final_FGR_clean.rds` contains the final FGR model including model formula, optimized coefficients, and spline knot locations
2) **Data**:
	- `data/data_dictionary.csv` provides a detailed overview of all predictor and outcome variables
	- `data/dummy_data.rds` contains randomly generated dummy data that can be used for testing purposes
	- Note: To protect patient privacy, we are not able to share the original training data in this repository. A description of the cohort used for model training can be found in Roberts & Loeffler et al. (in preparation).
3) **R demo code**
	- [predict_risk.md](predict_risk.md) contains a brief demo illustrating how to load the model object, generate predictions on new data, and evaluate model performance. 


## Reference

Roberts & Loeffler et al. (in preparation). Development, internal-external validation, and use of a prognostic model to predict future foot complications among people with diabetes recently discharged from hospital in Ontario, Canada. 


## Contact

If you have any questions about the content of this repository, please [open an issue](https://github.com/GEMINI-Medicine/diabetes-larp/issues) or contact Gemini.Data@unityhealth.to.
