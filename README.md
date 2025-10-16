# indRect <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/yourusername/indRect/workflows/R-CMD-check/badge.svg)](https://github.com/yourusername/indRect/actions)
<!-- badges: end -->

## Visualizing Indirect Effects in Causal Models

`indRect` provides tools for visualizing direct and indirect effects in causal models using the method described in Bush-Beaupré et al. (2025). The package makes it easy to extract model predictions and create publication-ready plots showing how exposure variables affect outcomes through mediator variables.

## Installation

You can install the development version of indRect from your local directory:

```r
# Install from source
install.packages("/home/abush/working_vol/indRect", repos = NULL, type = "source")

# Or using devtools
devtools::install_local("/home/abush/working_vol/indRect")
```

## Quick Start

### Simple Indirect Effects (E → M → O)

```r
library(indRect)
library(glmmTMB)
set.seed(333)

# Simulate data
n <- 1000
E <- rnorm(n, 0, 1)
M <- rpois(n, exp(4 + 0.1*E))
O <- rbinom(n, 1, plogis(-3 + 0.1*E + 0.05*M))
data <- data.frame(E = E, M = M, O = O)

# Fit models
mod_M <- glmmTMB(M ~ E, family = poisson, data = data)
mod_O <- glmmTMB(O ~ E + M, family = binomial, data = data)

# Extract predictions
preds <- indirect_predictions(
  model_mediator = mod_M,
  model_outcome = mod_O,
  exposure_var = "E",
  mediator_var = "M",
  data = data
)

# Visualize indirect effect
plot_indirect_effect(
  preds$pred_O_M,
  preds$pred_O_ME,
  mediator_var = "M",
  exposure_var = "E",
  title = "Indirect effect of E on O through M"
)
```

## Key Features

- **Three use cases supported:**
  1. Simple mediation (E → M → O)
  2. Interacting predictors (E1*E2 → M → O)
  3. Interaction as mediator (E → M1*M2 → O)

- **Easy-to-use functions:**
  - `indirect_predictions()` - Extract predictions for simple mediation
  - `indirect_predictions_interaction()` - Handle interacting predictors
  - `indirect_predictions_mediator_interaction()` - Handle mediator interactions
  - `plot_direct_effect()` - Plot direct effects
  - `plot_indirect_effect()` - Visualize indirect pathways

- **Publication-ready plots:**
  - Customizable colors and themes
  - Matches manuscript figure style
  - Built on ggplot2 for easy modification

## Use Cases

### Case 1: Simple Mediation

Visualize how an exposure (E) affects an outcome (O) through a mediator (M).

```r
preds <- indirect_predictions(mod_M, mod_O, "E", "M", data)
plot_indirect_effect(preds$pred_O_M, preds$pred_O_ME, "M", "E")
```

### Case 2: Interacting Predictors

Show indirect effects when two exposures interact (E1*E2 → M → O).

```r
preds <- indirect_predictions_interaction(
  mod_M, mod_O, "E1", "E2", "M", data,
  exposure1_values = c(-1, 0, 1)
)
plot_indirect_interaction(preds$pred_O_ME1E2, "M", "E1", "E2")
```

### Case 3: Interaction as Mediator

Visualize when exposure affects two mediators that interact (E → M1*M2 → O).

```r
preds <- indirect_predictions_mediator_interaction(
  mod_M1, mod_M2, mod_O, "E", "M1", "M2", data
)
plot_indirect_mediator_interaction(
  preds$pred_O_M1M2, preds$pred_O_M1M2E,
  "M1", "M2", "E"
)
```

## Why Use indRect?

Traditional path analysis provides standardized coefficients for indirect effects, but these can be hard to interpret, especially with:

- Non-linear relationships (GLMs with link functions)
- Count data (Poisson regression)
- Binary outcomes (logistic regression)

`indRect` provides **intuitive visualizations** that show:
- The magnitude of indirect effects on the response scale
- How different exposure levels map to outcome probabilities
- The portion of the mediator-outcome relationship influenced by exposure

## Documentation

For detailed examples and explanations, see:

```r
# View the main vignette
vignette("indirect-effects", package = "indRect")

# Function documentation
?indirect_predictions
?plot_indirect_effect
```

## Testing

The package includes comprehensive unit tests. To run them:

```r
# Load the package
library(testthat)
library(indRect)

# Run all tests
test_check("indRect")
```

## Dependencies

Required packages:
- `marginaleffects` - For model predictions
- `ggplot2` - For plotting
- `dplyr` - For data manipulation
- `tibble` - For data structures
- `scales` - For color palettes
- `patchwork` - For combining plots

Suggested packages:
- `glmmTMB` - For fitting GLMMs (used in examples)
- `testthat` - For unit tests
- `knitr`, `rmarkdown` - For vignettes

## Citation

If you use this package in your research, please cite:

Bush-Beaupré, A., Bélisle, M., & Coroller-Chouraki, S. (2025). Extending the causal inference toolkit for ecologists: A visualization method of indirect effects. *Methods in Ecology and Evolution*.

## Development

This package was developed as part of research on Tree Swallows (*Tachycineta bicolor*) and their ectoparasites at Université de Sherbrooke.

### Package Structure

```
indRect/
├── R/                    # Function definitions
│   ├── predictions.R     # Prediction extraction functions
│   └── plotting.R        # Plotting functions
├── tests/                # Unit tests
│   └── testthat/
├── vignettes/            # Documentation and examples
├── man/                  # Function documentation (auto-generated)
├── DESCRIPTION           # Package metadata
├── NAMESPACE             # Exported functions (auto-generated)
└── README.md             # This file
```

## License

MIT License - see LICENSE file for details

## Contact

Allen Bush-Beaupré  
Université de Sherbrooke  
Email: allen.bush-beaupre@usherbrooke.ca

## Contributing

Contributions, bug reports, and feature requests are welcome! Please file an issue or submit a pull request.
