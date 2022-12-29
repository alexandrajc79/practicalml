library(caret)
library(e1071)

# elasticnet required for lasso method
# must install lars and elasticnet packages first
install.packages("~/MyRLibs/lasso-lars.tar.gz", repos = NULL, lib = "/usr/local/lib/R/site-library")
install.packages("~/MyRLibs/lasso-elasticnet.tar.gz", repos = NULL, lib = "/usr/local/lib/R/site-library")
library(elasticnet) 


install.packages("~/MyRLibs/shape_1.4.6.tar.gz", repos = NULL, lib = "/usr/local/lib/R/site-library")
install.packages("~/MyRLibs/glmnet_4.1-6.tar.gz", repos = NULL, lib = "/usr/local/lib/R/site-library")
library(glmet)

#load training and testing data
training<-read.csv("pml-training.csv")
testing<-read.csv("pml-testing.csv")

#map classe to categories (12345 instead of ABCDE)
training$classe <- training$classe<-as.factor(training$classe)
#convert classe column to integer after setting them as a categorical
training$classe <- as.integer(training$classe)


#clean data by removing columns with no data
training <- training[!sapply(training, function(x) all(x == "" || is.na(x)))]

# Drop the index column and other columns which are user/time specific which would
# have no effect on prediction of classe variable
training<-training[,-c(1:7)]


#split training data to get a subset split on classe to be used as validation data
inTrain <- createDataPartition(y=training$classe,p=0.75,list=FALSE)
ds_train<-training[inTrain,]
ds_test<-training[-inTrain,]

set.seed(123)

modelGLM<-train(classe ~., data=ds_train, preProcess=c("center","scale"), method="glm")
predGLM<-predict(classe ~., ds_test)
print(modelGLM)
#RMSE      Rsquared  MAE      
#1.142357  0.4343478  0.8169056

modlasso <- train(classe ~ ., ds_train, method="lasso")

predlass <- predict(modlasso, ds_test)
print(predlass)
#fraction  RMSE      Rsquared   MAE      
#0.1       1.232099  0.3229802  1.0385323
#0.5       1.126277  0.4308748  0.8393484
#0.9       1.102961  0.4592028  0.8150769


# K-fold cross validation
train_control <- trainControl(method = "cv",number = 10)
modelCV <- train(classe ~. ,
                 data = ds_train, method = "lm", trControl = train_control)
predCV<-predict(modelCV, ds_test)
print(modelCV)
#RMSE      Rsquared  MAE      
#1.075099  0.490491  0.8122805