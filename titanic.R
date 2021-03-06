###############
# Prediction Model of Survivals in Titanic
# Competition of Kaggle
#
# Creator : Igna Garcia
# In representation of : Universidad Nacional del Oeste, Argentina
#
# Create date: 2020/10/03
# Update date: 2020/10/30 
#        comment: 
###############


##----------------START LIBRARIES
library(readr) #To read .csv
library(dplyr) #To use select(), subset(), mutate(), and others
library(ranger) #To Random Forest optimised
library(pROC)
##----------------END LIBRARIES


start <- Sys.time()
##----------------START READ DATA
data <- read_csv("train.csv")
test <- read_csv("test.csv")
# Survived: 0-No; 1-Yes
# Pclass: 1-Upper; 2-Middle; 3-Lowe;
# SibSp: number of siblings  or spouses on family relation
# Parch: number of parents or childrens on family relation
# Fare: price of ticket
##----------------END READ DATA


##----------------START PROCESS DATA
str(data)
summary(data)
sapply(data, function(x) sum(is.na(x)))
sapply(test, function(x) sum(is.na(x)))

# Survived to factor
data$Survived <- as.factor(data$Survived)
test$Survived <- 0

# Sex: 1-male; 2-female;
data$Sexo <- 0
data <- data %>% mutate(Sexo = case_when(.$Sex == "male" ~ 1,
                                         .$Sex == "female" ~ 2))
test$Sexo <- 0
test <- test %>% mutate(Sexo = case_when(.$Sex == "male" ~ 1,
                                         .$Sex == "female" ~ 2))

# Embarked: 1-Cherbourg; 2-Queenstown; 3-Southampton; 
data$Embark <- 0
data <- data %>% mutate(Embark = case_when(.$Embarked == 'C' ~ 1,
                                           .$Embarked == 'Q' ~ 2,
                                           .$Embarked == 'S' ~ 3))
test$Embark <- 0
test <- test %>% mutate(Embark = case_when(.$Embarked == 'C' ~ 1,
                                           .$Embarked == 'Q' ~ 2,
                                           .$Embarked == 'S' ~ 3))

# Less columns: -Name; -Ticket; -Cabin; -Sex; -Embarked; 
data <- select(data, -c("Name", "Ticket","Cabin", "Sex", "Embarked"))
test <- select(test, -c("Name", "Ticket","Cabin", "Sex", "Embarked"))

# NAs treatment
data <- subset(data, !is.na(data$Embark))
test <- subset(test, !is.na(test$Embark))
test$Fare[is.na(test$Fare)] <- 0

# Set whitout NA
set1 <- na.omit(data)
test1 <- na.omit(test)
summary(set1)

# Set whit Age NA = mean
set2 <- data 
set2$Age[is.na(set2$Age)] <- mean(set2$Age, na.rm=T)
test2 <- test 
test2$Age[is.na(test2$Age)] <- mean(test2$Age, na.rm=T)
summary(set2)

# Set whit Age as numeric factor
set3 <- data %>% mutate(Age = case_when(.$Age <= 10 ~ 1,
                                        .$Age <= 20 ~ 2,
                                        .$Age <= 30 ~ 3,
                                        .$Age <= 40 ~ 4,
                                        .$Age <= 50 ~ 5,
                                        .$Age <= 60 ~ 6,
                                        .$Age <= 70 ~ 7,
                                        .$Age <= 80 ~ 8,
                                        TRUE ~ 0))
test3 <- test %>% mutate(Age = case_when(.$Age <= 10 ~ 1,
                                         .$Age <= 20 ~ 2,
                                         .$Age <= 30 ~ 3,
                                         .$Age <= 40 ~ 4,
                                         .$Age <= 50 ~ 5,
                                         .$Age <= 60 ~ 6,
                                         .$Age <= 70 ~ 7,
                                         .$Age <= 80 ~ 8,
                                         TRUE ~ 0))
##----------------END PROCESS DATA
  

##----------------START MODELS
###---------- Set1
vars1 <- 2
results1 <- c(0)

for(vars1 in 2:7){
  model <- ranger( Survived ~ . , data= set1[,-1]
          , num.trees = 1000
          , mtry = vars1
          , importance = "impurity"
          , write.forest = T
          , probability = T
          , alpha = 0.005
  )
  results1[vars1-2] <- paste("\nVars: ", vars1, "; OOB: ", model$prediction.error)
}
cat("\nSet1:",results1) #With 3 Vars got the min OOB

