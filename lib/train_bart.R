#########################################################
### Train a classification model with training features ###
#########################################################

### Author: Chengliang Tang
### Project 3

#dat_train <- train.data
#label_train <- train.label
#par = par

train <- function(dat_train, label_train, par=NULL){
  
  ### Train a Gradient Boosting Model (GBM) using processed features from training images
  
  ### Input: 
  ###  -  features from LR images 
  ###  -  responses from HR images
  ### Output: a list for trained models
  
  ### load libraries
  library("BayesTree")
  
  ### creat model list
  modelList <- list()
  
  ### Train with gradient boosting model
  if(is.null(par)){
    depth <- 3
  } else {
    depth <- par$depth
  }
  
  ### the dimension of response array is * x 4 x 3, which requires 12 classifiers
  ### this part can be parallelized
  for (i in 1:12){
    ## calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_train[, , c2]
    labMat <- label_train[, c1, c2]
    fit_bart <- bart(x.train = featMat, y.train = labMat,verbose = FALSE,ntree = 5)
    modelList[i] <- list(fit_bart)
  }
  
  return(modelList)
}


