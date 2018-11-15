train.test.split <- function(data,train.size=0.8,seed=101){

  set.seed(seed)
  num_obs <- nrow(data)
  t_size <- as.integer(num_obs*train.size)
  train <- sample(1:num_obs, t_size)
  test <- setdiff(1:num_obs, train)
  data_train <- data[train,]
  data_test <- data[test,]
  split <- structure(list(),class="train.test.split")
  split$train <- data_train
  split$test <- data_test
  return(split)
}
