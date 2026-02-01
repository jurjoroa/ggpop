# Branch Comparison: Current Branch vs Dev

**Date:** February 1, 2026  
**Current Branch:** `copilot/compare-dev-branch-changes` (based on `223-add-unit-tests-geom_point_icon`)  
**Comparison Branch:** `Dev`

---

## Executive Summary

This document provides a comprehensive comparison between the current working branch (`copilot/compare-dev-branch-changes`) and the `Dev` branch. The two branches have **diverged significantly** and represent different feature development paths:

- **Current Branch Base (`223-add-unit-tests-geom_point_icon`)**: Focuses on adding comprehensive unit tests and validation for `geom_icon_point` functionality, including legend handling, alpha parameter validation, and test infrastructure improvements.

- **Dev Branch**: Contains extensive enhancements to `geom_pop` functionality, including parameter validation, error handling, the addition of `stroke_width` feature, DPI cache fixes, and comprehensive test coverage improvements.

### Key Statistics

- **Current Branch:** 1 commit ahead of base (223 branch)
- **Dev Branch:** Latest commit from January 26, 2026
- **Divergence Point:** These branches share different recent development histories
- **Files Modified in Dev:** 5 main files (R/draw_key.R, R/geom_pop.R, and 3 test files)
- **Total Changes in Dev:** +1659 additions, -58 deletions across the merge commit

---

## Current Branch Details

### Base: Branch `223-add-unit-tests-geom_point_icon`

**Latest Commit:** `b46a915` - "Use explicit devices in tests; remove legend test"

#### Recent Commits on 223 Branch (Jan 31 - Feb 1, 2026):

1. **b46a915** (2026-02-01): Use explicit devices in tests; remove legend test
   - Wrapped ggplot print calls in explicit graphics devices (pdf(NULL) or png(tempfile))
   - Prevents warnings/failures in non-interactive/CI environments
   - Removed duplicate/flaky "Legend: icons disabled (FALSE)" test
   - Files: `tests/testthat/test-05_geom_icon_point-warnings.R`, `tests/testthat/test-07_geom_icon_point-checkpass.R`
   - Changes: +35 additions, -26 deletions

2. **cfc8f42** (2026-02-01): Remove demo examples from geom_icon_point test
   - Pruned large blocks of demo/example plotting code
   - Reduced test clutter and improved CI speed
   - File: `tests/testthat/test-07_geom_icon_point-checkpass.R`

3. **cfb15b1** (2026-02-01): Warn on mixed legend_icons across geom_icon_point
   - Added global `.ggpop_legend_settings` registry to track legend_icons settings
   - Emits warning when TRUE/FALSE settings are mixed across layers
   - Added tests for mixed-settings warnings
   - Related to Issue #223

4. **9434f7e** (2026-01-31): Align test scripts' header comments to filenames
   - Updated 'Script:' headers in 7 test files to match filenames
   - Cosmetic consistency change only
   - Files: test-01 through test-07

5. **efe9483** (2026-01-31): Expand and reorganize geom_icon_point tests
   - Greatly expanded tests for geom_icon_point
   - Added sections: basic functionality, aesthetics, size, DPI, legend behavior, parameter validation, data input types, themes, integrations, coordinate/facet variations, edge cases, performance
   - Replaced many `expect_no_warning` with `expect_no_error`
   - Added raster grob checks for legend

6. **9f66263** (2026-01-31): Remove regexp arg from geom_icon_point test
   - Removed explicit regexp parameter from expect_error call
   - File: `tests/testthat/test-06_geom_icon_point-errors.R`

7. **169c633** (2026-01-31): Validate and warn on alpha parameter
   - Added strict validation for alpha argument in geom_icon_point
   - Hard-stops for invalid alpha usages (bare names, non-numeric, length != 1, NA, Inf, out-of-range)
   - Soft warning for very low alpha values (< 0.1)
   - Updated warning text to reference geom_icon_point
   - Added extensive tests for alpha behaviors

8. **fff20fd** (2026-01-31): Capture extra args and warn on alpha conflicts
   - Collected variadic arguments via `extra_args <- list(...)`
   - Added warning when alpha is provided both in aes() and as parameter
   - Removed show.legend parameter from function signature

9. **1df8029** (2026-01-31): Skip multi-icon legend check for numeric scales
   - Added guard to skip "multiple icons per legend group" check for numeric (continuous) scales
   - Prevents false-positive warnings for continuous legends

