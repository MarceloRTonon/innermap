
innermap <- function(input, .f0){
  require(rlang)
  require(purrr)
  .output <- map2(c(1:(length(input)-1)), c(2:length(input)),
                  function(x1,x2) rlang::exec(.f0, input[x1], input[x2])
                  )
  return(.output)
}


innermodify <- function(input, .f0){
  require(rlang)
  require(purrr)
  .output <- modify2(c(1:(length(input)-1)), c(2:length(input)),
                  function(x1,x2) rlang::exec(.f0, input[x1], input[x2])
  )
  return(.output)
}

innermodify(inputVec, sum) %>% unlist()


additiveDec  <-  function(t0, t1)
  

require(gtools)


y <- c(1:5 *2)
delta <- list()
for (2 in length(y)) {
  delta[[i]] <- y[[i]] - y[[i-1]]
}

map2(c(1:4), c(2:5), ~ y[.y] - y[.x])
