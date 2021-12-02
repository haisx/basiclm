# basiclm

<!-- badges: start -->
[![R-CMD-check](https://github.com/haisx/basiclm/workflows/R-CMD-check/badge.svg)](https://github.com/haisx/basiclm/actions)

[![codecov](https://codecov.io/gh/haisx/basiclm/branch/main/graph/badge.svg?token=uHnRthKzdt)](https://codecov.io/gh/haisx/basiclm)
<!-- badges: end -->



## Motivation
### Biostat 625 HW4
The goal of making this package is to get familiar with R package, and at the same time, trying to simplify the process of accessing the numeric key statistics in `lm()`. 
The `linear_model()` with `detailed = TRUE` can return a list of important statistics directly. In that way, we does not need to use `summary()` on `lm()` to show the results and then use complex indies to access the numeric values.

## Installation
```
# If not have devtools installed, it is recommended
install.packages('devtools')

devtools::install_github("haisx/basiclm", build_vignettes = T)
library("basiclm")
```
There is only one function `linear_model()` in `basiclm` package.

## Features
The `basiclm` package contains `linear_model()` which achieves the basic functionality of `lm()`. The function need to take the argument `formula` with all numeric variables and optional argument `data`, `digit`, and `detailed`. Without using `detailed = TRUE`, the function will return the function call and coefficients just like what `lm()` does. If we use a `detailed = TRUE`, we will get a list of numeric key values returned, which are the same values we can see in `summary(lm())` and `confint()`.

## Tests
The `linear_model()` function is tested compared with `lm()` function so that we can prove that it output correct and stable results when handle the numeric data. Each output statistics are tested in the tests. You can find them at testthat directory under tests directory. The tests mainly use `iris` data as sample data and random generated data by `runif()` as other simulated data to prove the correctness of the functionality. In the Vignette, we also compared the performance and efficiency of `linear_model()` function with `lm()` function.


## Examples

```
set.seed(222)
x = runif(500000, 1, 10000)
y = runif(500000, 1, 10000)
linear_model(y~x, detailed = TRUE)
linear_model(y~x + I(x^2), digit = 3, detailed = FALSE)
```

`linear_model(iris$Petal.Length~iris$Sepal.Width)`

`linear_model(Petal.Length~Sepal.Width, data=iris, detailed = T)`

`linear_model(Petal.Length~Sepal.Width, data=iris, digit = 8, detailed = F)`

To access the values, we can use `$` directly like following,

`linear_model(Petal.Length~Sepal.Width, data=iris, detailed = T)$Rsq`

`linear_model(Petal.Length~Sepal.Width, data=iris, detailed = T)$P`

More specific examples can be viewed at `browseVignettes("basiclm")`
