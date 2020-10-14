innermap_dfc <- function(input, .f0){
  require(rlang, warn.conflicts = F)
  require(purrr)
  .output <- map2_dfc(c(1:(length(input)-1)), c(2:length(input)),
                  function(x1,x2) rlang::exec(.f0, input[x1], input[x2])
  )
  return(.output)
}
