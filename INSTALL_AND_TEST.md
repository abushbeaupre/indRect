# Installation and Testing Script for indRect Package

## Quick Installation

To install the package from your local directory:

```r
# Option 1: Install from source (recommended)
install.packages("/home/abush/working_vol/indRect", 
                 repos = NULL, 
                 type = "source")

# Option 2: Using devtools
devtools::install_local("/home/abush/working_vol/indRect")

# Option 3: Using remotes
remotes::install_local("/home/abush/working_vol/indRect")
```

## Verify Installation

```r
# Load the package
library(indRect)

# Check package version
packageVersion("indRect")

# List all exported functions
ls("package:indRect")

# Should show:
# [1] "indirect_predictions"
# [2] "indirect_predictions_interaction"
# [3] "indirect_predictions_mediator_interaction"
# [4] "plot_direct_effect"
# [5] "plot_indirect_effect"
# [6] "plot_indirect_interaction"
# [7] "plot_indirect_mediator_interaction"
```

## Run Quick Test

```r
# Load required packages
library(indRect)
library(glmmTMB)
set.seed(333)

# Simulate simple data
n <- 500
E <- rnorm(n, 0, 1)
M <- rpois(n, exp(4 + 0.1*E))
O <- rbinom(n, 1, plogis(-3 + 0.1*E + 0.05*M))
data <- data.frame(E = E, M = M, O = O)

# Fit models
mod_M <- glmmTMB(M ~ E, family = poisson, data = data)
mod_O <- glmmTMB(O ~ E + M, family = binomial, data = data)

# Extract predictions (should run without errors)
preds <- indirect_predictions(mod_M, mod_O, "E", "M", data, n_points = 20)

# Create plot (should display a ggplot)
p <- plot_indirect_effect(preds$pred_O_M, preds$pred_O_ME, "M", "E",
                         title = "Test: Indirect effect")
print(p)

# If you see a plot with colored lines, installation successful!
```

## Run Full Test Suite

```r
# Install with tests
install.packages("/home/abush/working_vol/indRect", 
                 repos = NULL, 
                 type = "source",
                 INSTALL_opts = "--install-tests")

# Run all unit tests
library(testthat)
library(indRect)
test_package("indRect")

# Expected output:
# ✔ | F W S  OK | Context
# ✔ |         3 | plotting
# ✔ |         6 | predictions
# 
# ══ Results ═════════════════════════════════════════════════
# Duration: X.X s
# 
# [ FAIL 0 | WARN 0 | SKIP 0 | PASS 9 ]
```

## Build Package Documentation

If you want to rebuild documentation (after modifying functions):

```r
# Install roxygen2
install.packages("roxygen2")

# Set working directory to package root
setwd("/home/abush/working_vol/indRect")

# Build documentation
roxygen2::roxygenise()

# Build and check package
devtools::document()
devtools::check()
```

## View Documentation

```r
# View main vignette
vignette("indirect-effects", package = "indRect")

# View function help
?indirect_predictions
?plot_indirect_effect

# View package overview
help(package = "indRect")
```

## Common Installation Issues

### Issue: Missing dependencies

```r
# Install all required packages
install.packages(c("marginaleffects", "ggplot2", "dplyr", 
                   "tibble", "scales", "patchwork"))

# Install suggested packages
install.packages(c("glmmTMB", "testthat", "knitr", "rmarkdown"))
```

### Issue: Namespace conflicts

```r
# Unload package first
detach("package:indRect", unload = TRUE)

# Then reinstall
install.packages("/home/abush/working_vol/indRect", 
                 repos = NULL, type = "source")
```

### Issue: Permission errors

```r
# Install to user library
install.packages("/home/abush/working_vol/indRect", 
                 repos = NULL, 
                 type = "source",
                 lib = .libPaths()[1])
```

## Development Workflow

If you want to modify the package:

1. **Edit function files** in `R/`
2. **Update documentation** with roxygen2 comments
3. **Rebuild documentation**: `devtools::document()`
4. **Run tests**: `devtools::test()`
5. **Check package**: `devtools::check()`
6. **Reinstall**: `devtools::install()`

## Distribution

To share the package with others:

```r
# Build source package
devtools::build("/home/abush/working_vol/indRect")

# This creates: indRect_0.1.0.tar.gz

# Others can install with:
install.packages("path/to/indRect_0.1.0.tar.gz", 
                 repos = NULL, type = "source")
```

## Getting Help

- **README**: `/home/abush/working_vol/indRect/README.md`
- **Quick Reference**: `/home/abush/working_vol/indRect/QUICK_REFERENCE.md`
- **Vignette**: Run `vignette("indirect-effects", package = "indRect")`
- **Examples**: See `MEE_simulations.qmd` for original code
- **Contact**: allen.bush-beaupre@usherbrooke.ca
