# indRect Package - Quick Reference Guide

## Package Overview

`indRect` provides functions to visualize indirect effects in causal models. Based on Bush-Beaupré et al. (2025).

## Core Functions

### Prediction Functions

#### 1. Simple Mediation: E → M → O

```r
indirect_predictions(
  model_mediator,      # Model for M ~ E
  model_outcome,       # Model for O ~ E + M
  exposure_var,        # Name of exposure variable
  mediator_var,        # Name of mediator variable
  data,               # Original data
  n_points = 30,      # Number of prediction points
  vcov = TRUE         # Compute confidence intervals
)
```

**Returns:** List with 4 data frames:
- `pred_M_E`: Direct effect M ~ E
- `pred_O_E`: Direct effect O ~ E
- `pred_O_M`: Direct effect O ~ M
- `pred_O_ME`: Indirect effect O ~ M(E)

#### 2. Interacting Predictors: E1*E2 → M → O

```r
indirect_predictions_interaction(
  model_mediator,          # Model for M ~ E1*E2
  model_outcome,           # Model for O ~ E1*E2 + M
  exposure1_var,           # Name of first exposure
  exposure2_var,           # Name of second exposure
  mediator_var,            # Name of mediator
  data,
  exposure1_values = c(-1, 0, 1),  # E1 levels to plot
  n_points = 30,
  vcov = TRUE
)
```

**Returns:** List with 4 data frames:
- `pred_M_E1E2`: Direct effect M ~ E1*E2
- `pred_O_E1E2`: Direct effect O ~ E1*E2
- `pred_O_M`: Direct effect O ~ M
- `pred_O_ME1E2`: Indirect effect O ~ M(E1*E2)

#### 3. Interaction as Mediator: E → M1*M2 → O

```r
indirect_predictions_mediator_interaction(
  model_mediator1,         # Model for M1 ~ E
  model_mediator2,         # Model for M2 ~ E
  model_outcome,           # Model for O ~ E + M1*M2
  exposure_var,
  mediator1_var,
  mediator2_var,
  data,
  mediator2_quantiles = c(0.1, 0.5, 0.9),  # M2 levels
  n_points = 30,
  vcov = TRUE
)
```

**Returns:** List with 5 data frames:
- `pred_M1_E`: Direct effect M1 ~ E
- `pred_M2_E`: Direct effect M2 ~ E
- `pred_O_E`: Direct effect O ~ E
- `pred_O_M1M2`: Direct effect O ~ M1*M2
- `pred_O_M1M2E`: Indirect effect O ~ M1(E)*M2(E)

### Plotting Functions

#### Plot Direct Effects

```r
plot_direct_effect(
  pred_data,              # Prediction data frame
  x_var,                  # X-axis variable name
  y_var = "estimate",     # Y-axis variable (usually "estimate")
  title = "Direct Effect",
  x_label = "Predictor",
  y_label = "Response",
  x_color = "tomato3",    # Color for x-axis
  y_color = "aquamarine4", # Color for y-axis
  add_arrows = TRUE,
  line_width = 1.5,
  ribbon_alpha = 0.2
)
```

#### Plot Simple Indirect Effects

```r
plot_indirect_effect(
  pred_O_M,               # Direct M→O predictions
  pred_O_ME,              # Indirect E→M→O predictions
  mediator_var,
  exposure_var,
  title = "Indirect Effect",
  x_label = "Mediator",
  y_label = "Outcome",
  x_color = "mediumaquamarine",
  y_color = "lightskyblue",
  exposure_color_palette = NULL,  # Custom color gradient
  add_arrows = TRUE
)
```

#### Plot Interacting Predictors

```r
plot_indirect_interaction(
  pred_O_ME1E2,           # Indirect predictions
  mediator_var,
  exposure1_var,          # Variable for facets
  exposure2_var,          # Variable for color gradient
  title = "Indirect Effect of E1*E2",
  x_label = "Mediator",
  y_label = "Outcome",
  exposure1_colors = c("goldenrod2", "magenta3", "slategray2"),
  exposure2_color_palette = NULL,
  facet_labels = NULL     # Named vector for facet labels
)
```

