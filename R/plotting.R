#' Plot Direct Effect
#'
#' Creates a plot showing the direct effect of a predictor on a response variable.
#'
#' @param pred_data Data frame containing predictions (output from predictions())
#' @param x_var Character string naming the x-axis variable
#' @param y_var Character string naming the y-axis variable (default: "estimate")
#' @param title Plot title
#' @param x_label X-axis label
#' @param y_label Y-axis label
#' @param x_color Color for x-axis (default: "tomato3")
#' @param y_color Color for y-axis (default: "aquamarine4")
#' @param add_arrows Logical, whether to add arrows to axes (default: TRUE)
#' @param line_width Width of the prediction line (default: 1.5)
#' @param ribbon_alpha Transparency of confidence ribbon (default: 0.2)
#'
#' @return A ggplot2 object
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_line geom_ribbon theme_classic labs theme element_line element_text element_blank
#' @importFrom grid arrow unit
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' preds <- indirect_predictions(mod_M, mod_O, "E", "M", data)
#' plot_direct_effect(preds$pred_M_E, "E", title = "Effect of E on M",
#'                    x_label = "Exposure", y_label = "Mediator")
#' }
plot_direct_effect <- function(pred_data, x_var, y_var = "estimate",
                              title = "Direct Effect",
                              x_label = "Predictor", y_label = "Response",
                              x_color = "tomato3", y_color = "aquamarine4",
                              add_arrows = TRUE, line_width = 1.5, ribbon_alpha = 0.2) {
  
  p <- ggplot(data = pred_data, aes(x = .data[[x_var]], y = .data[[y_var]])) +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = ribbon_alpha) +
    geom_line(linewidth = line_width, lineend = "round") +
    theme_classic() +
    labs(title = title, x = x_label, y = y_label)
  
  if (add_arrows) {
    p <- p +
      theme(
        axis.line.y = element_line(
          arrow = arrow(length = unit(0.15, "inches"), ends = "last", type = "closed"),
          linewidth = 1.5,
          color = y_color
        ),
        axis.line.x = element_line(
          arrow = arrow(length = unit(0.15, "inches"), ends = "last", type = "closed"),
          linewidth = 1.5,
          color = x_color
        ),
        axis.ticks = element_blank(),
        axis.title.x = element_text(color = x_color, size = 16, face = "bold"),
        axis.title.y = element_text(color = y_color, size = 16, face = "bold"),
        axis.text.x = element_text(face = "bold", size = 14),
        axis.text.y = element_text(face = "bold", angle = 35, size = 14)
      )
  }
  
  return(p)
}


