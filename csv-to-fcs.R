rm(list = ls())

if(!require("flowCore"))
  BiocManager::install("flowCore")

if(!require("Biobase"))
  BiocManager::install("Biobase")

library(flowCore)
library(Biobase)
library(tidyverse)

dirname(rstudioapi::getActiveDocumentContext()$path)            # Finds the directory where this script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))     # Sets the working directory to where the script is located
getwd()
PrimaryDirectory <- getwd()
PrimaryDirectory

csv_filesDir <- "csv_files"
csv_filesDir <- file.path(PrimaryDirectory, csv_filesDir)


fcs_filesDir <- "fcs_files"
fcs_filesDir <- file.path(PrimaryDirectory, fcs_filesDir)

if(!dir.exists(fcs_filesDir))
  dir.create(fcs_filesDir)

file.names <- list.files(path = csv_filesDir, pattern = ".csv")
as_tibble(file.names)

# create an empty list to start
DataList <- list() 

for(file in file.names){
  tmp <- read_csv(file.path(csv_filesDir, file))
  file <- gsub(".csv", "", file)
  DataList[[file]] <- tmp
}
rm(tmp)

filenames <- names(DataList)
head(DataList)

# convert csv to fcs
setwd(fcs_filesDir)

for(i in c(1:length(filenames))){
  data_subset <- DataList[i]
  data_subset <- data.table::rbindlist(as.list(data_subset))
  file_name <- names(DataList)[i]
  
  metadata <- data.frame(name = dimnames(data_subset)[[2]], desc = "")
  
  # create FCS file metadata
  # metadata$range <- apply(apply(data_subset, 2, range), 2, diff)
  metadata$minRange <- apply(data_subset, 2, min)
  metadata$maxRange <- apply(data_subset, 2, max)
  
  
  # data as matrix by exprs
  data_subset.ff <- new("flowFrame", exprs = as.matrix(data_subset),
                        parameters = AnnotatedDataFrame(metadata))
  
  head(data_subset.ff)
  write.FCS(data_subset.ff, paste0(file_name, ".fcs"), what = "numeric")
}





