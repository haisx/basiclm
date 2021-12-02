# basiclm

<!-- badges: start -->
[![R-CMD-check](https://github.com/haisx/basiclm/workflows/R-CMD-check/badge.svg)](https://github.com/haisx/basiclm/actions)

[![codecov](https://codecov.io/gh/haisx/basiclm/branch/main/graph/badge.svg?token=uHnRthKzdt)](https://codecov.io/gh/haisx/basiclm)
<!-- badges: end -->



# Motivation
## Biostat 625 HW4
The goal of making this package is to get familiar with R package, and at the same time, trying to simplify the process of getting the results from `lm()`. The `linear_model()` with `detailed = TRUE` can return a list of important statistics directly. In that way, we does not need to use `summary()` on `lm()` to get the results and then use complex indies to access the values.

# Installation
```
# If not have devtools installed 
install.packages('devtools')

devtools::install_github("haisx/basiclm")
library("basiclm")
```
There is only one function in `basiclm` package.

# Features
The `basiclm` package contains `linear_regression()` which achieves the basic functionality of `lm()`. The function returns need to take the argument `formula` and optional argument `data`, `digit`, and `detailed`. Without `detailed = TRUE`, the function will return the function call and coefficients just like what `lm()` does. If we use a `detailed = TRUE`, we will get a list of numeric key values returned, which we can also get from `summary(lm())` and `confint()`.

# Example
`linear_model(iris$Petal.Length~iris$Sepal.Width)`
`linear_model(Petal.Length~Sepal.Width, data=iris, detailed = T)`
`linear_model(Petal.Length~Sepal.Width, data=iris, digit = 8, detailed = F)`
