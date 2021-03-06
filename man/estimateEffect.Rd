% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimateEffect.R
\name{estimateEffect}
\alias{estimateEffect}
\title{Estimates regressions using an STM object}
\usage{
estimateEffect(formula, stmobj, metadata = NULL, uncertainty = c("Global",
  "Local", "None"), documents = NULL, nsims = 25, prior = NULL)
}
\arguments{
\item{formula}{A formula for the regression.  It should have an integer or
vector of numbers on the left-hand side and an equation with covariates on
the right hand side.  See Details for more information.}

\item{stmobj}{Model output from STM}

\item{metadata}{A dataframe where all predictor variables in the formula can
be found. If \code{NULL} R will look for the variables in the global
namespace.  It will not look for them in the \code{STM} object which for
memory efficiency only stores the transformed design matrix and thus will
not in general have the original covariates.}

\item{uncertainty}{Which procedure should be used to approximate the
measurement uncertainty in the topic proportions.  See details for more
information.  Defaults to the Global approximation.}

\item{documents}{If uncertainty is set to \code{Local}, the user needs to
provide the documents object (see \code{\link{stm}} for format).}

\item{nsims}{The number of simulated draws from the variational posterior.
Defaults to 25.  This can often go even lower without affecting the results
too dramatically.}

\item{prior}{This argument allows the user to specify a ridge penalty to be
added to the least squares solution for the purposes of numerical stability.
If its a scalar it is added to all coefficients.  If its a matrix it should
be the prior precision matrix (a diagonal matrix of the same dimension as
the \code{ncol(X)}).  When the design matrix is collinear but this argument
is not specified, a warning will pop up and the function will estimate with
a small default penalty.}
}
\value{
\item{parameters}{A list of K elements each corresponding to a
topic.  Each element is itself a list of n elements one per simulation.
Each simulation contains the MLE of the parameter vector and the variance
covariance matrix} \item{topics}{The topic vector} \item{call}{The original
call} \item{uncertainty}{The user choice of uncertainty measure}
\item{formula}{The formula object} \item{data}{The original user provided
meta data.} \item{modelframe}{The model frame created from the formula and
data} \item{varlist}{A variable list useful for mapping terms with columns
in the design matrix}
}
\description{
Estimates a regression where documents are the units, the outcome is the
proportion of each document about a topic in an STM model and the covariates
are document-meta data.  This procedure incorporates measurement uncertainty
from the STM model using the method of composition.
}
\details{
This function performs a regression where topic-proportions are the outcome
variable.  This allows us to conditional expectation of topic prevalence
given document characteristics.  Use of the method of composition allows us
to incorporate our estimation uncertainty in the dependent variable. Mechanically
this means we draw a set of topic proportions from the variational posterior,
compute our coefficients, then repeat.  To compute quantities of interest we
simulate within each batch of coefficients and then average over all our results.

The formula specifies the nature of the linear model.  On the left hand-side
we use a vector of integers to indicate the topics to be included as outcome
variables.  If left blank then the default of all topics is used. On the
right hand-side we can specify a linear model of covariates including
standard transformations.  Thus the model \code{2:4 ~ var1 + s(var2)} would
indicate that we want to run three regressions on Topics 2, 3 and 4 with
predictor variables \code{var1} and a b-spline transformed \code{var2}.  We
encourage the use of spline functions for non-linear transformations of
variables.

The function allows the user to specify any variables in the model.
However, we caution that for the assumptions of the method of composition to
be the most plausible the topic model should contain at least all the
covariates contained in the \code{estimateEffect} regression.  However the
inverse need not be true.  The function will automatically check whether the
covariate matrix is singular which generally results from linearly dependent
columns.  Some common causes include a factor variable with an unobserved
level, a spline with degrees of freedom that are too high, or a spline with
a continuous variable where a gap in the support of the variable results in
several empty basis functions.  In these cases the function will still
estimate by adding a small ridge penalty to the likelihood.  However, we
emphasize that while this will produce an estimate it is only identified by
the penalty.  In many cases this will be an indication that the user should
specify a different model.

The function can handle factors and numeric variables.  Dates should be
converted to numeric variables before analysis.

We offer several different methods of incorporating uncertainty.  Ideally we
would want to use the covariance matrix that governs the variational
posterior for each document (\eqn{\nu}).  The updates for the global
parameters rely only on the sum of these matrices and so we do not store
copies for each individual document.  The default uncertainty method
\code{Global} uses an approximation to the average covariance matrix formed
using the global parameters.  The uncertainty method \code{Local} steps
through each document and updates the parameters calculating and then saving
the local covariance matrix.  The option \code{None} simply uses the map
estimates for \eqn{\theta} and does not incorporate any uncertainty.  We
strongly recommend the \code{Global} approximation as it provides the best
tradeoff of accuracy and computational tractability.

Effects are plotted based on the results of \code{\link{estimateEffect}}
which contains information on how the estimates are constructed.  Note that
in some circumstances the expected value of a topic proportion given a
covariate level can be above 1 or below 0.  This is because we use a Normal
distribution rather than something constrained to the range between 0 and 1.
If a continuous variable goes above 0 or 1 within the range of the data it
may indicate that a more flexible non-linear specification is needed (such
as using a spline or a spline with greater degrees of freedom).
}
\examples{

#Just one topic (note we need c() to indicate it is a vector)
prep <- estimateEffect(c(1) ~ treatment, gadarianFit, gadarian)
summary(prep)
plot(prep, "treatment", model=gadarianFit, method="pointestimate")

#three topics at once
prep <- estimateEffect(1:3 ~ treatment, gadarianFit, gadarian)
summary(prep)
plot(prep, "treatment", model=gadarianFit, method="pointestimate")

#with interactions
prep <- estimateEffect(1 ~ treatment*s(pid_rep), gadarianFit, gadarian)
summary(prep)
}
\seealso{
\code{\link{plot.estimateEffect}} \code{\link{summary.estimateEffect}}
}
