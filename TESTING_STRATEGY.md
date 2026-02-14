# Testing Strategy and Recommendations for ggpop

This document provides guidance on maintaining and expanding the test suite for the ggpop package.

---

## Current Test Infrastructure

### Test Files Overview

```
tests/testthat/
├── test-01_geom_pop-warnings.R           # Parameter conflicts, faceting, DPI
├── test-02_geom_pop-errors.R             # Input validation, integration errors
├── test-03_geom_pop-checkpass.R          # Valid usage patterns
├── test-04_geom_pop-cowplot.R            # Multi-panel integration
├── test-05_geom_icon_point-warnings.R    # Size, DPI, alpha warnings
├── test-06_geom_icon_point-errors.R      # Validation, coordinates, legends
├── test-07_geom_icon_point-checkpass.R   # Basic plots, aesthetics
├── test-08_process_data.R                # Data processing basics
├── test-09_helper-functions.R            # ✨ NEW: Helper function units
├── test-10_process_data-advanced.R       # ✨ NEW: Edge cases, hierarchies
└── test-11_advanced-scenarios.R          # ✨ NEW: Layers, facets, themes
```

### Coverage Statistics

- **Total Test Cases:** ~393
- **Coverage Areas:**
  - Error handling: Comprehensive ✅
  - Warning systems: Comprehensive ✅
  - Valid scenarios: Good ✅
  - Helper functions: Good ✅
  - Edge cases: Good ✅
  - Advanced patterns: Good ✅

---

## Running Tests

### Full Test Suite

```r
# Run all tests
testthat::test_dir("tests/testthat")

# Run with detailed output
testthat::test_dir("tests/testthat", reporter = "progress")

# Run specific test file
testthat::test_file("tests/testthat/test-09_helper-functions.R")
```

### Code Coverage

```r
# Install covr if needed
install.packages("covr")

# Run coverage analysis
covr::package_coverage()

# Generate HTML report
report <- covr::package_coverage()
covr::report(report)
```

### Continuous Integration

Add to your CI pipeline (e.g., GitHub Actions):

```yaml
- name: Run tests
  run: |
    R -e 'testthat::test_dir("tests/testthat", reporter = "summary")'
    
- name: Coverage
  run: |
    R -e 'covr::codecov()'
```

---

## Test Writing Guidelines

### 1. Error Tests

**Do:** Test that errors are thrown for invalid inputs

```r
testthat::test_that("Error: invalid dpi", {
  testthat::expect_error(
    ggplot(df) + geom_icon_point(aes(x = x, y = y), dpi = "high")
  )
})
```

**Don't:** Match exact error messages (they may change)

```r
# ❌ Avoid this
testthat::expect_error(..., regexp = "DPI must be numeric between 25 and 600")

# ✅ Do this instead
testthat::expect_error(...)
```

### 2. Warning Tests

**Do:** Test that warnings are emitted

```r
testthat::test_that("Warning: size conflict", {
  testthat::expect_warning(
    ggplot(df, aes(x = x, y = y, size = s)) + 
      geom_icon_point(size = 10)
  )
})
```

### 3. Valid Scenario Tests

**Do:** Test that valid inputs produce expected outputs

```r
testthat::test_that("Basic plot works", {
  p <- ggplot(df, aes(x = x, y = y, icon = icon)) + 
    geom_icon_point()
  
  testthat::expect_s3_class(p, "ggplot")
  
  # Can also build to verify no errors
  built <- ggplot_build(p)
  testthat::expect_true(!is.null(built))
})
```

### 4. Helper Function Tests

**Do:** Test internal functions directly

```r
testthat::test_that("detect_legend_variable works", {
  mapping <- list(color = rlang::sym("category"))
  
  result <- ggpop:::detect_legend_variable(mapping, df)
  
  testthat::expect_equal(result, "category")
})
```

---

## Adding New Tests

### When to Add Tests

Add tests when:
1. Adding new features
2. Fixing bugs (add test that would have caught it)
3. Receiving user bug reports
4. Identifying edge cases
5. Improving error messages

### Test Structure Template

```r
# *****************************************************************************
#
# Script: test-XX_feature-name.R
#
# Purpose: Brief description of what's tested
#
# Author: Your Name
#
# Date Created: YYYY-MM-DD
#
# *****************************************************************************

# Load required packages
testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")

# Test fixtures
df_test <- data.frame(
  x = 1:5,
  y = 1:5,
  icon = "circle"
)

# Test cases
testthat::test_that("Feature works as expected", {
  # Arrange
  # Act
  # Assert
})

# END
```

---

## Test Maintenance

### Regular Maintenance Tasks

**Monthly:**
- Run full test suite
- Check for flaky tests
- Update fixtures if data structures change

**Quarterly:**
- Review code coverage
- Identify gaps in test coverage
- Update test data for edge cases

**Release:**
- Run tests on multiple R versions
- Run tests on multiple platforms (Windows, Mac, Linux)
- Check CRAN checks pass

### Handling Flaky Tests

If a test fails intermittently:

1. Add `set.seed()` for reproducibility
2. Use `skip_on_cran()` if environment-dependent
3. Increase timeouts for slow operations
4. Mock external dependencies

