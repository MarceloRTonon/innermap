innermap_raw <- function(input, .f0, distance = 1){
  .output <- purrr::map2_raw(c(1:(length(input)-distance)), c((1+distance):length(input)),
                  function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}
