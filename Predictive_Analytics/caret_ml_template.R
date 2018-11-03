library(e1071)
library(caret)

train_test_split <- function(data,target_column,train_size=0.8){
  num_obs <- nrow(data)
  t_size <- as.integer(num_obs*train_size)
  t1 <- sample(1:num_obs, t_size)
  t2 <- base::setdiff(1:num_obs, t1)
  train <- subset(data[t1,], select =- eval(parse(text=target_column)))
  test <- subset(data[t2,], select =- eval(parse(text=target_column)))
  train_target <- data[t1,c(target_column)]
  test_target <- data[t2,c(target_column)]
  tt_split <- structure(list(), class='train.test.split.res')
  tt_split$train <- train
  tt_split$test <- test
  tt_split$train_target <- train_target
  tt_split$test_target <- test_target
  return(tt_split)
}

path <- ""
target_variable <- ""
data <-read.csv(file=path, head=FALSE, sep=',')

tt_split <- train_test_split(data,target_variable)

train <- tt_split$train
test <- tt_split$test
train_target <- tt_split$train_target
test_target <- tt_split$test_target

# model <- train(train, train_target, method='')
# pred <- predict(model,test)
# confusionMatrix(pred,test_target)

