###### Random Forest ######

## 1
# train <- function(feat_train, label_train, params=NULL, run_gbm = F, 
#                   run_xgb = F,run_lr=F, run_rf = F){
#   
#   ### Train a Gradient Boosting Model (GBM) using processed features from training images
#   
#   ### Input: 
#   ###  -  features from LR images 
#   ###  -  responses from HR images
#   ### Output: a list for trained models
#   
#   ### creat model list
#   modelList <- list()
#   
# 
# for (i in 1:12){
#   ## calculate column and channel
#   c1 <- (i-1) %% 4 + 1
#   c2 <- (i-c1) %/% 4 + 1
#   featMat <- feat_train[, , c2]
#   labMat <- label_train[, c1, c2]
#   
# rf <- NULL
# if(run_rf){
#   if( !require("randomForest" )){
#     install.packages("randomForest")
#   }
#   
#   library(randomForest)
#   library(caret)
#   library(e1071)
#   
#   rf.fit <- randomForest(as.factor(labMat) ~ .,
#                          data = featMat, mtry = params[1],
#                          importance=TRUE, 
#                          ntree = params[2])
#   modelList[[i]] <- list(fit= rf.fit)
# }
# }
# return(modelList)
# }

#########################################################
## 2


### Train a Random Forest model using processed features from training images

### Input: 
###  -  features from LR images 
###  -  responses from HR images
### Output: a list for trained models

train_randomforest <- function(dat_train, label_train, par=NULL){
  
  ### load libraries
  library("randomForest")
  
  ### creat model list
  modelList <- list()
  
  ### Train with random forest model
  if(is.null(par)){
    mtry <- 3
    ntrees <- 100
  } 
  
  else {
    mtry <- par$depth
    ntrees <- par$nrounds
  }
  
  ### the dimension of response arrat is * x 4 x 3, which requires 12 classifiers
  ### this part can be parallelized
  for (i in 1:12){
    ## calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_train[, , c2]
    colnames(featMat) <- c("1","2","3","4","5","6","7","8")
    labMat <- label_train[, c1, c2]
    fit_rdf <- randomForest(x=featMat,
                            y=labMat,
                            importance = TRUE,
                            keep.forest=TRUE )
    modelList[[i]] <- list(fit=fit_rdf)
  }
  
  return(modelList)
  
}