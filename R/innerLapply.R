innerLapply <- function(input, .f0, distance =1, ...){
  if(rlang::is_formula(.f0)){
    abort(message = "`innerLapply does not support formula")
  }

    list(.x = input[c(1:(length(input)-1))],
         .y = input[c(2:length(input))]) |>
    purrr::transpose() |>
    lapply(FUN = function(.input) .input$.x+ .input$.y)
}