#' Plot Indirect Effect (Simple Case)
#'
#' Creates a plot showing the indirect effect of an exposure on an outcome through
#' a mediator, overlaying the direct M→O relationship with the indirect E→M→O path.
#'
#' @param pred_O_M Data frame with direct effect predictions for O ~ M
#' @param pred_O_ME Data frame with indirect effect predictions for O ~ M(E)
#' @param mediator_var Character string naming the mediator variable
#' @param exposure_var Character string naming the exposure variable
#' @param title Plot title (default: "Indirect Effect")
#' @param x_label X-axis label (default: "Mediator")
#' @param y_label Y-axis label (default: "Outcome")
#' @param x_color Color for mediator axis (default: "mediumaquamarine")
#' @param y_color Color for outcome axis (default: "lightskyblue")
#' @param exposure_color_palette Color palette for exposure gradient (default: tomato gradient)
#' @param add_arrows Logical, whether to add arrows to axes (default: TRUE)
#'
#' @return A ggplot2 object
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_line geom_ribbon scale_color_gradientn guides theme labs theme_classic
#' @importFrom scales alpha
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' preds <- indirect_predictions(mod_M, mod_O, "E", "M", data)
#' plot_indirect_effect(preds$pred_O_M, preds$pred_O_ME, "M", "E",
#'                     title = "Indirect effect of E on O through M")
#' }
plot_indirect_effect <- function(pred_O_M, pred_O_ME, mediator_var, exposure_var,
                                title = "Indirect Effect",
                                x_label = "Mediator", y_label = "Outcome",
                                x_color = "mediumaquamarine", y_color = "lightskyblue",
                                exposure_color_palette = NULL,
                                add_arrows = TRUE) {
  
  # Default color palette
  if (is.null(exposure_color_palette)) {
    exposure_color_palette <- alpha(colorRampPalette(c("seashell", "tomato3"))(30), 0.8)
  }
  
  p <- ggplot() +
    # Direct effect O ~ M (background)
    geom_ribbon(data = pred_O_M, 
                aes(x = .data[[mediator_var]], ymin = conf.low, ymax = conf.high),
                alpha = 0.05) +
    geom_line(data = pred_O_M,
              aes(x = .data[[mediator_var]], y = estimate),
              linewidth = 1.5, lineend = "round") +
    # Indirect effect O ~ M(E) (foreground, colored by E)
    geom_line(data = pred_O_ME,
              aes(x = .data[[mediator_var]], y = estimate, 
                  color = .data[[exposure_var]], 
                  linewidth = .data[[exposure_var]]),
              lineend = "round") +
    scale_color_gradientn(colours = exposure_color_palette, name = exposure_var) +
    guides(linewidth = "none") +
    theme_classic() +
    labs(title = title, x = x_label, y = y_label) +
    theme(
      legend.position = "inside",
      legend.position.inside = c(0.3, 0.75),
      legend.direction = "horizontal"
    )
  
  if (add_arrows) {
    p <- p +
      theme(
        axis.line.y = element_line(
          arrow = arrow(length = unit(0.15, "inches"), ends = "last", type = "closed"),
          linewidth = 1.5,
          color = y_color
        ),
        axis.line.x = element_line(
          arrow = arrow(length = unit(0.15, "inches"), ends = "last", type = "closed"),
          linewidth = 1.5,
          color = x_color
        ),
        axis.ticks = element_blank(),
        axis.title.x = element_text(color = x_color, size = 16, face = "bold"),
        axis.title.y = element_text(color = y_color, size = 16, face = "bold"),
        axis.text.x = element_text(face = "bold", size = 14),
        axis.text.y = element_text(face = "bold", angle = 35, size = 14)
      )
  }
  
  return(p)
}


#' Plot Indirect Effect (Interacting Predictors)
#'
#' Creates a faceted plot showing the indirect effect when two exposure variables
#' interact in their effect on mediator and outcome (E1*E2 → M → O).
#'
#' @param pred_O_ME1E2 Data frame with indirect effect predictions
#' @param mediator_var Character string naming the mediator variable
#' @param exposure1_var Character string naming the first exposure variable (for facets)
#' @param exposure2_var Character string naming the second exposure variable (for color)
#' @param title Plot title
#' @param x_label X-axis label
#' @param y_label Y-axis label
#' @param exposure1_colors Vector of colors for E1 levels (default: c("goldenrod2", "magenta3", "slategray2"))
#' @param exposure2_color_palette Color palette for E2 gradient
#' @param facet_labels Optional named vector of facet labels
#'
#' @return A ggplot2 object
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_ribbon geom_line scale_fill_manual scale_color_gradientn facet_wrap guides theme_classic labs theme
#' @importFrom scales alpha
#'
#' @examples
#' \dontrun{
#' preds <- indirect_predictions_interaction(mod_M, mod_O, "E1", "E2", "M", data)
#' plot_indirect_interaction(preds$pred_O_ME1E2, "M", "E1", "E2")
#' }
plot_indirect_interaction <- function(pred_O_ME1E2, mediator_var, exposure1_var, exposure2_var,
                                     title = "Indirect Effect of E1*E2 on O through M",
                                     x_label = "Mediator", y_label = "Outcome",
                                     exposure1_colors = c("goldenrod2", "magenta3", "slategray2"),
                                     exposure2_color_palette = NULL,
                                     facet_labels = NULL) {
  
  # Default color palette for E2
  if (is.null(exposure2_color_palette)) {
    exposure2_color_palette <- alpha(colorRampPalette(c("seashell", "tomato3"))(30), 0.8)
  }
  
  # Convert E1 to factor for faceting
  pred_O_ME1E2[[exposure1_var]] <- as.factor(pred_O_ME1E2[[exposure1_var]])
  
  p <- ggplot(data = pred_O_ME1E2) +
    geom_ribbon(aes(x = .data[[mediator_var]], 
                    ymin = conf.low, ymax = conf.high,
                    fill = .data[[exposure1_var]]),
                alpha = 0.2) +
    geom_line(aes(x = .data[[mediator_var]], y = estimate,
                  color = .data[[exposure2_var]],
                  linewidth = .data[[exposure2_var]]),
              lineend = "round") +
    scale_fill_manual(values = exposure1_colors) +
    scale_color_gradientn(colours = exposure2_color_palette, name = exposure2_var) +
    guides(fill = "none", linewidth = "none") +
    theme_classic() +
    facet_wrap(as.formula(paste0("~", exposure1_var)), 
               labeller = if (!is.null(facet_labels)) as_labeller(facet_labels) else NULL) +
    labs(title = title, x = x_label, y = y_label) +
    theme(
      legend.position = "inside",
      legend.position.inside = c(0.2, 0.5)
    )
  
  return(p)
}


