% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Ex2delayedEffect.r
\docType{data}
\name{Ex2delayedEffect}
\alias{Ex2delayedEffect}
\title{Time-to-event data example 2 for non-proportional hazards working group}
\format{
Data frame with 4 variables:
\describe{ 
\item{id}{sequential numbering of unique identifiers}
\item{month}{time-to-event}
\item{event}{1 for event, 0 for censored} 
\item{trt}{1 for experimental, 0 for control}
}
}
\usage{
data(Ex2delayedEffect)
}
\description{
Survival objects reverse-engineered datasets from published Kaplan-Meier
curves. 
Individual trials are de-identified since the data are only
approximations of the actual data.
Data are intended to evaluate methods and designs for trials where
non-proportional hazards may be anticipated for outcome data.
}
\examples{
library(survival)
data(Ex2delayedEffect)
km1 <- with(Ex2delayedEffect,survfit(Surv(month,evntd)~trt))
km1
plot(km1)
with(subset(Ex2delayedEffect,trt==1),survfit(Surv(month,evntd)~trt))
with(subset(Ex2delayedEffect,trt==0),survfit(Surv(month,evntd)~trt))
}
\references{
TBD
}
\seealso{
\code{\link{Ex1delayedEffect}}, \code{\link{Ex3curewithph}}, \code{\link{Ex4belly}},
\code{\link{Ex5widening}}, \code{\link{Ex6crossing}}
}
\keyword{datasets}