model1 <- ranger( Survived ~ . , data= set1[,-1]
                  , num.trees = 1000
                  , mtry = 3
                  , importance = "impurity"
                  , write.forest = T
                  , probability = T
                  , alpha = 0.005
) #OOB: 0.1322607

roc1 <- roc(set1$Survived, model1$predictions[,2], percetnt= T, auc= T, ci= T, plot= T)
plot.roc(roc1, legacy.axes= T, print.thres= "best", print.auc= T)

model11 <- ranger( Survived ~ . , data= set1[,-1]
                   , num.trees = 1000
                   , mtry = 3
                   , importance = "impurity"
                   , write.forest = T
                   , probability = F
                   , alpha = 0.005
)


###---------- Set2
vars2 <- 2
results2 <- c(0)

for(vars2 in 2:7){
  model <- ranger( Survived ~ . , data= set2[,-1]
                   , num.trees = 1000
                   , mtry = vars2
                   , importance = "impurity"
                   , write.forest = T
                   , probability = T
                   , alpha = 0.005
  )
  results2[vars2-2] <- paste("\nVars: ", vars2, "; OOB: ", model$prediction.error)
}
cat("\nSet2:",results2) #With 3 Vars got the min OOB

model2 <- ranger( Survived ~ . , data= set2[,-1]
                  , num.trees = 1000
                  , mtry = 3
                  , importance = "impurity"
                  , write.forest = T
                  , probability = T
                  , alpha = 0.005
) #OOB: 0.1260643

roc2 <- roc(set2$Survived, model2$predictions[,2], percetnt= T, auc= T, ci= T, plot= T)
plot.roc(roc2, legacy.axes= T, print.thres= "best", print.auc= T)

model21 <- ranger( Survived ~ . , data= set2[,-1]
                  , num.trees = 1000
                  , mtry = 3
                  , importance = "impurity"
                  , write.forest = T
                  , probability = F
                  , alpha = 0.005
)


###---------- Set3
vars3 <- 2
results3 <- c(0)

for(vars3 in 2:7){
  model <- ranger( Survived ~ . , data= set3[,-1]
                   , num.trees = 1000
                   , mtry = vars3
                   , importance = "impurity"
                   , write.forest = T
                   , probability = T
                   , alpha = 0.005
  )
  results3[vars3-2] <- paste("\nVars: ", vars3, "; OOB: ", model$prediction.error)
}
cat("\nSet3:",results3) #With 3 Vars got the min OOB

model3 <- ranger( Survived ~ . , data= set3[,-1]
                  , num.trees = 1000
                  , mtry = 3
                  , importance = "impurity"
                  , write.forest = T
                  , probability = T
                  , alpha = 0.005
) #OOB: 0.1267627

roc3 <- roc(set3$Survived, model3$predictions[,2], percetnt= T, auc= T, ci= T, plot= T)
plot.roc(roc3, legacy.axes= T, print.thres= "best", print.auc= T)

model31 <- ranger( Survived ~ . , data= set3[,-1]
                   , num.trees = 1000
                   , mtry = 3
                   , importance = "impurity"
                   , write.forest = T
                   , probability = F
                   , alpha = 0.005
)

##----------------END MODELS


##----------------START PREDICTION
## Set1 - Is Useless
preds1 <- predict(model11, data = test1)
test1$Survived <- as.numeric(as.character(preds1$predictions))
write.csv (select(test1, PassengerId, Survived), 'submission1.csv' ,fileEncoding= "UTF-8",row.names= F)

## Set2
preds2 <- predict(model21, test2)
test2$Survived <- as.numeric(as.character(preds2$predictions))
write.csv (select(test2, PassengerId, Survived), 'submission2.csv' ,fileEncoding= "UTF-8",row.names= F)

## Set3
preds3 <- predict(model31, data = test3)
test2$Survived <- as.numeric(as.character(preds3$predictions))
write.csv (select(test3, PassengerId, Survived), 'submission3.csv' ,fileEncoding= "UTF-8",row.names= F)

##----------------END PREDICTION

totalTime <- Sys.time() - start
print(totalTime)