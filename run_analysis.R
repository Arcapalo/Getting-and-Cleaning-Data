## You should create one R script called run_analysis.R that does the following. 
## 
## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement. 
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names. 
## 
## From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject.


if (!require("data.table")) {
    install.packages("data.table")
}
if (!require("reshape2")) {
    install.packages("reshape2")
}
require("data.table")
require("reshape2")

## Capturing data
## Labels
Activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
measures <- read.table("./UCI HAR Dataset/features.txt")[,2]
measures_select <- grepl("mean|std", measures)
new_header <- measures[1:length(measures)]
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(subject_test) = "Subject"
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(subject_train) = "Subject"

## Creating descriptive Activity_Names TRAIN  - read 7352 rows x 2 cols
Activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
Activity_train <- mutate(Activity_train,V2 = Activity_labels[V1])
names(Activity_train) <- c("Activity_Code","Activity_Name")

## Reading TRAN data   - read 7352 rows x 561 cols
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
## X_train new header
names(X_train) <- new_header

## Extract only the measurements on the mean and standard deviation for each measurement.
X_train_final <- X_train[,measures_select]
X_train_final <- cbind(subject_train, Activity_train ,X_train_final)

##  Creating descriptive Activity_Names TEST  - read 2947 rows x 2 cols
Activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
Activity_test <- mutate(Activity_test,V2 = Activity_labels[V1])
names(Activity_test) <- c("Activity_Code","Activity_Name")

## Reading TEST data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
## X_test new header
names(X_test) <- new_header

## Extract only the measurements on the mean and standard deviation for each measurement.
X_test_final <- X_test[,measures_select]
X_test_final <- cbind(subject_test, Activity_test, X_test_final)

## Merging the data sets
tidy_data1 <- rbind(X_train_final, X_test_final)
off_labels = c("Subject", "Activity_Code", "Activity_Name")
sep_labels = setdiff(colnames(tidy_data1), off_labels)

## Redistributing data set
melt_data = melt(tidy_data1, id = off_labels, measure.vars = data_labels)

## Apply mean function using dcast
tidy_data = dcast(melt_data, Subject + Activity_Name ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")