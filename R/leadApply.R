#' Apply a function to an atomic vector using its two elements each time
#'
#'#' The innermap function applies a function to an atomic vector using two of its elements in sequence as inputs. It is different from [purrr::accumulate()] since it does not use any of its output as an input.
#'
#' @param input An atomic vector.
#' @param .f0 A function, formula, or vector (not necessarily atomic)
#'
#'  If a __function__, it is used as is.
#'
#'  If a __formula__, e.g. `~ .x + 2`, it is converted to a function. There are three ways to refer to the arguments:
#'
#'   * For a single argument function, use `.`
#'   * For a two argument function, use `.x` and `.y`
#'   * For more arguments, use `..1`, `..2`, `..3` etc
#'
#'    This syntax allows you to create very compact anonymous functions. Note that formula functions conceptually take dots (that's why you can use `..1` etc). They silently ignore additional arguments that are not used in the formula expression.
#' @param distance The distance between each element of the vector. The default value is 1.
#'
#' @return An atomic vector
#' @export
#'
#' @examples
#'
#'
#' inputVec <- 1:30
#'
#' outputVec <- leadApply(inputVec, `+`)
#'
#' leadApply(letters, paste0)
#'
#' leadApply(c(T,F,T,F), `!=`)

leadApply <- function(input, .f0, distance =1){
  .f0(input, dplyr::lead(input, distance))[1:(length(input)-distance)]
}
