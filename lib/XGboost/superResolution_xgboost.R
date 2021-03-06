########################
### Super-resolution ###
########################

### Author: Chengliang Tang
### Project 3

source("../lib/XGboost/test_xgboost.R")
# helper function to get the value for pixel
get_pixel_value <- function(All_value, Given_Row_Index, Given_Col_Index){	
  
  if( Given_Row_Index <= 0 | Given_Row_Index > nrow(All_value) | Given_Col_Index <= 0 | Given_Col_Index > ncol(All_value) ){	
    return(NA)	
  }	
  
  else{	
    return(All_value[Given_Row_Index, Given_Col_Index])	
  }	
  
}


# helper function to get the value for the neighbor 8 pixels - central pixel
get_neighbor_pixel_value <- function(Chanel_Data, Given_Index){
  
  Row_Index <- arrayInd(Given_Index, dim(Chanel_Data))[1]
  Col_Index <- arrayInd(Given_Index, dim(Chanel_Data))[2]
  
  Threematrix <- matrix(NA,nrow=3,ncol=3)
  Threematrix[max(3-Row_Index,1):min(2+nrow(Chanel_Data)-Row_Index,3),max(3-Col_Index,1):min(2+ncol(Chanel_Data)-Col_Index,3)] <- Chanel_Data[max(Row_Index-1,1):min(Row_Index+1,nrow(Chanel_Data)),max(Col_Index-1,1):min(Col_Index+1,ncol(Chanel_Data))]
  
  Threematrix <- Threematrix-Threematrix[2,2]
  
  
  LR_Neighbor_value <- as.vector(Threematrix) 
  
  LR_Neighbor_NA_index <- which(is.na(LR_Neighbor_value))
  LR_Neighbor_value[LR_Neighbor_NA_index] <- 0
  
  LR_Neighbor_value <- LR_Neighbor_value[-5]

  return(LR_Neighbor_value)
  
}


superResolution_xgboost <- function(LR_dir, HR_dir, modelList){
  
  ### Construct high-resolution images from low-resolution images with trained predictor
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + a list for predictors
  
  n_files <- length(list.files(LR_dir))
  
  Total_MSE <- c()
    
  Total_PSNR <- c()
  
  ### read LR/HR image pairs
  for(i in 1:20){
    
    print(Sys.time())
    imgLR <- readImage(paste0(LR_dir,  "img", "_", sprintf("%04d", i), ".jpg"))
    cat(paste0(LR_dir,  "img", "_", sprintf("%04d", i), ".jpg"))
    pathHR <- paste0(HR_dir,  "img", "_", sprintf("%04d", i), ".jpg")
    featMat <- array(NA, c(dim(imgLR)[1] * dim(imgLR)[2], 8, 3))
    
    
    Red_Chanel_Image_Data <- imageData(imgLR)[ , , 1]
    Green_Chanel_Image_Data <- imageData(imgLR)[ , , 2]
    Blue_Chanel_Image_Data <- imageData(imgLR)[ , , 3]
    
    
    ### step 1. for each pixel and each channel in imgLR:
    ###           save (the neighbor 8 pixels - central pixel) in featMat
    ###           tips: padding zeros for boundary points

    print(Sys.time())
    # cl <- makeCluster(3)
    # on.exit(stopCluster(cl))
    
    featMat[ , , 1] <- do.call(rbind, lapply(c(1:length(Red_Chanel_Image_Data)), get_neighbor_pixel_value, Chanel_Data = Red_Chanel_Image_Data))
   
    featMat[ , , 2] <- do.call(rbind, lapply(c(1:length(Red_Chanel_Image_Data)), get_neighbor_pixel_value, Chanel_Data = Green_Chanel_Image_Data))
    
    featMat[ , , 3] <- do.call(rbind, lapply(c(1:length(Red_Chanel_Image_Data)), get_neighbor_pixel_value, Chanel_Data = Blue_Chanel_Image_Data))
    
    print(Sys.time())
    
    # stopCluster(cl)
    
    print("done feature")
    
    ### step 2. apply the modelList over featMat
    predMat <- test_xgboost(modelList, featMat)

    print("done predict")
    New_Image_Data <- array(data = predMat, c(dim(imgLR)[1]*dim(imgLR)[2], 4, 3))
    
    HR_Image_Data <- array(data = NA, c(dim(imgLR)[1]*2 , dim(imgLR)[2]*2, 3))
    
    
    for (index in c(1:nrow(New_Image_Data[,,1]))) {
      
      Row_i <- arrayInd(index, dim(Red_Chanel_Image_Data))[1]
      Col_i <- arrayInd(index, dim(Red_Chanel_Image_Data))[2]

      
      # In Red Channel
      HR_Image_Data[c(2*Row_i-1,2*Row_i), c(2*Col_i-1,2*Col_i), 1] <- matrix(New_Image_Data[index, , 1], nrow = 2, ncol = 2) + get_pixel_value(Red_Chanel_Image_Data, Row_i, Col_i)
      
      # Green
      HR_Image_Data[c(2*Row_i-1,2*Row_i), c(2*Col_i-1,2*Col_i), 2] <- matrix(New_Image_Data[index, , 2], nrow = 2, ncol = 2) + get_pixel_value(Green_Chanel_Image_Data, Row_i, Col_i)
      
      # Blue
      HR_Image_Data[c(2*Row_i-1,2*Row_i), c(2*Col_i-1,2*Col_i), 3] <- matrix(New_Image_Data[index, , 3], nrow = 2, ncol = 2) + get_pixel_value(Blue_Chanel_Image_Data, Row_i, Col_i)
      
    }
    
    # HR_Image <- Image(predMat, dim=c(dim(imgLR)[1]*2, dim(imgLR)[2]*2, 3), colormode='Color')
    HR_Image <- Image(HR_Image_Data, colormode='Color')
    
    # True_HR_Image_Data <- imageData(readImage(paste0("../data/train_set/HR/",  "img", "_", sprintf("%04d", i), ".jpg")))
    # 
    # MSE <- mean((True_HR_Image_Data - HR_Image_Data)^2)
    # 
    # Total_MSE <- c(Total_MSE, MSE)
    # 
    # PSNR <- 20*log10(1) - 10*log10(MSE)
    # 
    # Total_PSNR <- c(Total_PSNR, PSNR)
    
    # print(HR_Image)
    ### step 3. recover high-resolution from predMat and save in HR_dir
    writeImage(HR_Image, pathHR)
    
    cat("Image", i, "Done !\n")
    print(Sys.time())
  }
  
  # print("Mean MSE : \n")
  # print(mean(Total_MSE))
  # print("Mean PSNR : \n")
  # print(mean(Total_PSNR))
  
}

