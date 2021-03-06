context("Double programming for tensurv.R")

test_that("Counting Process Format without ties", {

})

test_that("Counting Process Format with ties", {

})



surv_to_count <- function(time, status, trt, strats){
  db <- data.frame(time, status, trt, strats)
  
  # KM estimator by Stratum
  tidy_survfit <- function(...){
    .survfit <- summary(survfit(...))
    n <- length(.survfit$time)
    data.frame(time = .survfit$time,
               n.risk = .survfit$n.risk,
               n.event = .survfit$n.event,
               surv = c(1, .survfit$surv[-n]) ) # ensure left continuous
  }
  km <- db %>% group_by(strats) %>% do( tidy_survfit(Surv(time, status) ~ 1, data = .) )
  
  # KM estimator by Stratum and Treatment Group Predicted at Specified Time
  pred_survfit <- function(pred_time, ...){
    .survfit <- survfit(...)
    
    # At risk subjects at pred_time
    n.risk  <- stepfun(.survfit$time, c(.survfit$n.risk, 0), right = TRUE )(pred_time)
    .x1 <- data.frame(time = pred_time, n.risk)
    
    # Number of Event
    .x2 <- data.frame(time = .survfit$time, n.event = .survfit$n.event) %>% subset(n.event > 0)
    
    merge(.x1, .x2, all = TRUE) %>% mutate(n.event = if_else(is.na(n.event), 0, n.event))
    
  }
  
  km_by_trt <- db %>% group_by(strats, trt) %>%
    do( pred_time = pred_survfit(km[km$strats == .$strats[1], ]$time,
                                 Surv(time, status) ~ 1, data = .) ) %>% unnest(cols = pred_time) %>%
    rename(tn.risk = n.risk, tn.event = n.event)
  
  
  # Log Rank Expectation Difference and Variance
  res <- merge(km, km_by_trt, all = TRUE) %>%
    arrange(trt, strats, time) %>%
    mutate( OminusE=tn.event - tn.risk/n.risk*n.event,
            Var=(n.risk- tn.risk)*tn.risk*n.event*(n.risk- n.event)/n.risk^2/(n.risk-1))
}

testthat::test_that("Counting Process Format without ties", {
  x=tibble(Stratum = c(rep(1,10),rep(2,6)),
           Treatment = rep(c(1,1,0,0),4),
           tte = 1:16,
           event= rep(c(0,1),8))
  txval=1
  res_tensurv <- simtrial::tensurv(x, txval)
  res_test <- surv_to_count(time = x$tte, status = x$event, trt = x$Treatment, strats = x$Stratum)
  
  res_test <- as_tibble(subset(res_test, trt == 1)) %>%
    subset(n.event>0 & n.risk - tn.risk > 0 & tn.risk >0)
  
  testthat::expect_equal(res_tensurv$OminusE, res_test$OminusE )
  testthat::expect_equal(res_tensurv$Var, res_test$Var)
  
})


testthat::test_that("Counting Process Format with ties", {
  x=tibble(Stratum = c(rep(1,10),rep(2,6)),
           Treatment = rep(c(1,1,0,0),4),
           tte = c(rep(1:4, each = 4) ),
           event= rep(c(0,1),8))
  txval=1
  res_tensurv <- tensurv(x, txval)
  res_test <- surv_to_count(time = x$tte, status = x$event, trt = x$Treatment, strats = x$Stratum)
  
  res_test <- as_tibble(subset(res_test, trt == 1)) %>%
    subset(n.event>0 & n.risk - tn.risk > 0 & tn.risk >0)
  
  testthat::expect_equal(res_tensurv$OminusE, res_test$OminusE )
  testthat::expect_equal(res_tensurv$Var, res_test$Var)
  
})
# test: making sure the data set is in the right format with exactly the same variable names: ERROR 
#if the required var names
# are missing or different (required input data set variable name is missing)
# x input has to be in tibble format
# test for stupid input and make sure the proper error msg is generated
# test: if txval is incorrectly specified, check if the proper error is generated







