#############################################################
### Construct features and responses for training images###
#############################################################

### Authors: Chengliang Tang/Tian Zheng
### Project 3

feature <- function(LR_dir, HR_dir, n_points=1000){
  
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
  
  ### read LR/HR image pairs
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    imgHR <- readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    ### step 1. sample n_points from imgLR
    x_sam <- sample(1:nrow(imgLR), n_points, replace = T)
    y_sam <- sample(1:ncol(imgLR), n_points, replace = T)
    ### step 2. for each sampled point in imgLR,
    temp = array(0, c(dim(imgLR))+c(2,2,0))
    temp[2:(nrow(imgLR)+1),2:(ncol(imgLR)+1),]= imgLR
    for (j in 1:n_points) {
      featMat[(i-1)*n_points+j,,] = matrix(temp[x_sam[j]:(x_sam[j]+2),y_sam[j]:(y_sam[j]+2),],9,3)[-5,]
      labMat[j,,] = matrix(imgHR[(2*x_sam[j]-1):(2*x_sam[j]),(2*y_sam[j]-1):(2*y_sam[j]),],4,3)
      }
  }
  return(list(feature = featMat, label = labMat))
}