10. **fb0a973** (2026-01-31): Add tests for geom_icon_point real-world cases
    - Created `tests/testthat/test-07_geom_icon_point-checkpass.R`
    - New test suite for real-world usage and edge cases
    - Includes typical usage, layering, faceting, mapping icon+size, edge cases

---

## Dev Branch Details

### Latest Commit: `6edc782` - Merge PR #222

**Summary:** The Dev branch contains a major merge (PR #222) focused on updating unit tests and adding robustness checks for `geom_pop`, along with several feature additions and bug fixes from earlier PRs.

#### Major Changes in Dev Branch (Jan 17-26, 2026):

### 1. **Merge PR #222** (2026-01-26) - Main Integration
   - **Commit:** 6edc782
   - **Issue:** #216 - Update unit test to add robustness checks
   - **Files Modified:** 
     - `R/draw_key.R`: +86 additions, -17 deletions
     - `R/geom_pop.R`: +574 additions, -11 deletions
     - `tests/testthat/test-01_geom_pop-warnings.R`: +176 additions, -21 deletions
     - `tests/testthat/test-02_geom_pop-errors.R`: +489 additions, -7 deletions
     - `tests/testthat/test-03_geom_pop-checkpass.R`: +334 additions, -2 deletions
   - **Total:** +1659 additions, -58 deletions

### 2. **Parameter Validation & Error Handling Enhancements**

#### a. Data Type Validation (Commit: d2b95cd)
   - **Date:** 2026-01-26
   - Added hard check to ensure data argument is data.frame, tibble, or data.table
   - Provides informative error messages and conversion suggestions
   - Added extensive tests for unsupported data types

#### b. Icon Mapping Enforcement (Commit: 8687d05)
   - **Date:** 2026-01-25
   - Requires explicit mapping of 'icon' aesthetic even if column exists in data
   - Added check to ensure mapped icon column exists
   - Improved error messages for missing/incorrect icon mappings
   - Updated tests for new error conditions

#### c. legend_icons Parameter Validation (Commit: fccb763)
   - **Date:** 2026-01-25
   - Added strict validation ensuring single logical value (TRUE/FALSE)
   - Updated tests for invalid legend_icons inputs

#### d. stroke_width Validation (Commit: d4b551a)
   - **Date:** 2026-01-20
   - Strict parameter validation including type, length, and value checks
   - Errors for invalid types, negative, NA, or infinite values
   - Warning for unusually large values (>20)
   - Added corresponding unit tests

#### e. size Parameter Validation (Commit: b2c3e9c)
   - **Date:** 2026-01-19
   - Comprehensive validation including type, length, NA, Inf, and positivity checks
   - Warnings for extreme size values (very small or very large)
   - Informative error messages
   - Updated and expanded tests

#### f. Reserved Column Names Check (Commit: c9187b8)
   - **Date:** 2026-01-19
   - Hard stop if user data contains reserved internal column names
   - Reserved names: x1, y1, pos, image, coord_size, icon_size, icon_stroke_width
   - Detailed error message with example fix
   - Prevents coordinate calculation errors

#### g. arrange Parameter Validation (Commit: 9d47c58)
   - **Date:** 2026-01-18
   - Added validation for arrange parameter
   - Related to comprehensive error testing

#### h. alpha as aes Mapping Enforcement (Commit: 6c0b6d4)
   - **Date:** 2026-01-18
   - Enforces alpha as aes mapping in geom_pop

### 3. **stroke_width Feature Addition** (Merge PR #218 & #219)

#### a. Core Implementation (Commit: a33ff95)
   - **Date:** 2026-01-19
   - **Issue:** #217 - Add feature stroke_width for Font Awesome icon thickness
   - Introduces new `stroke_width` parameter to control outline width around icons
   - Adds hard stops to prevent multiple geom_pop layers per plot
   - Disallows fill aesthetic with clear error messages
   - Updated icon rendering and legend key generation

#### b. Legend Key Support (Commit: b857959)
   - **Date:** 2026-01-18
   - Added stroke_width support to `draw_key_pop_image`
   - Improved color/alpha handling

#### c. Aesthetic Mapping Warning (Commit: 63ad92b)
   - **Date:** 2026-01-19
   - **Issue:** #217
   - Warning when stroke_width is mapped inside aes()
   - Informs users it's a parameter, not an aesthetic
   - Removes stroke_width from mapping to prevent interference
   - Added test for fill aesthetic error (guides to use color instead)

### 4. **DPI Bug Fix** (Merge PR #221)

#### a. Cache Key Fix (Commit: 1c4d149)
   - **Date:** 2026-01-19
   - **Issue:** #220 - Fix bug: DPI not working properly
   - Adds DPI value to cache key for ggpop-icons
   - Ensures icons at different DPIs are cached separately
   - Prevents cache collisions

#### b. DPI Tests (Commit: bda580b)
   - **Date:** 2026-01-19
   - Comprehensive tests for DPI parameter behavior
   - Tests include: PNG resolution, file size scaling, cache filename embedding, cache reuse, cache separation, validation error handling

### 5. **Test Infrastructure Improvements**

#### a. Test Reorganization (Commit: 8fa31ec)
   - **Date:** 2026-01-19
   - Refactored and expanded geom_pop warning tests
   - Added sections: grouping, facet, unsupported aesthetics, DPI values, size parameters, icon-related warnings
   - Improved section headers and test coverage

#### b. Reserved Column Test (Commit: 63bdd54)
   - **Date:** 2026-01-19
   - Added test for reserved column names ('pos', etc.)

#### c. Negative/Zero Size Tests (Commit: 0dd7eeb)
   - **Date:** 2026-01-18
   - Added tests for negative and zero size warnings

#### d. Comprehensive Error Tests (Commit: b37a125)
   - **Date:** 2026-01-18
   - Added comprehensive error tests for geom_pop inputs

#### e. Test Parameter Update (Commit: 3494ba3)
   - **Date:** 2026-01-26
   - Fixed typo and updated size parameter in test
   - Changed 'size' from 0 to 5 in 'Minimal raw mode' test

### 6. **geom_icon_point Addition** (Merge PR #213)

#### a. Core Addition (Commit: 7a7a8b3)
   - **Date:** 2026-01-17
   - **Issue:** #212 - Improvement: plot any data freely
   - Added `geom_icon_point` function
   - Updated documentation

#### b. Argument Handling (Commit: 9317540)
   - **Date:** 2026-01-17
   - Improved argument handling in geom_icon_point

#### c. Legend Documentation (Commit: 746b6bc)
   - **Date:** 2026-01-17
   - Clarified fixed size for legend icons in draw_key_pop_image

#### d. Validation Enhancements (Commit: f03c9d9)
   - **Date:** 2026-01-17
   - Refactored and enhanced geom_icon_point validation and mapping

#### e. Further Refactoring (Commit: 74c6244)
   - **Date:** 2026-01-17
   - Refactored geom_icon_point for improved mapping and validation

### 7. **Bug Fix - Principal Aesthetics** (Merge PR #215)

#### Mapping Check Fix (Commit: 01ecfd6)
   - **Date:** 2026-01-17
   - **Issue:** #214 - Fix bug: geom_pop doesn't work in principal aes
   - Fixed mapping checks to include inherited aesthetics
   - Ensures geom_pop works correctly when aesthetics are set at ggplot() level

---

## Detailed File-Level Changes in Dev Branch

### 1. **R/draw_key.R**
   - **Changes:** +86 additions, -17 deletions (103 total changes)
   - **Purpose:** Updated legend key drawing functions
   - **Key Updates:**
     - Added stroke_width parameter support
     - Improved color and alpha handling for legend icons
     - Fixed size handling for legend icons

### 2. **R/geom_pop.R**
   - **Changes:** +574 additions, -11 deletions (585 total changes)
   - **Purpose:** Core geom_pop function enhancements
   - **Major Updates:**
     - Added `stroke_width` parameter
     - Comprehensive validation for all parameters (data, icon, legend_icons, stroke_width, size, arrange)
     - Reserved column names checking
     - Improved error messages and user guidance
     - DPI cache key fix
     - Aesthetic mapping improvements (alpha, stroke_width warnings)
     - Prevention of multiple geom_pop layers
     - Disallow fill aesthetic with guidance to use color
     - Fixed inherited aesthetics handling

### 3. **tests/testthat/test-01_geom_pop-warnings.R**
   - **Changes:** +176 additions, -21 deletions (197 total changes)
   - **Purpose:** Warning test cases
   - **Updates:**
     - Reorganized test structure with clear sections
     - Added tests for: grouping, facet, unsupported aesthetics, DPI values, size parameters (negative, zero, extreme), stroke_width warnings, icon-related warnings
     - Improved test descriptions

### 4. **tests/testthat/test-02_geom_pop-errors.R**
   - **Changes:** +489 additions, -7 deletions (496 total changes)
   - **Purpose:** Error test cases
   - **Updates:**
     - Extensive validation tests for all parameters
     - Data type validation tests (vectors, lists, matrices, NULL, unsupported types)
     - Icon mapping tests (missing, incorrect, non-explicit mapping)
     - legend_icons validation tests
     - stroke_width validation tests
     - size parameter validation tests
     - arrange parameter validation tests
     - Reserved column names tests
     - Multiple layer prevention tests
     - fill aesthetic error tests
     - alpha parameter validation tests

### 5. **tests/testthat/test-03_geom_pop-checkpass.R**
   - **Changes:** +334 additions, -2 deletions (336 total changes)
   - **Purpose:** Positive test cases (should pass without errors)
   - **Updates:**
     - Added comprehensive passing scenarios
     - DPI parameter tests (cache behavior, resolution, separation)
     - Valid parameter combinations
     - Explicit icon mapping tests
     - stroke_width functionality tests
     - Data type acceptance tests (data.frame, tibble, data.table)

---

## Key Differences Summary

### Feature Focus:
- **Current Branch (223):** Focuses on `geom_icon_point` testing, validation, and legend handling
- **Dev Branch:** Focuses on `geom_pop` enhancements, validation, and new stroke_width feature

### Testing Approach:
- **Current Branch:** Added 10 commits enhancing geom_icon_point tests, including real-world scenarios, alpha validation, legend conflict warnings, and CI environment handling
- **Dev Branch:** Added 17+ commits with comprehensive test coverage for geom_pop, including parameter validation, error handling, DPI tests, and integration tests

### Code Quality:
- **Both branches** emphasize robust error handling, clear user messages, and comprehensive test coverage
- **Both branches** address CI/testing environment issues
- **Dev branch** has more extensive parameter validation infrastructure

### Major Functional Differences:
1. **Dev has stroke_width feature** for controlling icon outline thickness - Current branch does not
2. **Dev has DPI cache fix** - Current branch may still have DPI cache collision issues
3. **Dev has comprehensive geom_pop validation** (data types, reserved columns, parameter validation) - Current branch validation is in geom_icon_point
4. **Current has geom_icon_point legend conflict detection** - Dev branch does not have this feature
5. **Current has explicit graphics device handling in tests** - Dev branch may need this for CI stability

### Potential Integration Challenges:
1. Both branches modify test files extensively - merge conflicts likely
2. Different validation philosophies may need reconciliation
3. Both address similar testing infrastructure needs differently
4. geom_icon_point and geom_pop development happening in parallel

---

## Recommendations

### For Integration:
1. **Merge Strategy:** Consider rebasing current branch onto Dev to incorporate all Dev improvements
2. **Test Conflicts:** Carefully review test file conflicts - both have valuable additions
3. **Validation Consistency:** Align validation approaches between geom_pop and geom_icon_point
4. **Graphics Device Handling:** Port the explicit device handling from current branch to Dev tests
5. **Feature Port:** Consider porting legend conflict detection to Dev branch

### For Going Forward:
1. **Merge Dev into Current:** Recommended to get stroke_width, DPI fix, and validation improvements
2. **Preserve Current Additions:** Keep geom_icon_point improvements and legend conflict detection
3. **Test Suite Unification:** Consolidate test improvements from both branches
4. **Documentation:** Update documentation to reflect all new features and validations

---

## Conclusion

The current branch and Dev branch represent significant parallel development efforts, each adding valuable functionality and robustness to the ggpop package:

- **Dev Branch** excels in parameter validation, error handling, and the addition of the stroke_width feature for geom_pop
- **Current Branch (223)** excels in comprehensive geom_icon_point testing and legend conflict detection

Both branches improve code quality, test coverage, and user experience. Integration will require careful attention to test file conflicts and validation consistency, but the combined result will be a significantly more robust and feature-rich package.

**Total Impact:**
- **Dev Branch:** ~1,700+ line changes focused on geom_pop
- **Current Branch:** ~200+ line changes focused on geom_icon_point
- **Combined Value:** Comprehensive improvements to both major geom functions with extensive test coverage

