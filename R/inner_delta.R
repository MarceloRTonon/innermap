
inner_delta <- function(input, .f0, distance = 1, .names = "after"){
  .output <- purrr::map2(input[c((1+distance):length(input))],
                         input[c(1:(length(input)-distance))],
                         `-`) %>%
    .innerNames(.Output = ., .input = input, .Names = .names)
  return(.output)
}
