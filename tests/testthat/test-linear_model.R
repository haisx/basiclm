test_that("multiplication works", {
  library(basiclm)

  # Use the iris as the test dataset
  # Response variable and explanatory variables should all be numeric

  # Test Petal.Length~Sepal.Width, data = iris (1 independent variable)
  mylm = linear_model(Petal.Length~Sepal.Width, data=iris, detailed = T)
  standardlm = lm(Petal.Length~Sepal.Width, data=iris)

  # Used default digits here (3 digits)
  # Test the coefficient beta0(intercept)
  expect_equal(mylm$Coefficients[1],
               round(as.numeric(standardlm[1]$coefficients[1]),3))

  # Test the coefficient beta1
  expect_equal(mylm$Coefficients[2],
               round(as.numeric(standardlm[1]$coefficients[2]),3))


  # Test iris$Petal.Length~iris$Sepal.Width + iris$Petal.Width
  # (2 independent variable)
  mylm2 = linear_model(iris$Petal.Length~iris$Sepal.Width +
                         iris$Petal.Width, digit = 4)
  standardlm2 = lm(iris$Petal.Length~iris$Sepal.Width +
                     iris$Petal.Width)
  # Used 5 digits here
  # Test the coefficient beta0(intercept)
  expect_equal(mylm2$Coefficients[1],
               round(as.numeric(standardlm2[1]$coefficients[1]),4))

  # Test the coefficient beta1
  expect_equal(mylm2$Coefficients[2],
               round(as.numeric(standardlm2[1]$coefficients[2]),4))

  # Test the coefficient beta2
  expect_equal(mylm2$Coefficients[3],
               round(as.numeric(standardlm2[1]$coefficients[3]),4))


  ## Try more complex situation (with squared terms) and more precise results
  # Test the detailed table statistics
  # (2 independent variable in addition with 1 squared term)
  # Used 8 digits here
  # iris$Petal.Length~iris$Sepal.Width + iris$Petal.Width + I(iris$Petal.Width^2)
  mylm3 = linear_model(iris$Petal.Length~iris$Sepal.Width +
                         iris$Petal.Width + I(iris$Petal.Width^2), detailed = T, digit = 8)
  standardlm3 = lm(iris$Petal.Length~iris$Sepal.Width + iris$Petal.Width + I(iris$Petal.Width^2))

  # Coefficients table
  # Estimates row
  expect_equal(as.numeric(mylm3$Coefficients[,1]),
               round(as.numeric(summary(standardlm3)[4]$coe[,1] ),8))

  # Std error
  expect_equal(as.numeric(mylm3$Coefficients[,2]),
               round(as.numeric(summary(standardlm3)[4]$coe[,2] ),8))

  # 95% CI
  expect_equal(round(as.numeric(mylm3$Coefficients[,3]),9),
               round(as.numeric(confint(standardlm3)[,1]),9))
  expect_equal(round(as.numeric(mylm3$Coefficients[,4]),8),
               round(as.numeric(confint(standardlm3)[,2]),8))
  # t value
  expect_equal(round(as.numeric(mylm3$Coefficients[,5]),8),
               round(as.numeric(summary(standardlm3)[4]$coe[,3] ),8))
  # p value
  expect_equal(round(as.numeric(mylm3$Coefficients[,6]),8),
               round(as.numeric(summary(standardlm3)[4]$coe[,4] ),8))


  ######################### model statistics
  # R-squared
  expect_equal(mylm3$Rsq,
               round(as.numeric(summary(standardlm3)[8]),8))

  # Adjusted_Rsq
  expect_equal(mylm3$Adjusted_Rsq,
               round(as.numeric(summary(standardlm3)[9]),8))
  # F statistic
  expect_equal(mylm3$F_stat,
               round(as.numeric(summary(standardlm3)[10]$f[1]),8))

  # P value of model
  expect_equal(mylm3$P_value, anova(standardlm2)$'Pr(>F)'[1])

  # Test warning
  expect_warning(linear_model(Petal.Length~Sepal.Width,
                              data=iris, digit = 0))

  # Test error returned (If we add any non-numeric terms)
  expect_error(linear_model(Petal.Length~Sepal.Width + Species,
                              data=iris))

  # Test another linear models using other larger datasets
  set.seed(222)
  testx = runif(500000, 1, 10000)
  testy = runif(500000, 1, 10000)

  # Test the coefficient beta0
  expect_equal(linear_model(testy~testx)$Coefficients[1],
               round(as.numeric(lm(testy~testx)[1]$coefficients[1]),3))

  # Test the coefficient beta1
  expect_equal(linear_model(testy~testx)$Coefficients[2],
               round(as.numeric(lm(testy~testx)[1]$coefficients[2]),3))
})
