#' Extract Indirect Effect Predictions (Simple Case)
#'
#' Calculates predictions for indirect effects in a simple mediation model where
#' an exposure variable (E) affects an outcome (O) through a mediator (M).
#' This implements the method described in Bush-Beaupré et al. (2025).
#'
#' @param model_mediator A fitted model object for M ~ E
#' @param model_outcome A fitted model object for O ~ E + M
#' @param exposure_var Character string naming the exposure variable
#' @param mediator_var Character string naming the mediator variable
#' @param data Data frame containing the original data
#' @param n_points Number of points for prediction grid (default: 30)
#' @param vcov Logical, whether to compute variance-covariance matrix (default: TRUE)
#'
#' @return A list containing:
#' \itemize{
#'   \item pred_M_E: Direct effect predictions for M ~ E
#'   \item pred_O_E: Direct effect predictions for O ~ E
#'   \item pred_O_M: Direct effect predictions for O ~ M
#'   \item pred_O_ME: Indirect effect predictions for O ~ M(E)
#' }
#'
#' @export
#' @importFrom marginaleffects predictions datagrid
#' @importFrom dplyr select mutate
#'
#' @examples
#' \dontrun{
#' # Simulate data
#' n <- 1000
#' E <- rnorm(n, 0, 1)
#' M <- rpois(n, exp(4 + 0.1*E))
#' O <- rbinom(n, 1, plogis(-3 + 0.1*E + 0.05*M))
#' data <- data.frame(E = E, M = M, O = O)
#'
#' # Fit models
#' library(glmmTMB)
#' mod_M <- glmmTMB(M ~ E, family = poisson, data = data)
#' mod_O <- glmmTMB(O ~ E + M, family = binomial, data = data)
#'
#' # Extract predictions
#' preds <- indirect_predictions(mod_M, mod_O, "E", "M", data)
#' }
indirect_predictions <- function(model_mediator, model_outcome, exposure_var, mediator_var,
                                 data, n_points = 30, vcov = TRUE) {
  
  # Extract range of exposure variable
  E_range <- range(data[[exposure_var]], na.rm = TRUE)
  M_range <- range(data[[mediator_var]], na.rm = TRUE)
  
  # Create prediction grid for exposure
  E_grid <- seq(from = E_range[1], to = E_range[2], length.out = n_points)
  
  # Direct effect: M ~ E
  newdata_M_E <- data.frame(x = E_grid)
  names(newdata_M_E) <- exposure_var
  pred_M_E <- predictions(model_mediator, vcov = vcov, newdata = newdata_M_E, re.form = NA)
  
  # Direct effect: O ~ E (holding M at mean)
  newdata_O_E <- data.frame(x = E_grid)
  names(newdata_O_E) <- exposure_var
  pred_O_E <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_E, re.form = NA)
  
  # Direct effect: O ~ M (holding E at mean)
  M_grid <- seq(from = M_range[1], to = M_range[2], length.out = n_points)
  newdata_O_M <- data.frame(x = M_grid)
  names(newdata_O_M) <- mediator_var
  pred_O_M <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_M, re.form = NA)
  
  # Indirect effect: O ~ M(E)
  # Use predicted values of M from model_mediator as input to model_outcome
  newdata_O_ME <- data.frame(x = pred_M_E$estimate)
  names(newdata_O_ME) <- mediator_var
  pred_O_ME_raw <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_ME, re.form = NA)
  
  # Add exposure values to indirect predictions
  pred_O_ME <- pred_O_ME_raw
  pred_O_ME[[exposure_var]] <- pred_M_E[[exposure_var]]
  
  # Return list of all predictions
  list(
    pred_M_E = as.data.frame(pred_M_E),
    pred_O_E = as.data.frame(pred_O_E),
    pred_O_M = as.data.frame(pred_O_M),
    pred_O_ME = as.data.frame(pred_O_ME)
  )
}


