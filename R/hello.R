# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'


#'linear_model
#'
#'Gets the square of a number
#'
#'@param formula regression formula of interests
#'@param data data used for regression model
#'@param digit digits of output numbers (except p-value)
#'@param detailed whether output a detailed table
#'
#'
#'@return the square of x
#'
#'@examples
#'square(3)
#'
#'@export
#'
linear_model <- function(formula, data, digit = 3, detailed = FALSE)
{
  if(digit < 1)
  {
    warning("The precisions may be low. Try to have larger digits (digit > 1).")
  }

  # Read the formula
  cl = match.call()
  mf = match.call(expand.dots = FALSE)
  m = match(c("formula", "data"),names(mf), 0L)
  mf = mf[c(1L, m)]
  mf$drop.unused.levels = TRUE
  mf[[1L]] = quote(stats::model.frame)
  mf = eval(mf, parent.frame())

  # Get the data
  dataframe = as.matrix(eval(mf, parent.frame()))

  X = cbind(1, dataframe[,-1])
  y = model.response(mf, "numeric")

  # Stops the program when variables are not numeric
  if (!is.numeric(X) || !is.numeric(y))
  {
    stop("The variables must be numeric")
  }

  # Calculate the beta
  betas = solve(t(X) %*% X) %*% t(X) %*% eval(y)
  betas = t(betas)
  round(betas, digits = digit)

  # Get the variable name
  mt = attr(mf, "terms")
  mt = attr(mt, "term.labels")
  var.len = length(mt)
  name.list = c("(Intercept)")
  for (i in 1:var.len)
  {
    name.list[i+1] = mt[i]
  }

  # Add the beta table col and row names
  colnames(betas) = name.list
  rownames(betas) = " "

  call = cl
  terms = mt
  betas = round(betas, digit)

  # Residual Standard Error
  ny = length(y)
  yhat = X %*% t(betas)
  residual = y - yhat
  SSE = sum(residual^2)
  residualse = sqrt(sum(residual^2) / (ny - 1 - var.len))

  # Df
  degreef = ny - 1 - var.len

  # R-Squared
  SSyy=sum((y - mean(y))**2)
  Rsq = 1-SSE / SSyy
  Rsq = round(Rsq, digit)

  # Adjusted R-Squared
  AdRsq = 1-(SSE / SSyy) * (ny - 1)/(ny - 1 - var.len)
  AdRsq = round(AdRsq, digit)

  # F-statistic
  Fstat = ((SSyy-SSE)/var.len) / (SSE/(ny - 1 - var.len))
  Fstat = round(Fstat, digit)

  #P-value
  pvalue = pf(Fstat, var.len, degreef, lower.tail = FALSE)

  #Std. Error of Coefficients
  sigmaM = ((sum(residual^2)/(ny - 1 - var.len)) * solve(t(X) %*% X))
  betasd = c(sqrt(sigmaM[1, 1]))
  for(i in 1:var.len)
  {
    betasd[i+1]=sqrt(sigmaM[i+1, i+1])
  }
  betasd=(as.matrix(betasd))

  rownames(betasd) = name.list
  colnames(betasd) = "Std. Error"

  detail_list = cbind(t(betas),betasd,
                      c(t(betas)-1.96*betasd),
                      c(t(betas)+1.96*betasd))

  t_value = detail_list[,1]/detail_list[,2]
  detail_list = cbind(detail_list, t_value)
  detail_list = round(detail_list, digit)

  # Make a table to summarize the significant coefficients
  pcoes = 2*pt(q=abs(t_value), df=degreef, lower.tail=F)
  signifi = ifelse(pcoes<0.05, "Yes", "No")
  signifi = (as.matrix(signifi))
  colnames(signifi) = "Significant or not (alpha = 0.05)"

  detail_list = cbind(detail_list, pcoes)
  colnames(detail_list) = c("Estimates", "Std. Error",
                            "Lower Bound 95% CI",
                            "Upper Bound 95% CI",
                            "t value", "P value")

  # Return the final results
  final_result = list(Call = cl,Coefficients = betas)
  final_detailed = list(Call = cl, Coefficients = detail_list,
                        Significant_table = signifi, Df = degreef,
                        Rsq = Rsq, Adjusted_Rsq = AdRsq,
                        F_statistics = Fstat, P_value = pvalue)

  if(detailed){return(final_detailed)}
  return(final_result)
}
