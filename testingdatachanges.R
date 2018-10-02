library(boot)
library(leaps)
library(MASS)
library(DAAG)
library(car)
library(caret)
library(CombMSC)
library(AppliedPredictiveModeling) #preprocessing
set.seed(42)
#############################################################

# set working directory
setwd("V:\\CRMAnalytics\\Data and Research\\2018-19 Season\\Game Rank")

# We know that the linear model is the best model.
# Now we test whether or not we should remove near zero variance variables, high correlated variables, or
# preprocess the data.

# Test (Best Linear Model out of the above 4) on transformed or nontransformed data
set.seed(42)
df<-data.frame()
for (i in 1:300) {
  lmFit.trans <-train(y=data$NormRev, x=transformed,method="lm",trControl=fitControl)
  trans.rmse<-lmFit.trans$results[2]
  lmFit.og<-train(y=data$NormRev, x=dataDescr,method="lm",trControl=fitControl)
  og.rmse<-lmFit.og$results[2]
  newrow<-c(og.rmse,trans.rmse)
  names(newrow)<-c("RMSE","RMSE.1")
  df<-rbind(df,newrow)
}
trans.mean<-mean(df[["RMSE.1"]])
og.mean<-mean(df[["RMSE"]])
means<-c(og.mean,trans.mean)
means
# [1] 0.5091315 0.5105601
# using transformed data leads to higher error rate

# Test whether or not to remove LeBron and/or OverUnders (nzv and high corr variables)
set.seed(42)
df1<-data.frame()
for (i in 1:300) {
  lmFit.none <-train(y=data$NormRev, x=dataDescr[-c(9,14)],method="lm",trControl=fitControl)
  none.rmse<-lmFit.none$results[2]
  lmFit.noleb<-train(y=data$NormRev, x=dataDescr[-c(9)],method="lm",trControl=fitControl)
  noleb.rmse<-lmFit.noleb$results[2]
  lmFit.nocorr<-train(y=data$NormRev, x=dataDescr[-c(14)],method="lm",trControl=fitControl)
  nocorr.rmse<-lmFit.nocorr$results[2]
  lmFit.both<-train(y=data$NormRev, x=dataDescr,method="lm",trControl=fitControl)
  both.rmse<-lmFit.both$results[2]
  newrow<-c(none.rmse,noleb.rmse,nocorr.rmse,both.rmse)
  names(newrow)<-c("RMSE","RMSE.1","RMSE.2","RMSE.3")
  df1<-rbind(df1,newrow)
}
none.mean<-mean(df1[["RMSE.1"]])
noleb.mean<-mean(df1[["RMSE"]])
nocorr.mean<-mean(df1[["RMSE.2"]])
both.mean<-mean(df1[["RMSE.3"]])
means<-c(none.mean,noleb.mean,nocorr.mean,both.mean)
means
# [1] 0.5146093 0.5141657 0.4602792 0.4617581
# remove correlated variable, but keep lebron