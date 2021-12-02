#'Linear Models
#'
#'@description
#'linear_model function is used to fit linear models.
#'It can be seen as a basic version of lm() function.
#'
#'@param formula regression formula of interests; an object of class "formula"
#'(or one that can be coerced to that class).
#'@param data data used for regression model; an optional data frame, list or
#'environment (or object coercible by as.data.frame to a data frame)
#'containing the variables in the model.
#'@param digit digit precision of output (except p-value); an
#'optional int value. The default value in this function is 3.
#'@param detailed whether the function output a detailed table; a optional boolean
#'that indicates whether output the relevant detailed table. The default
#'value of "detailed" is FALSE.
#'
#'
#'@return linear_model() will return the fitted model's information
#'
#'It returns a list containing at least the following
#'components:
#'\describe{
#'  \item{call}{the matched call.}
#'  \item{coefficients}{a named vector of coefficients.}
#'}
#'
#'
#'If the option "detailed = TRUE", it would also return:
#'
#'\describe{
#'  \item{Significant_table}{the table showing the whether the
#'coefficients are significant.}
#'  \item{Df}{the degree of freedom of the model.}
#'  \item{Rsq}{the R squared.}
#'  \item{Adjusted_Rsq}{the adjusted R squared.}
#'  \item{F_statistics}{the F statistic of the model.}
#'  \item{P_value}{the P value of the model.}
#'}
#'
#'@examples
#'x = c(1,2,5,7,1,4)
#'y = c(3,4,7,1,8,8)
#'linear_model(y~x, detailed = TRUE)
#'linear_model(y~x + x^2, digit = 3, detailed = FALSE)
#'linear_model(Petal.Length~Sepal.Width, data = iris, digit = 3, detailed = TRUE)
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
                      c(t(betas)-stats::qt(0.025, degreef,lower.tail=FALSE)*betasd),
                      c(t(betas)+stats::qt(0.025, degreef,lower.tail=FALSE)*betasd))

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
