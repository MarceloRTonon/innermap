library(microbenchmark)
library(purrr)
library(innermap)
library(dplyr)


leadApply <- function(ivec, func, dist =1){
  func(ivec, dplyr::lead(ivec, dist))[1:(length(ivec)-dist)]
}

inputVec <- 1:100000

leadApply(1:10, `+`, 5)

microbenchmark(
  "Old innermap_dbl" = {innermap_dbl(inputVec, `+`, 5)},
  "New innermap_dbl" = {innermap_dbl2(inputVec, `+`, 5)},
  "leadApply" = {leadApply(inputVec, `+`, 5)},
  times = 10
)

innermap_dbl2 <- function(input, .f0, distance = 1){
  .output <- purrr::map2(input, dplyr::lead(input, distance), .f0)[c(1:(length(input)-distance))]
}


microbenchmark(
  "innermap_chr" = {innermap_chr(letters, paste0)},
  "leadApply" = {leadApply(letters, paste0)},
  times = 20
)
