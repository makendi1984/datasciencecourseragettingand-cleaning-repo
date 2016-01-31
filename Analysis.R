library(reshape2)

fileURL  <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileURL,destfile="getdata_dataset.zip", method="curl")
unzip("getdata_dataset.zip") 


# Load activity labels + features
Labelsactivity <- read.table("UCI HAR Dataset/activity_labels.txt")
Labelsactivity[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Loading respective datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(Subjects, Activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(Subjects, Activities, test)

# merge datasets and add labels
wholeData <- rbind(train, test)
colnames(wholeData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
wholeData$activity <- factor(wholeData$activity, levels = Labelsactivity[,1], labels = Labelsactivity[,2])
wholeData$subject <- as.factor(wholeData$subject)

wholeData.melted <- melt(wholeData, id = c("subject", "activity"))
wholeData.mean <- dcast(wholeData.melted, subject + activity ~ variable, mean)

write.table(wholeData.mean, "tidydata.txt", row.names = FALSE, quote = FALSE)