Example:
```r
testthat::test_that("Random shuffle is reproducible", {
  set.seed(123)
  result1 <- my_shuffle_function(data)
  
  set.seed(123)
  result2 <- my_shuffle_function(data)
  
  testthat::expect_equal(result1, result2)
})
```

---

## Priority Test Additions

### High Priority (Recommended)

1. **Icon Cache Tests**
   ```r
   # test-12_icon-cache.R
   - Cache directory creation
   - Cache key generation
   - Cache invalidation
   - Concurrent access
   ```

2. **Icon Utilities Tests**
   ```r
   # test-13_icon-utils.R
   - generate_icon_png()
   - normalize_color()
   - create_rgba_color()
   - get_row_color() / get_row_alpha()
   ```

3. **Validator Function Tests**
   ```r
   # test-14_validators.R
   - validate_single_geom_pop()
   - warn_mixed_legend_icons()
   - Individual warning functions
   ```

### Medium Priority (Nice to Have)

1. **Performance Tests**
   ```r
   # test-15_performance.R
   - Benchmark large datasets
   - PNG generation speed
   - Cache overhead
   ```

2. **Visual Regression Tests**
   ```r
   # test-16_visual-regression.R
   - Use vdiffr package
   - Compare plot outputs
   - Detect rendering changes
   ```

### Low Priority (Future)

1. Integration with other packages (plotly, patchwork)
2. Accessibility tests (color-blind palettes)
3. Cross-version compatibility tests

---

## Common Test Patterns

### Pattern 1: Testing Both Data Patterns

geom_icon_point accepts data in two ways:

```r
# Pattern 1: Data in ggplot()
ggplot(data, aes(x = x, y = y)) + geom_icon_point(aes(icon = icon))

# Pattern 2: Data in geom
ggplot() + geom_icon_point(data = data, aes(x = x, y = y, icon = icon))
```

Test both:

```r
testthat::test_that("Works with ggplot data pattern", {
  p <- ggplot(df, aes(x = x, y = y, icon = icon)) + geom_icon_point()
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("Works with geom data pattern", {
  p <- ggplot() + geom_icon_point(data = df, aes(x = x, y = y, icon = icon))
  testthat::expect_s3_class(p, "ggplot")
})
```

### Pattern 2: Testing Parameter Boundaries

Test at boundaries and just outside:

```r
testthat::test_that("size = 0.5 (boundary) does not warn", {
  testthat::expect_no_warning(
    ggplot(df) + geom_icon_point(aes(x = x, y = y, icon = icon), size = 0.5)
  )
})

testthat::test_that("size = 0.49 triggers warning", {
  testthat::expect_warning(
    ggplot(df) + geom_icon_point(aes(x = x, y = y, icon = icon), size = 0.49)
  )
})
```

### Pattern 3: Testing Facets

```r
testthat::test_that("Works with facet_wrap", {
  df$facet_var <- rep(c("A", "B"), each = 5)
  
  p <- ggplot(df, aes(x = x, y = y, icon = icon)) +
    geom_icon_point() +
    facet_wrap(~ facet_var)
  
  testthat::expect_s3_class(p, "ggplot")
  built <- ggplot_build(p)
  testthat::expect_true(!is.null(built))
})
```

---

## Troubleshooting Tests

### Test Fails on CI but Passes Locally

**Possible causes:**
- Different R version
- Missing dependencies
- Environment-specific behavior
- Random seed not set

**Solutions:**
```r
# Use skip_on_cran() for flaky tests
testthat::skip_on_cran()

# Set seed for reproducibility
set.seed(123)

# Check R version
testthat::skip_if(getRversion() < "4.0.0")

# Check package version
testthat::skip_if_not_installed("ggplot2", minimum_version = "3.4.0")
```

### Test Takes Too Long

**Solutions:**
```r
# Skip slow tests on CRAN
testthat::skip_on_cran()

# Use smaller datasets
df_small <- df[1:10, ]

# Mock expensive operations
mockery::stub(my_function, "expensive_call", return_value)
```

### Tests Interfere with Each Other

**Solutions:**
```r
# Use separate fixtures per test
testthat::test_that("Test 1", {
  df_test <- create_test_data()  # Fresh copy
  # ...
})

# Clean up after tests
testthat::test_that("Test with cleanup", {
  tmp_file <- tempfile()
  # ... use tmp_file ...
  unlink(tmp_file)  # Cleanup
})
```

---

## Resources

### R Testing Resources

- [testthat documentation](https://testthat.r-lib.org/)
- [R Packages book - Testing chapter](https://r-pkgs.org/testing-basics.html)
- [covr package](https://covr.r-lib.org/)

### ggplot2 Testing

- [ggplot2 test suite](https://github.com/tidyverse/ggplot2/tree/main/tests/testthat)
- [vdiffr for visual regression](https://github.com/r-lib/vdiffr)

### CI/CD

- [GitHub Actions for R](https://github.com/r-lib/actions)
- [usethis::use_github_action()](https://usethis.r-lib.org/reference/github_actions.html)

---

## Questions?

For questions about testing:
1. Check existing tests for similar patterns
2. Review this document
3. Consult testthat documentation
4. Ask in GitHub issues or discussions

**Maintainer Contact:** See DESCRIPTION file

---

**Document Version:** 1.0  
**Last Updated:** February 14, 2026  
**Status:** Active
