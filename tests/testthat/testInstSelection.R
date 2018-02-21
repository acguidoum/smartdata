library(testthat)
library(imbalance)
# Loads data
data(ecoli1)
data(glass0)
data(haberman)
data(iris0)
data(newthyroid1)
data(wisconsin)
data(yeast4)

context("Instance selection testing")

# We change the class attribute in a dataset
modecoli <- ecoli1
names(modecoli)[ncol(modecoli)] <- "my_class"

test_that("Correct instance selection", {
  expect_error(instance_selection(iris0, "ENN"), NA)
  expect_error(instance_selection(glass0, "CNN"), NA)
  expect_error(instance_selection(haberman, "multiedit", class_attr = "Class"), NA)
  expect_error(instance_selection(newthyroid1, method = "multiedit", k = 3, I = 7), NA)
  expect_error(instance_selection(iris0, method = "ENN", k = 1), NA)
  expect_error(instance_selection(iris0, method = "ENN", k = 0))
  expect_error(instance_selection(modecoli, method = "FRIS"))
  expect_error(instance_selection(modecoli, method = "FRIS", class_attr = "my_class"), NA)
})