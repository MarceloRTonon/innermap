innerma_lgl <- function(input, .f0, distance = 1){
  require(rlang, warn.conflicts = F)
  require(purrr)
  .output <- map2_lgl(c(1:(length(input)-distance)), c((1+distance):length(input)),
                  function(x1,x2) rlang::exec(.f0, input[x1], input[x2])
  )
  return(.output)
}
