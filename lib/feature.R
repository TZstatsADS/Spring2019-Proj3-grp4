#############################################################
### Construct features and responses for training images###
#############################################################

### Authors: Chengliang Tang/Tian Zheng
### Project 3

feature <- function(LR_dir, HR_dir, n_points=10){
  
  ### Construct process features for training images (LR/HR pairs)
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + number of points sampled from each LR image
  ### Output: an .RData file contains processed features and responses for the images
  
  ### load libraries
  library("EBImage")
  n_files <- length(list.files(LR_dir))
  
  ### store feature and responses
  featMat <- array(NA, c(n_files * n_points, 8, 3))
  labMat <- array(NA, c(n_files * n_points, 4, 3))
  
  f1 = function(c){
    return(matrix(temp[c[1]:(c[1]+2),c[2]:(c[2]+2),],9,3)[-5,])
  }
  f2 = function(c){
    return(matrix(imgHR[(2*c[1]-1):(2*c[1]),(2*c[2]-1):(2*c[2]),],4,3))
  }
  ### read LR/HR image pairs
  for(i in 1:2){
    imgLR <- readImage(paste0(LR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    imgHR <- readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    ### step 1. sample n_points from imgLR
    sam = matrix(0,nrow = n_points, ncol = 2)
    sam[,1] <- sample(1:nrow(imgLR), n_points, replace = T)
    sam[,2] <- sample(1:ncol(imgLR), n_points, replace = T)
    ### step 2. for each sampled point in imgLR,
    temp = array(0, c(dim(imgLR))+c(2,2,0))
    temp[2:(nrow(imgLR)+1),2:(ncol(imgLR)+1),]= imgLR
    t1 = apply(sam,1,f1)
    featMat[((i-1)*n_points+1):(i*n_points),,] = aperm(array(t1,c(8,3,n_points)),c(3,1,2))
    t2 = apply(sam,1,f2)
    labMat[((i-1)*n_points+1):(i*n_points),,] = aperm(array(t2,c(4,3,n_points)),c(3,1,2))
  }  
  return(list(feature = featMat, label = labMat))
}