#### Plot Mediator Interaction

```r
plot_indirect_mediator_interaction(
  pred_O_M1M2,            # Direct M1*M2→O predictions
  pred_O_M1M2E,           # Indirect E→M1*M2→O predictions
  mediator1_var,
  mediator2_var,          # Variable for facets
  exposure_var,           # Variable for color gradient
  title = "Indirect Effect through M1*M2",
  x_label = "Mediator 1",
  y_label = "Outcome",
  exposure_color_palette = NULL,
  facet_labels = NULL
)
```

## Typical Workflow

### Step 1: Fit Models

```r
library(glmmTMB)

# For simple mediation
mod_mediator <- glmmTMB(M ~ E, family = ..., data = data)
mod_outcome <- glmmTMB(O ~ E + M, family = ..., data = data)
```

### Step 2: Extract Predictions

```r
library(indRect)

preds <- indirect_predictions(
  mod_mediator, mod_outcome,
  "E", "M", data
)
```

### Step 3: Create Plots

```r
# Direct effects
p1 <- plot_direct_effect(preds$pred_M_E, "E", 
                         title = "E → M")
p2 <- plot_direct_effect(preds$pred_O_M, "M",
                         title = "M → O")

# Indirect effect
p3 <- plot_indirect_effect(preds$pred_O_M, preds$pred_O_ME,
                           "M", "E",
                           title = "E → M → O")

# Combine (requires patchwork)
library(patchwork)
p1 / p2 / p3
```

## Customization Tips

### Change Color Palettes

```r
# Custom exposure gradient
my_colors <- scales::alpha(
  colorRampPalette(c("blue", "red"))(30), 0.8
)

plot_indirect_effect(..., exposure_color_palette = my_colors)
```

### Modify Facet Labels

```r
# For interacting predictors
facet_labels <- c(
  `-1` = "Low E1",
  `0` = "Medium E1",
  `1` = "High E1"
)

plot_indirect_interaction(..., facet_labels = facet_labels)
```

### Further ggplot2 Customization

All plot functions return ggplot2 objects, so you can modify them:

```r
p <- plot_indirect_effect(...)

p + 
  theme(text = element_text(family = "Arial")) +
  scale_y_continuous(limits = c(0, 1))
```

## Common Issues

### Issue: "Object not found" errors

**Solution:** Ensure variable names match exactly between data and model formulas.

```r
# Check variable names
names(data)
names(preds$pred_M_E)
```

### Issue: Predictions seem wrong

**Solution:** Verify models are correctly specified and data is appropriate.

```r
# Check model summaries
summary(mod_mediator)
summary(mod_outcome)

# Check prediction ranges
range(preds$pred_M_E$estimate)
```

### Issue: Plots don't display

**Solution:** Make sure to explicitly print or save the plot.

```r
# Explicitly print
print(p)

# Or save
ggsave("my_plot.png", p, width = 8, height = 6)
```

## Running Tests

```r
# Install with tests
install.packages("/path/to/indRect", 
                 repos = NULL, 
                 type = "source",
                 INSTALL_opts = "--install-tests")

# Run tests
library(testthat)
test_package("indRect")
```

## Package Information

```r
# View package help
?indRect

# List all functions
ls("package:indRect")

# View vignette
vignette("indirect-effects", package = "indRect")
```

## Support

For questions, issues, or feature requests:
- Email: allen.bush-beaupre@usherbrooke.ca
- File an issue on GitHub (if applicable)

## Citation

Bush-Beaupré, A., Bélisle, M., & Coroller-Chouraki, S. (2025). Extending the causal inference toolkit for ecologists: A visualization method of indirect effects. *Methods in Ecology and Evolution*.