#' Extract Indirect Effect Predictions (Interacting Predictors)
#'
#' Calculates predictions for indirect effects when two exposure variables interact
#' in their effect on both mediator and outcome (E1*E2 → M → O).
#'
#' @param model_mediator A fitted model object for M ~ E1*E2
#' @param model_outcome A fitted model object for O ~ E1*E2 + M
#' @param exposure1_var Character string naming the first exposure variable
#' @param exposure2_var Character string naming the second exposure variable
#' @param mediator_var Character string naming the mediator variable
#' @param data Data frame containing the original data
#' @param exposure1_values Values of E1 to use (default: c(-1, 0, 1))
#' @param n_points Number of points for E2 prediction grid (default: 30)
#' @param vcov Logical, whether to compute variance-covariance matrix (default: TRUE)
#'
#' @return A list containing:
#' \itemize{
#'   \item pred_M_E1E2: Direct effect predictions for M ~ E1*E2
#'   \item pred_O_E1E2: Direct effect predictions for O ~ E1*E2
#'   \item pred_O_M: Direct effect predictions for O ~ M
#'   \item pred_O_ME1E2: Indirect effect predictions for O ~ M(E1*E2)
#' }
#'
#' @export
#' @importFrom marginaleffects predictions datagrid
#' @importFrom dplyr select mutate
#'
#' @examples
#' \dontrun{
#' # Simulate data with interaction
#' n <- 1000
#' E1 <- rnorm(n, 0, 1)
#' E2 <- rpois(n, 3)
#' M <- rpois(n, exp(0 + 0.3*E1 + 0.2*E2 + 0.05*E1*E2))
#' O <- rbinom(n, 1, plogis(-1 + 0.1*E1 + 0.2*E2 - 0.5*E1*E2 - 0.25*M))
#' data <- data.frame(E1 = E1, E2 = E2, M = M, O = O)
#'
#' # Fit models
#' library(glmmTMB)
#' mod_M <- glmmTMB(M ~ E1 + E2 + E1:E2, family = poisson, data = data)
#' mod_O <- glmmTMB(O ~ E1 + E2 + E1:E2 + M, family = binomial, data = data)
#'
#' # Extract predictions
#' preds <- indirect_predictions_interaction(mod_M, mod_O, "E1", "E2", "M", data)
#' }
indirect_predictions_interaction <- function(model_mediator, model_outcome, 
                                            exposure1_var, exposure2_var, mediator_var,
                                            data, exposure1_values = c(-1, 0, 1), 
                                            n_points = 30, vcov = TRUE) {
  
  # Extract range of E2
  E2_range <- range(data[[exposure2_var]], na.rm = TRUE)
  M_range <- range(data[[mediator_var]], na.rm = TRUE)
  
  # Create prediction grid for E2
  E2_grid <- seq(from = E2_range[1], to = E2_range[2], length.out = n_points)
  
  # Direct effect: M ~ E1*E2
  newdata_M_E1E2 <- expand.grid(x1 = exposure1_values, x2 = E2_grid)
  names(newdata_M_E1E2) <- c(exposure1_var, exposure2_var)
  pred_M_E1E2 <- predictions(model_mediator, vcov = vcov, newdata = newdata_M_E1E2, re.form = NA)
  
  # Direct effect: O ~ E1*E2 (holding M at mean)
  newdata_O_E1E2 <- expand.grid(x1 = exposure1_values, x2 = E2_grid)
  names(newdata_O_E1E2) <- c(exposure1_var, exposure2_var)
  pred_O_E1E2 <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_E1E2, re.form = NA)
  
  # Direct effect: O ~ M (holding E1, E2 at mean)
  M_grid <- seq(from = M_range[1], to = M_range[2], length.out = n_points)
  newdata_O_M <- data.frame(x = M_grid)
  names(newdata_O_M) <- mediator_var
  pred_O_M <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_M, re.form = NA)
  
  # Indirect effect: O ~ M(E1*E2)
  newdata_O_ME1E2 <- data.frame(x = pred_M_E1E2$estimate)
  names(newdata_O_ME1E2) <- mediator_var
  pred_O_ME1E2_raw <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_ME1E2, re.form = NA)
  
  # Add E1 and E2 values to indirect predictions
  pred_O_ME1E2 <- pred_O_ME1E2_raw
  pred_O_ME1E2[[exposure1_var]] <- pred_M_E1E2[[exposure1_var]]
  pred_O_ME1E2[[exposure2_var]] <- pred_M_E1E2[[exposure2_var]]
  
  # Return list of all predictions
  list(
    pred_M_E1E2 = as.data.frame(pred_M_E1E2),
    pred_O_E1E2 = as.data.frame(pred_O_E1E2),
    pred_O_M = as.data.frame(pred_O_M),
    pred_O_ME1E2 = as.data.frame(pred_O_ME1E2)
  )
}


