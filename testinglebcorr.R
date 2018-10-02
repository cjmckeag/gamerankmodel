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
setwd("/Users/candacemckeag/Downloads")

#load data
data<-read.csv(file="TicketRev18.csv")
# remove first 3 columns (team name, schedule, individual revenue)
data<-data[-c(1,2,3)]
data<-data[1:204,]
attach(data)
SeasonPart<-factor(SeasonPart)
data<-data.frame(NormRev,Rivalry,Stars,Facebook,SeasonPart,FootballSeason,LeBron,Weekend,PastWins,Holiday,BigGame,OverUnders,DaysSinceLast,DaysUntilNext)
dummies <- dummyVars(NormRev~., data = data)
head(predict(dummies, newdata = data))
dataDescr<-predict(dummies,newdata=data)
dataDescr<-data.frame(dataDescr)
attach(dataDescr)
dataClass<-data$NormRev


# Model without LeBron or OverUnders

# finding predictors with near zero variance
nzv <- nearZeroVar(dataDescr, saveMetrics= TRUE)
nzv[nzv$nzv,][1:10,]
# LeBron has near zero variance
nzv <- nearZeroVar(dataDescr)
filteredDescr1 <- dataDescr[, -nzv]
# find highly correlated predictors
descrCor1 <-  cor(filteredDescr1)
highCorr1 <- sum(abs(descrCor1[upper.tri(descrCor1)]) > .999)
summary(descrCor1[upper.tri(descrCor1)])
highlyCorDescr1 <- findCorrelation(descrCor1, cutoff = .75)
# remove highly correlated predictors
filteredDescr1 <- filteredDescr1[,-highlyCorDescr1]
descrCor21 <- cor(filteredDescr1)
summary(descrCor21[upper.tri(descrCor21)])
# transforming predictors
pp.no.nzv <- preProcess(filteredDescr1, method = c("center", "scale", "YeoJohnson", "nzv"))
transformed1<-predict(pp.no.nzv, newdata = filteredDescr1)
fulldata1<-data.frame(data$NormRev,transformed1)
# define model
set.seed(42)
gbmGrid2<-expand.grid(interaction.depth = 17,n.trees = 125,shrinkage = 0.1,n.minobsinnode = 1)
gbmFit3.none<-train(y=data$NormRev, x=fulldata1,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
gbmFit3.none
# RMSE        Rsquared   MAE       
# 0.04143684  0.9990102  0.01998062


# Model With LeBron, without correlated

descrCor2 <-  cor(dataDescr)
highCorr2 <- sum(abs(descrCor2[upper.tri(descrCor2)]) > .999)
summary(descrCor2[upper.tri(descrCor2)])
highlyCorDescr2 <- findCorrelation(descrCor2, cutoff = .75)
# remove highly correlated predictors
filteredDescr2 <- dataDescr[,-highlyCorDescr2]
descrCor22 <- cor(filteredDescr2)
summary(descrCor22[upper.tri(descrCor22)])
# transforming predictors
pp <- preProcess(filteredDescr2, method = c("center", "scale", "YeoJohnson"))
transformed2<-predict(pp, newdata = filteredDescr2)
fulldata2<-data.frame(data$NormRev,transformed2)
# define model
set.seed(42)
gbmGrid2<-expand.grid(interaction.depth = 17,n.trees = 125,shrinkage = 0.1,n.minobsinnode = 1)
gbmFit3.nocorr<-train(y=data$NormRev, x=fulldata2,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
gbmFit3.nocorr
# RMSE        Rsquared   MAE       
# 0.04121021  0.9989577  0.01992002


# Model with correlated, without LeBron

nzv <- nearZeroVar(dataDescr, saveMetrics= TRUE)
nzv[nzv$nzv,][1:10,]
# LeBron has near zero variance
nzv <- nearZeroVar(dataDescr)
filteredDescr3 <- dataDescr[, -nzv]
# transforming predictors
pp <- preProcess(filteredDescr3, method = c("center", "scale", "YeoJohnson"))
transformed3<-predict(pp, newdata = filteredDescr3)
fulldata3<-data.frame(data$NormRev,transformed3)
# define model
set.seed(42)
gbmGrid2<-expand.grid(interaction.depth = 17,n.trees = 125,shrinkage = 0.1,n.minobsinnode = 1)
gbmFit3.noleb<-train(y=data$NormRev, x=fulldata3,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
gbmFit3.noleb
# RMSE        Rsquared   MAE       
# 0.04139976  0.9989977  0.02008992


# Model With Lebron and Correlated

# transforming predictors
filteredDescr4<-dataDescr
pp <- preProcess(filteredDescr4, method = c("center", "scale", "YeoJohnson"))
transformed4<-predict(pp, newdata = filteredDescr4)
fulldata4<-data.frame(data$NormRev,transformed4)
# define model
set.seed(42)
gbmGrid2<-expand.grid(interaction.depth = 17,n.trees =125,shrinkage = 0.1,n.minobsinnode = 1)
gbmFit3.both<-train(y=data$NormRev, x=fulldata4,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
gbmFit3.both
# RMSE        Rsquared   MAE       
# 0.04135605  0.9989664  0.02004488

set.seed(42)
df<-data.frame()
for (i in 1:1000) {
  gbmFit3.none<-train(y=data$NormRev, x=fulldata1,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
  rmse.none<-gbmFit3.none$results[5]
  gbmFit3.nocorr<-train(y=data$NormRev, x=fulldata2,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
  rmse.nocorr<-gbmFit3.nocorr$results[5]
  gbmFit3.noleb<-train(y=data$NormRev, x=fulldata3,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
  rmse.noleb<-gbmFit3.noleb$results[5]
  gbmFit3.both<-train(y=data$NormRev, x=fulldata4,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
  rmse.both<-gbmFit3.both$results[5]
  newrow<-c(rmse.none,rmse.nocorr,rmse.noleb,rmse.both)
  names(newrow)<-c("RMSE","RMSE.1","RMSE.2","RMSE.3")
  df=rbind(df,newrow)
}

mean.none<-mean(df[["RMSE"]])
mean.nocorr<-mean(df[["RMSE.1"]])
mean.noleb<-mean(df[["RMSE.2"]])
mean.both<-mean(df[["RMSE.3"]])
means<-c(mean.none,mean.nocorr,mean.noleb,mean.both)
means
# [1] 0.04251400 0.04244973 0.04259525 0.04282650
# the model with LeBron, without OverUnders wins