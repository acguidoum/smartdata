normalizationPackages <- list("min-max" = "clusterSim",
                              "z-score" = "clusterSim",
                              "decimal-scaling" = "dprep",
                              "sigmoidal" = "dprep",
                              "softmax" = "dprep")
normalizationMethods <- names(normalizationPackages)


normalizationTask <- function(dataset, method, ...){
  task <- list(dataset = dataset, method = method, args = list(...))
  class(task) <- normalizationPackages[[method]]
  task
}


doNormalization <- function(task){
  UseMethod("doNormalization")
}

doNormalization.clusterSim <- function(task){
  possibleArgs <- list(normalization = c("column", "row"))
  checkListArguments(task$args, possibleArgs)

  type <- switch(task$method,
                 "z-score" = "n1",
                 "min-max" = "n4")

  callArgs <- append(list(x = task$dataset, type = type), task$args)
  do.call(clusterSim::data.Normalization, callArgs)
}


doNormalization.dprep <- function(task){
  possibleArgs <- list()
  checkListArguments(task$args, possibleArgs)

  if(task$method == "decimal-scaling"){
    dprep::decscale(task$dataset)
  } else if(task$method == "sigmoidal"){
    dprep::signorm(task$dataset)
  } else if(task$method == "softmax"){
    dprep::softmaxnorm(task$dataset)
  }
}


#' Normalization wrapper
#'
#' @param dataset we want to perform normalization on
#' @param method selected method of normalization
#' @param classAttr \code{character}. Indicates the class attribute from
#'   \code{dataset}. Must exist in it.
#'
#' @return The normalized dataset
#' @export
#'
#' @examples
#' library("amendr")
#' data(iris0)
#'
#' super_iris <- iris0 %>% normalization(method = "min-max", class_attr = "Class")
#' super_iris <- iris0 %>% normalization(method = "min-max", normalization = "row")
#'
normalization <- function(dataset, method = normalizationMethods,
                          class_attr = "Class", ...){
  # Convert all not camelCase arguments to camelCase
  classAttr <- class_attr
  checkDataset(dataset)
  checkDatasetClass(dataset, classAttr)
  checkAllColumnsNumeric(dataset, exclude = classAttr)
  method <- match.arg(method)
  classIndex <- which(names(dataset) == classAttr)
  # Strip dataset from class attribute
  datasetClass <- dataset[, classIndex]
  dataset <- dataset[, -classIndex]

  # Perform normalization
  task <- normalizationTask(dataset, method, ...)
  dataset <- doNormalization(task)

  # Join class attribute again
  dataset[, classIndex] <- datasetClass
  names(dataset)[classIndex] <- classAttr

  dataset
}