#' Extract Indirect Effect Predictions (Interaction as Mediator)
#'
#' Calculates predictions for indirect effects when an exposure affects two mediators
#' that interact in their effect on the outcome (E → M1*M2 → O).
#'
#' @param model_mediator1 A fitted model object for M1 ~ E
#' @param model_mediator2 A fitted model object for M2 ~ E
#' @param model_outcome A fitted model object for O ~ E + M1*M2
#' @param exposure_var Character string naming the exposure variable
#' @param mediator1_var Character string naming the first mediator variable
#' @param mediator2_var Character string naming the second mediator variable
#' @param data Data frame containing the original data
#' @param mediator2_quantiles Quantiles of M2 to use (default: c(0.1, 0.5, 0.9))
#' @param n_points Number of points for prediction grid (default: 30)
#' @param vcov Logical, whether to compute variance-covariance matrix (default: TRUE)
#'
#' @return A list containing:
#' \itemize{
#'   \item pred_M1_E: Direct effect predictions for M1 ~ E
#'   \item pred_M2_E: Direct effect predictions for M2 ~ E
#'   \item pred_O_E: Direct effect predictions for O ~ E
#'   \item pred_O_M1M2: Direct effect predictions for O ~ M1*M2
#'   \item pred_O_M1M2E: Indirect effect predictions for O ~ M1(E)*M2(E)
#' }
#'
#' @export
#' @importFrom marginaleffects predictions datagrid
#' @importFrom dplyr select mutate
#'
#' @examples
#' \dontrun{
#' # Simulate data with mediator interaction
#' n <- 1000
#' E <- rnorm(n, 0, 1)
#' M1 <- rpois(n, exp(4 + 0.1*E))
#' M2 <- rpois(n, exp(1 - 0.2*E))
#' O <- rbinom(n, 1, plogis(-3 + 0.1*E + 0.05*M1 + 0.03*M2 + 0.01*M1*M2))
#' data <- data.frame(E = E, M1 = M1, M2 = M2, O = O)
#'
#' # Fit models
#' library(glmmTMB)
#' mod_M1 <- glmmTMB(M1 ~ E, family = poisson, data = data)
#' mod_M2 <- glmmTMB(M2 ~ E, family = poisson, data = data)
#' mod_O <- glmmTMB(O ~ E + M1 + M2 + M1:M2, family = binomial, data = data)
#'
#' # Extract predictions
#' preds <- indirect_predictions_mediator_interaction(
#'   mod_M1, mod_M2, mod_O, "E", "M1", "M2", data
#' )
#' }
indirect_predictions_mediator_interaction <- function(model_mediator1, model_mediator2, 
                                                     model_outcome, exposure_var, 
                                                     mediator1_var, mediator2_var, data,
                                                     mediator2_quantiles = c(0.1, 0.5, 0.9),
                                                     n_points = 30, vcov = TRUE) {
  
  # Extract ranges
  E_range <- range(data[[exposure_var]], na.rm = TRUE)
  M1_range <- range(data[[mediator1_var]], na.rm = TRUE)
  M2_quantile_values <- quantile(data[[mediator2_var]], probs = mediator2_quantiles, na.rm = TRUE)
  
  # Create prediction grids
  E_grid <- seq(from = E_range[1], to = E_range[2], length.out = n_points)
  M1_grid <- seq(from = M1_range[1], to = M1_range[2], length.out = n_points)
  
  # Direct effect: M1 ~ E
  newdata_M1_E <- data.frame(x = E_grid)
  names(newdata_M1_E) <- exposure_var
  pred_M1_E <- predictions(model_mediator1, vcov = vcov, newdata = newdata_M1_E, re.form = NA)
  
  # Direct effect: M2 ~ E
  newdata_M2_E <- data.frame(x = E_grid)
  names(newdata_M2_E) <- exposure_var
  pred_M2_E <- predictions(model_mediator2, vcov = vcov, newdata = newdata_M2_E, re.form = NA)
  
  # Direct effect: O ~ E (holding M1, M2 at mean)
  newdata_O_E <- data.frame(x = E_grid)
  names(newdata_O_E) <- exposure_var
  pred_O_E <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_E, re.form = NA)
  
  # Direct effect: O ~ M1*M2 (holding E at mean)
  newdata_O_M1M2 <- expand.grid(x1 = M1_grid, x2 = M2_quantile_values)
  names(newdata_O_M1M2) <- c(mediator1_var, mediator2_var)
  pred_O_M1M2 <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_M1M2, re.form = NA)
  
  # Indirect effect: O ~ M1(E)*M2(E)
  # Use predicted M1 values and fixed M2 quantiles
  newdata_O_M1M2E <- expand.grid(x1 = pred_M1_E$estimate, x2 = M2_quantile_values)
  names(newdata_O_M1M2E) <- c(mediator1_var, mediator2_var)
  pred_O_M1M2E_raw <- predictions(model_outcome, vcov = vcov, newdata = newdata_O_M1M2E, re.form = NA)
  
  # Add exposure values to indirect predictions
  pred_O_M1M2E <- pred_O_M1M2E_raw
  # Need to replicate E values for each M2 quantile
  n_quantiles <- length(mediator2_quantiles)
  pred_O_M1M2E[[exposure_var]] <- rep(pred_M1_E[[exposure_var]], times = n_quantiles)
  
  # Return list of all predictions
  list(
    pred_M1_E = as.data.frame(pred_M1_E),
    pred_M2_E = as.data.frame(pred_M2_E),
    pred_O_E = as.data.frame(pred_O_E),
    pred_O_M1M2 = as.data.frame(pred_O_M1M2),
    pred_O_M1M2E = as.data.frame(pred_O_M1M2E)
  )
}
