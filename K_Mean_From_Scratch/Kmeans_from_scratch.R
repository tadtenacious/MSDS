#Calculates Euclidean distance between a matrix and a vector
#Returns a vector
#Vector length must be the same length of a row from the matrix
vec_dist <- function(matrix,vec) {
  ones <- rep(1,length(vec))
  dvec <- (t(t(matrix) - vec)^2 %*% ones)^(1/2)
  return(dvec)
}

#Calculates the Euclidean distance between a matrix and multiple vectors
#Calls vec_dist() for each centroid/K iterations
mat_dist <- function(matrix, centroids, K) {
  dist_mat <- matrix(nrow = nrow(matrix),ncol = nrow(centroids))
  for (ix in 1:K){
    cntr <- centroids[ix,]
    dvec <- vec_dist(matrix, cntr)
    dist_mat[,ix] <- dvec
  }
  return(dist_mat)
}

#Calculates the average vector in a matrix(with k-Means this is a subset)
#If the matrix subset is actually a vector, the vector is returned as
#no calculation is needed
calc_centroid <- function(mat.subset, old.centroid){
  if (class(mat.subset)!= "matrix"){
    return(old.centroid)
  }
  else{
    new.centroid <- as.vector((t(mat.subset) %*% rep(1,nrow(mat.subset))) / nrow(mat.subset))
    return(new.centroid)
  }
}

#Runs the iteration for the new k-Means function
#returns a kmeans.result object
#kmeans.result$centroids are the new centroids
#kmeans.result$labels are the new class labels
#kmeans.result$result is the input matrix with the labels column
run_iteration <- function(matrix, centroids, K){
  dist_mat <- mat_dist(matrix, centroids, K) #Calculate Distance Matrix
  labs <- apply(dist_mat,1,FUN=which.min) #Arg Mins
  labeled.mat <- cbind(matrix,labs)
  new_centroids <- matrix(nrow = K, ncol = ncol(matrix))
  rownames(new_centroids) <- 1:K
  for (group in 1:K){
    lab.col <- ncol(labeled.mat)
    sset <- subset(labeled.mat,labeled.mat[,lab.col]==group)[,1:lab.col-1]
    new.cntr <- calc_centroid(sset,centroids[group,])
    new_centroids[group,] <- new.cntr
  }
  colnames(new_centroids) <- colnames(matrix)
  kmean.res <- structure(list(), class="kmeans.result")
  kmean.res$centroids <- new_centroids
  kmean.res$labels <- labs
  kmean.res$result <- labeled.mat
  return(kmean.res)
}


k.manual_means <- function(matrix, K, iterations=1000){
  first_centroids <- matrix[sample(nrow(matrix),K),]
  res <- run_iteration(matrix, first_centroids, K)
  for (i in 1:iterations){
    new_res <- run_iteration(matrix, res$centroids, K)
    if (identical(res$labels,new_res$labels)){
      return(res)
    }
    else{
      res <- new_res
    }
  }
  return(res)
}


set.seed(101)
imat <- as.matrix(iris[,1:4])
my.k.means <- k.manual_means(imat,3)
table(iris$Species, my.k.means$labels)
set.seed(101) # reset seed to same seed
rkmeans <- kmeans(imat,3,1000) # same K and same iterations
table(iris$Species, rkmeans$cluster)
print("The outputs between the two algorithms are identical")
print("when running from the same random state, same k, and same max iterations")
par(mfrow=c(2,1))
plot(imat[,c("Sepal.Length", "Sepal.Width")], col = rkmeans$cluster,main="R k-Means Results")
points(rkmeans$centers[,c("Sepal.Length", "Sepal.Width")], col = 1:3,pch = 8, cex=2)
plot(imat[,c("Sepal.Length", "Sepal.Width")], col = my.k.means$labels,main="My k-Means Results")
points(my.k.means$centroids[,c("Sepal.Length", "Sepal.Width")], col = 1:3,pch = 8, cex=2)
