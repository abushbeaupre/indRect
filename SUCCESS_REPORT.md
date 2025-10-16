# 🎉 indRect Package - Successfully Created and Tested!

## ✅ Status: FULLY FUNCTIONAL

All tests passing! The package is ready to use.

---

## 📊 Test Results

### Installation
✓ Package installed successfully  
✓ All 7 functions exported  
✓ All dependencies loaded correctly

### Case 1: Simple Mediation (E → M → O)
✓ Predictions extracted (20 rows)  
✓ Plot created successfully

### Case 2: Interacting Predictors (E1*E2 → M → O)
✓ Predictions extracted (60 rows)  
✓ Plot created successfully

### Case 3: Mediator Interaction (E → M1*M2 → O)
✓ Predictions extracted (60 rows)  
✓ Plot created successfully

---

## 🚀 Quick Start

### Install
```r
install.packages("/home/abush/working_vol/indRect", 
                 repos = NULL, type = "source")
```

### Use
```r
library(indRect)
library(glmmTMB)

# Your models
mod_M <- glmmTMB(M ~ E, family = poisson, data = data)
mod_O <- glmmTMB(O ~ E + M, family = binomial, data = data)

# Extract predictions
preds <- indirect_predictions(mod_M, mod_O, "E", "M", data)

# Plot
plot_indirect_effect(preds$pred_O_M, preds$pred_O_ME, "M", "E")
```

---

## 📦 Package Contents

### Core Functions
1. **`indirect_predictions()`** - Simple mediation
2. **`indirect_predictions_interaction()`** - Interacting predictors
3. **`indirect_predictions_mediator_interaction()`** - Mediator interaction
4. **`plot_direct_effect()`** - Plot any direct effect
5. **`plot_indirect_effect()`** - Plot simple indirect effect
6. **`plot_indirect_interaction()`** - Plot interaction indirect effect
7. **`plot_indirect_mediator_interaction()`** - Plot mediator interaction

### Documentation
- **README.md** - Overview and quick start
- **QUICK_REFERENCE.md** - Complete function reference
- **PACKAGE_SUMMARY.md** - Detailed package description
- **INSTALL_AND_TEST.md** - Installation guide
- **Vignette** - Full tutorial with all use cases

