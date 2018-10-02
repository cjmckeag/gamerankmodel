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
setwd("D:\\Users\\cmckeag\\Documents\\gamerank")

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
# finding predictors with near zero variance
nzv <- nearZeroVar(dataDescr, saveMetrics= TRUE)
nzv[nzv$nzv,][1:10,]
# LeBron has near zero variance
nzv <- nearZeroVar(dataDescr)
filteredDescr <- dataDescr[, -nzv]
# find highly correlated predictors
descrCor <-  cor(filteredDescr)
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .999)
summary(descrCor[upper.tri(descrCor)])
highlyCorDescr <- findCorrelation(descrCor, cutoff = .75)
# remove highly correlated predictors
filteredDescr <- filteredDescr[,-highlyCorDescr]
descrCor2 <- cor(filteredDescr)
summary(descrCor2[upper.tri(descrCor2)])
# transforming predictors
pp.no.nzv <- preProcess(filteredDescr, method = c("center", "scale", "YeoJohnson", "nzv"))
pp.no.nzv
transformed<-predict(pp.no.nzv, newdata = filteredDescr)
fulldata<-data.frame(data$NormRev,transformed)
# splitting data
set.seed(42)
trainIndex <- createDataPartition(fulldata$data.NormRev, p = .8,list = FALSE, times = 1)
head(trainIndex)
dataTrain <- fulldata[ trainIndex,]
dataTest  <- fulldata[-trainIndex,]

# gradient boosted model
fitControl <- trainControl(method = "repeatedcv",number = 20, repeats = 20)
set.seed(42)
gbmFit1 <- train(y=dataTrain$data.NormRev, x=dataTrain,method = "gbm", trControl = fitControl,verbose = FALSE)
gbmFit1
gbmGrid <-expand.grid(interaction.depth = c(9, 11, 13),n.trees = (1:25)*2,shrinkage = 0.1,n.minobsinnode = 1)
set.seed(42)
gbmFit2 <- train(y=dataTrain$data.NormRev, x=dataTrain,method = "gbm",trControl = fitControl,verbose = FALSE,tuneGrid = gbmGrid)
gbmFit2
set.seed(42)
gbmGrid2<-expand.grid(interaction.depth = 17,n.trees = 100,shrinkage = 0.1,n.minobsinnode = 1)
gbmFit3<-train(y=dataTrain$data.NormRev, x=dataTrain,method = "gbm",trControl = trainControl(method="repeatedcv",number=20,repeats=20),verbose = FALSE,tuneGrid=gbmGrid2)
gbmFit3
#  RMSE        Rsquared   MAE       
#  0.05200376  0.9988569  0.02632437
# see if there is a simpler model with just as much strength
# predictions
gbm.predictions<-predict(gbmFit3,newdata=dataTest,n.trees=100)
plot(dataTest$data.NormRev,gbm.predictions)
abline(lm(gbm.predictions~dataTest$data.NormRev))
# we can see that predictions were very accurate, but accuracy decreased as NormRev increased
# FINAL BEST GBM MODEL:
gbm.model<-gbmFit3
#  RMSE        Rsquared   MAE       
#  0.05200376  0.9988569  0.02632437

# random forest model
fitControl <- trainControl(method = "repeatedcv",number = 10, repeats = 10)
set.seed(42)
rfFit1 <- train(y=dataTrain$data.NormRev, x=dataTrain,method = "rf", trControl = fitControl,verbose = FALSE)
rfFit1
#  RMSE        Rsquared   MAE       
#  0.1020496  0.9944892  0.04109713
# worse than the gbm model
# note: i tried adding more folds and repeats to the traincontrol, but it just takes too long
# predictions
rf.predictions<-predict(rfFit1,newdata=dataTest)
plot(dataTest$data.NormRev,rf.predictions)
abline(lm(rf.predictions~dataTest$data.NormRev))
# less accurate than gbm

# Bagged model
fitControl <- trainControl(method = "repeatedcv",number = 20, repeats = 20)
set.seed(42)
bagFit1<- train(y=dataTrain$data.NormRev, x=dataTrain,method = "treebag", trControl = fitControl,verbose = FALSE)
bagFit1
# RMSE       Rsquared   MAE      
# 0.1868128  0.9817937  0.1102776
# no tuning parameters
# predictions
bag.predictions<-predict(bagFit1,newdata=dataTest)
plot(dataTest$data.NormRev,bag.predictions)
abline(lm(bag.predictions~dataTest$data.NormRev))
# pretty bad

# EXTREME gradient boosting
fitControl <- trainControl(method = "repeatedcv",number=10,repeats=3)
xgbGrid <- expand.grid(nrounds = 500, eta = c(0.01,0.1), max_depth = c(2,6,10),gamma=0,colsample_bytree=0.8,min_child_weight=1,subsample=0.75)
set.seed(42)
xgbFit1 <-train(y=dataTrain$data.NormRev, x=dataTrain,method="xgbTree",trControl=fitControl)
xgbFit1
# RMSE        Rsquared  MAE
# 0.1134470  0.9872616  0.07259301
# not as good as normal gbm

# best model: GBM

save(gbm.model, file = "07242018 Game Rank Model.RData")
load("07242018 Game Rank Model.RData")

schedule <- read.csv("2018-19 Home Games.csv")
schedule$output <- predict(gbm.model, schedule, n.trees=100)

write.csv(schedule, "2018-19 Game Rank.csv")
