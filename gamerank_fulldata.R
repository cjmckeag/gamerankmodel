library(boot)
library(leaps)
library(MASS)
library(DAAG)
library(car)
library(caret)
library(CombMSC)
library(AppliedPredictiveModeling)
set.seed(42)
#############################################################

# set working directory
setwd("V:\\CRMAnalytics\\Data and Research\\2018-19 Season\\Game Rank")

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
# finding predictors with near zero variance
nzv <- nearZeroVar(dataDescr, saveMetrics= TRUE)
nzv[nzv$nzv,][1:10,]
# LeBron has near zero variance, but will not be removed (see testingdatachanges.R)
# find highly correlated predictors
filteredDescr<-dataDescr
descrCor <-  cor(filteredDescr)
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .999)
summary(descrCor[upper.tri(descrCor)])
highlyCorDescr <- findCorrelation(descrCor, cutoff = .75)
# remove highly correlated predictors
filteredDescr <- filteredDescr[,-highlyCorDescr]
descrCor2 <- cor(filteredDescr)
summary(descrCor2[upper.tri(descrCor2)])


# gradient boosting model
fitControl <- trainControl(method = "repeatedcv",number = 20, repeats = 20)
set.seed(42)
gbmGrid<-expand.grid(interaction.depth = 7,n.trees = 26,shrinkage = 0.1,n.minobsinnode = 1)
gbmFit<-train(y=data$NormRev, x=filteredDescr,method = "gbm",trControl = fitControl,verbose = FALSE,tuneGrid=gbmGrid)
gbmFit
#  RMSE        Rsquared   MAE       
#  0.5577934  0.698065  0.386471
# FINAL BEST GBM MODEL


# random forest model
fitControl <- trainControl(method = "repeatedcv",number = 10, repeats = 10)
set.seed(42)
rfFit <- train(y=data$NormRev, x=filteredDescr,method = "rf", trControl = fitControl,verbose = FALSE)
rfFit
#  RMSE        Rsquared   MAE       
#  0.5661689  0.6897815  0.3768407
# mtry=9
# note: i tried adding more folds and repeats to the traincontrol, but it just takes too long


# Bagged model
fitControl <- trainControl(method = "repeatedcv",number = 20, repeats = 20)
set.seed(42)
bagFit<- train(y=data$NormRev, x=filteredDescr,method = "treebag", trControl = fitControl,verbose = FALSE)
bagFit
# RMSE       Rsquared   MAE      
# 0.5773923  0.6631033  0.393701
# no tuning parameters


# EXTREME gradient boosting
fitControl <- trainControl(method = "repeatedcv",number=10,repeats=3)
set.seed(42)
xgbFit <-train(y=data$NormRev, x=filteredDescr,method="xgbTree",trControl=fitControl)
xgbFit
# RMSE       Rsquared   MAE
# 0.5867545  0.6582424  0.3968625
# not as good as normal gbm

# k nearest neighbors
fitControl <- trainControl(method = "repeatedcv",number=10,repeats=5)
set.seed(42)
knn.model<-train(y=data$NormRev, x=filteredDescr,trControl=fitControl,method='knn')
knn.model
# RMSE       Rsquared   MAE
# 0.8582361  0.2904200  0.5810316

# lm model
fitControl <- trainControl(method = "repeatedcv",number=50,repeats=20)
set.seed(42)
lmFit <-train(y=data$NormRev, x=filteredDescr,method="lm",trControl=fitControl)
lmFit
# RMSE       Rsquared   MAE
# 0.4610565  0.7469109  0.3488148


# best model: 
lmFit