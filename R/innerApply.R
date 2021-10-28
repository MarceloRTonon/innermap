#' Apply a function to an atomic vector using its two elements each time
#'
#'#' The innerApply function applies a function to an atomic vector using two of its elements in sequence as inputs. It is different from purrr::accumulate since it does not use any of its output as an input.
#'
#' @param input An atomic vector.
#' @param .f0 A function. Anonymous functions are supported. Formula or vectors are not.
#'
#' @param distance The distance between each element of the vector. The default value is 1.
#'
#' @details If the function used as .f0 returns a vector of length higher than 1, the function will throw an error.
#'
#' @return An atomic vector of length equals length(input)-distance.
#' @export
#'
#' @examples
#'
#'
#' inputVec <- 1:30
#'
#' outputVec <- innerApply(inputVec, `+`)
#'
#' innerApply(letters, paste0)
#'
#' innerApply(c(TRUE,FALSE,TRUE,FALSE), `!=`)

innerApply <- function(input, .f0, distance =1){
  .f0(input[c(1:(length(input)-distance))],
      input[c((1+distance):length(input))]
      )
}

