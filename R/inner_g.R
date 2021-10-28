
inner_g <- function(input, .f0, distance = 1){
  .output <- purrr::map2(input[c((1+distance):length(input))],
                         input[c(1:(length(input)-distance))],
                         x/y)
  return(.output)
}