#' Plot Indirect Effect (Interaction as Mediator)
#'
#' Creates a faceted plot showing the indirect effect when exposure affects two
#' mediators that interact (E → M1*M2 → O).
#'
#' @param pred_O_M1M2 Data frame with direct effect predictions for O ~ M1*M2
#' @param pred_O_M1M2E Data frame with indirect effect predictions
#' @param mediator1_var Character string naming the first mediator variable
#' @param mediator2_var Character string naming the second mediator variable (for facets)
#' @param exposure_var Character string naming the exposure variable
#' @param title Plot title
#' @param x_label X-axis label
#' @param y_label Y-axis label
#' @param exposure_color_palette Color palette for exposure gradient
#' @param facet_labels Optional named vector of facet labels
#'
#' @return A ggplot2 object
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_ribbon geom_line scale_color_gradientn facet_wrap guides theme_classic labs
#' @importFrom scales alpha
#'
#' @examples
#' \dontrun{
#' preds <- indirect_predictions_mediator_interaction(
#'   mod_M1, mod_M2, mod_O, "E", "M1", "M2", data
#' )
#' plot_indirect_mediator_interaction(
#'   preds$pred_O_M1M2, preds$pred_O_M1M2E, "M1", "M2", "E"
#' )
#' }
plot_indirect_mediator_interaction <- function(pred_O_M1M2, pred_O_M1M2E,
                                              mediator1_var, mediator2_var, exposure_var,
                                              title = "Indirect Effect of E on O through M1*M2",
                                              x_label = "Mediator 1", y_label = "Outcome",
                                              exposure_color_palette = NULL,
                                              facet_labels = NULL) {
  
  # Default color palette
  if (is.null(exposure_color_palette)) {
    exposure_color_palette <- alpha(colorRampPalette(c("seashell", "tomato3"))(30), 0.8)
  }
  
  p <- ggplot() +
    # Direct effect O ~ M1*M2 (background)
    geom_ribbon(data = pred_O_M1M2,
                aes(x = .data[[mediator1_var]], ymin = conf.low, ymax = conf.high),
                alpha = 0.2) +
    geom_line(data = pred_O_M1M2,
              aes(x = .data[[mediator1_var]], y = estimate)) +
    # Indirect effect O ~ M1(E)*M2 (foreground, colored by E)
    geom_line(data = pred_O_M1M2E,
              aes(x = .data[[mediator1_var]], y = estimate,
                  color = .data[[exposure_var]],
                  linewidth = .data[[exposure_var]]),
              lineend = "round") +
    scale_color_gradientn(colours = exposure_color_palette, name = exposure_var) +
    guides(linewidth = "none") +
    theme_classic() +
    facet_wrap(as.formula(paste0("~", mediator2_var)),
               labeller = if (!is.null(facet_labels)) as_labeller(facet_labels) else NULL) +
    labs(title = title, x = x_label, y = y_label) +
    theme(
      legend.position = "inside",
      legend.position.inside = c(0.2, 0.5)
    )
  
  return(p)
}
