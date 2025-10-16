test_that("indirect_predictions works with simple case", {
  skip_if_not_installed("glmmTMB")
  
  # Simulate simple data
  set.seed(123)
  n <- 500
  E <- rnorm(n, 0, 1)
  M <- rpois(n, exp(4 + 0.1*E))
  O <- rbinom(n, 1, plogis(-3 + 0.1*E + 0.05*M))
  data <- data.frame(E = E, M = M, O = O)
  
  # Fit models
  mod_M <- glmmTMB::glmmTMB(M ~ E, family = poisson, data = data)
  mod_O <- glmmTMB::glmmTMB(O ~ E + M, family = binomial, data = data)
  
  # Extract predictions
  preds <- indirect_predictions(mod_M, mod_O, "E", "M", data, n_points = 10)
  
  # Check output structure
  expect_type(preds, "list")
  expect_named(preds, c("pred_M_E", "pred_O_E", "pred_O_M", "pred_O_ME"))
  
  # Check that predictions are data frames
  expect_s3_class(preds$pred_M_E, "data.frame")
  expect_s3_class(preds$pred_O_E, "data.frame")
  expect_s3_class(preds$pred_O_M, "data.frame")
  expect_s3_class(preds$pred_O_ME, "data.frame")
  
  # Check that predictions have required columns
  expect_true("estimate" %in% names(preds$pred_M_E))
  expect_true("conf.low" %in% names(preds$pred_M_E))
  expect_true("conf.high" %in% names(preds$pred_M_E))
  expect_true("E" %in% names(preds$pred_M_E))
  
  # Check number of rows
  expect_equal(nrow(preds$pred_M_E), 10)
  expect_equal(nrow(preds$pred_O_ME), 10)
})


test_that("indirect_predictions_interaction works with interacting predictors", {
  skip_if_not_installed("glmmTMB")
  
  # Simulate data with interaction
  set.seed(123)
  n <- 500
  E1 <- rnorm(n, 0, 1)
  E2 <- rpois(n, 3)
  M <- rpois(n, exp(0 + 0.3*E1 + 0.2*E2 + 0.05*E1*E2))
  O <- rbinom(n, 1, plogis(-1 + 0.1*E1 + 0.2*E2 - 0.5*E1*E2 - 0.25*M))
  data <- data.frame(E1 = E1, E2 = E2, M = M, O = O)
  
  # Fit models
  mod_M <- glmmTMB::glmmTMB(M ~ E1 + E2 + E1:E2, family = poisson, data = data)
  mod_O <- glmmTMB::glmmTMB(O ~ E1 + E2 + E1:E2 + M, family = binomial, data = data)
  
  # Extract predictions
  preds <- indirect_predictions_interaction(
    mod_M, mod_O, "E1", "E2", "M", data,
    exposure1_values = c(-1, 0, 1), n_points = 10
  )
  
  # Check output structure
  expect_type(preds, "list")
  expect_named(preds, c("pred_M_E1E2", "pred_O_E1E2", "pred_O_M", "pred_O_ME1E2"))
  
  # Check that predictions are data frames
  expect_s3_class(preds$pred_M_E1E2, "data.frame")
  expect_s3_class(preds$pred_O_ME1E2, "data.frame")
  
  # Check that predictions have required columns
  expect_true("E1" %in% names(preds$pred_M_E1E2))
  expect_true("E2" %in% names(preds$pred_M_E1E2))
  expect_true("estimate" %in% names(preds$pred_M_E1E2))
  
  # Check number of rows (3 E1 values × 10 E2 values = 30)
  expect_equal(nrow(preds$pred_M_E1E2), 30)
})


test_that("indirect_predictions_mediator_interaction works with mediator interaction", {
  skip_if_not_installed("glmmTMB")
  
  # Simulate data with mediator interaction
  set.seed(123)
  n <- 500
  E <- rnorm(n, 0, 1)
  M1 <- rpois(n, exp(4 + 0.1*E))
  M2 <- rpois(n, exp(1 - 0.2*E))
  O <- rbinom(n, 1, plogis(-3 + 0.1*E + 0.05*M1 + 0.03*M2 + 0.01*M1*M2))
  data <- data.frame(E = E, M1 = M1, M2 = M2, O = O)
  
  # Fit models
  mod_M1 <- glmmTMB::glmmTMB(M1 ~ E, family = poisson, data = data)
  mod_M2 <- glmmTMB::glmmTMB(M2 ~ E, family = poisson, data = data)
  mod_O <- glmmTMB::glmmTMB(O ~ E + M1 + M2 + M1:M2, family = binomial, data = data)
  
  # Extract predictions
  preds <- indirect_predictions_mediator_interaction(
    mod_M1, mod_M2, mod_O, "E", "M1", "M2", data,
    mediator2_quantiles = c(0.1, 0.5, 0.9), n_points = 10
  )
  
  # Check output structure
  expect_type(preds, "list")
  expect_named(preds, c("pred_M1_E", "pred_M2_E", "pred_O_E", "pred_O_M1M2", "pred_O_M1M2E"))
  
  # Check that predictions are data frames
  expect_s3_class(preds$pred_M1_E, "data.frame")
  expect_s3_class(preds$pred_O_M1M2E, "data.frame")
  
  # Check that predictions have required columns
  expect_true("E" %in% names(preds$pred_M1_E))
  expect_true("M1" %in% names(preds$pred_O_M1M2))
  expect_true("M2" %in% names(preds$pred_O_M1M2))
  
  # Check number of rows for M1M2 predictions (10 M1 values × 3 M2 quantiles = 30)
  expect_equal(nrow(preds$pred_O_M1M2), 30)
})