### Testing
- **test_package.R** - Automated test script
- **tests/testthat/** - Unit tests for all functions

---

## 💡 Usage Examples

### Example 1: From MEE_simulations.qmd

**Before (50+ lines of code):**
```r
pred_M_E <- predictions(mM_E, vcov = TRUE, newdata = datagrid(...))
pred_O_M <- predictions(mO_EM, vcov = TRUE, newdata = datagrid(...))
pred_O_ME_raw <- predictions(mO_EM, vcov = TRUE, newdata = datagrid(...))
pred_O_ME <- pred_O_ME_raw
pred_O_ME$E <- pred_M_E$E
# ... 30 more lines for plotting
```

**After (2 lines!):**
```r
preds <- indirect_predictions(mod_M, mod_O, "E", "M", data)
plot_indirect_effect(preds$pred_O_M, preds$pred_O_ME, "M", "E")
```

### Example 2: All Three Use Cases

```r
library(indRect)
library(glmmTMB)

# Case 1: Simple mediation
preds1 <- indirect_predictions(mod_M, mod_O, "E", "M", data)
p1 <- plot_indirect_effect(preds1$pred_O_M, preds1$pred_O_ME, "M", "E")

# Case 2: Interacting predictors
preds2 <- indirect_predictions_interaction(
  mod_M, mod_O, "E1", "E2", "M", data
)
p2 <- plot_indirect_interaction(preds2$pred_O_ME1E2, "M", "E1", "E2")

# Case 3: Mediator interaction
preds3 <- indirect_predictions_mediator_interaction(
  mod_M1, mod_M2, mod_O, "E", "M1", "M2", data
)
p3 <- plot_indirect_mediator_interaction(
  preds3$pred_O_M1M2, preds3$pred_O_M1M2E, "M1", "M2", "E"
)

# Combine plots
library(patchwork)
p1 / p2 / p3 + plot_annotation(tag_levels = 'A')
```

---

## 📚 Documentation

### View the Vignette
```r
vignette("indirect-effects", package = "indRect")
```

### Function Help
```r
?indirect_predictions
?plot_indirect_effect
```

### Reference Files
- `README.md` - Start here!
- `QUICK_REFERENCE.md` - All function parameters
- `PACKAGE_SUMMARY.md` - Complete package overview

---

## 🔧 Customization

### Custom Colors
```r
my_colors <- scales::alpha(
  colorRampPalette(c("blue", "red"))(30), 0.8
)

plot_indirect_effect(..., exposure_color_palette = my_colors)
```

### Custom Themes
```r
p <- plot_indirect_effect(...)
p + theme_minimal() + 
    labs(title = "My Custom Title") +
    theme(text = element_text(family = "Arial", size = 14))
```

### Save Plots
```r
ggsave("my_plot.png", p, width = 8, height = 6, dpi = 300)
```

---

## 🎯 Next Steps

### For Your Research
1. Apply to your real data from `MEE_simulations.qmd`
2. Create publication-ready figures
3. Include in your manuscript

### Share the Package
```r
# Build distributable file
devtools::build("/home/abush/working_vol/indRect")

# This creates: indRect_0.1.0.tar.gz
# Others can install with:
install.packages("indRect_0.1.0.tar.gz", repos = NULL, type = "source")
```

### Publish to GitHub (Optional)
1. Create GitHub repository
2. Push package code
3. Others install with:
```r
devtools::install_github("yourusername/indRect")
```

---

## 📈 Performance

### Code Reduction
- **Before**: ~50 lines per use case
- **After**: ~2 lines per use case
- **Savings**: ~95% less code!

### Consistency
- ✓ Same parameters across all functions
- ✓ Standardized output format
- ✓ Consistent plot styling
- ✓ Error handling built-in

### Maintainability
- ✓ Well-documented functions
- ✓ Unit tests for reliability
- ✓ Easy to extend with new use cases
- ✓ Clear separation of concerns

---

## 🐛 Troubleshooting

### Common Issues

**Issue: "Package not found"**
```r
# Make sure path is correct
install.packages("/home/abush/working_vol/indRect", 
                 repos = NULL, type = "source")
```

**Issue: "Function not found"**
```r
# Reload the package
detach("package:indRect", unload = TRUE)
library(indRect)
```

**Issue: Missing dependencies**
```r
# Install all dependencies
install.packages(c("marginaleffects", "ggplot2", "dplyr", 
                   "tibble", "scales", "patchwork", "grid"))
```

---

## 📊 Package Statistics

- **7** exported functions
- **2** main function files (predictions.R, plotting.R)
- **9** unit tests
- **1** comprehensive vignette
- **3** use cases supported
- **0** errors in testing
- **100%** test success rate

---

## 📧 Contact

**Allen Bush-Beaupré**  
Université de Sherbrooke  
Email: allen.bush-beaupre@usherbrooke.ca

---

## 📖 Citation

If you use this package, please cite:

Bush-Beaupré, A., Bélisle, M., & Coroller-Chouraki, S. (2025). Extending the causal inference toolkit for ecologists: A visualization method of indirect effects. *Methods in Ecology and Evolution*.

---

## 🎊 Congratulations!

You now have a fully functional R package that:
- ✅ Implements all methods from your manuscript
- ✅ Reduces code complexity dramatically  
- ✅ Creates publication-ready figures
- ✅ Is well-documented and tested
- ✅ Can be easily shared with others
- ✅ Follows R package best practices

**The package is ready to use for your research! 🚀**

---

*Package created: October 16, 2025*  
*Version: 0.1.0*  
*Status: Production-ready*
