library(testthat)
library(riskRegression)
library(prodlim)
setwd("../")

test_that("dummy data is created correctly", {
  source("data/simulate_data.R")
  dummy_data <- simulate_data()
  
  expect_equal(nrow(dummy_data), 10000)
  expect_equal(ncol(dummy_data), 18)
  expect_equal(round(mean(dummy_data$age), 2), 69.63)
  expect_equal(sum(is.na(dummy_data$Hb_A1C)), 5868)
  expect_equal(round(max(dummy_data$creatinine, na.rm = TRUE), 2), 153.86)
})

test_that("there is only one model object (for FGR)", {
  expect_equal(list.files("models/"), "final_FGR_clean.rds")
})

test_that("model object contains expected list items", {
  model <- readRDS("models/final_FGR_clean.rds")
  expect_equal(names(model), c("crrFit", "call", "terms", "form", "cause", "coef", "splines"))
})

test_that("predicted risk scores are as expected", {
  source("data/simulate_data.R")
  dummy_data <- simulate_data()
  model <- readRDS("models/final_FGR_clean.rds")
  
  # create missing indicator flag
  dummy_data[, Hb_A1C_missing := ifelse(is.na(Hb_A1C), TRUE, FALSE)]
  dummy_data[, creatinine_missing := ifelse(is.na(creatinine), TRUE, FALSE)]
  dummy_data[, albumin_missing := ifelse(is.na(albumin), TRUE, FALSE)]
  
  # set missing test results to 0
  dummy_data[is.na(Hb_A1C), Hb_A1C := 0]
  dummy_data[is.na(creatinine), creatinine := 0]
  dummy_data[is.na(albumin), albumin := 0]
  
  # add non-linear components to new_data
  age_splines <- rcs(dummy_data$age, model$splines$age_knots)
  creatinine_splines <- rcs(dummy_data$creatinine, model$splines$creatinine_knots)
  Hb_A1C_splines <- rcs(dummy_data$Hb_A1C, model$splines$hba1c_knots)
  albumin_splines <- rcs(dummy_data$albumin, model$splines$albumin_knots)
  
  dummy_data[, age1 := age_splines[, 2]]
  dummy_data[, age2 := age_splines[, 3]]
  dummy_data[, creatinine1 := creatinine_splines[, 2]]
  dummy_data[, creatinine2 := creatinine_splines[, 3]]
  dummy_data[, Hb_A1C1 := Hb_A1C_splines[, 2]]
  dummy_data[, Hb_A1C2 := Hb_A1C_splines[, 3]]
  dummy_data[, albumin1 := albumin_splines[, 2]]
  
  # generate predictions
  pred <- predictRisk(model, dummy_data, 365.25, 1)
  
  expect_equal(round(mean(pred), 4), 0.0102)
  expect_equal(round(min(pred), 4), 8e-04)
  expect_equal(round(max(pred), 4), 0.2395)
})
