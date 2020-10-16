#' Apply a function to a list or atomic vector using its two elements each time
#'
#' The innermap function applies a function to a list or atomic vectors using its two of their elements in sequence as input. It is different from purrr::accumulate() since it does not use any of its output as an input. Although the innermap family accepts atomic as inputs, the use of the innerApply() function is way more faster.
#'
#' @param input A list or atomic vector.
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
#' @seealso [innerApply()] for applying a function to sequentional elements of an atomic vector, is way more faster than any element of the innermap family.
#'
#'
#' @return
#'    * innermap returns a list with the lenght equals  of the input minus the distance argument..
#'    * innermap_lgl, innermap_dbl, innermap_int, innermap_chr and innermpa_raw return a atomic vector the type of the pronoun, with the lenght equals of the input minus the distance argument.
#'    * innermap_dfr and innermap_dfc returns a data.frame
#'
#' @examples
#'
#' library(plyr)
#' library(magrittr)
#'
#' # Making cell to cell operations
#'
#' plyr::alply(ozone, 3) %>%
#' innermap(`/`)
#'
#'
#' # Making logical operations for the matrices as a
#' # whole and returning a logical vector
#'
#' plyr::alply(ozone,3) %>%
#' innermap_lgl(identical)
#'
#' # Making logical operations for the matrices elements
#' # and creating a data frame by column-binding it.
#'
#' plyr::alply(ozone, 3, colMeans) %>%
#' innermap(function(x,y) x <= y)
#'
#' # Using all.equal for the matrices and returning a character vector.
#'
#' plyr::alply(ozone, 3) %>%
#' innermap_chr(function(x,y) all.equal(x,y)[1], distance =2)
#'
#'
#' @export
#'
#'
innermap <- function(input, .f0, distance = 1){
  .output <- purrr::map2(input[c(1:(length(input)-distance))],
                         input[c((1+distance):length(input))],
                         .f0)
  return(.output)
}


#' @rdname innermap
#' @export
#'
innermap_lgl <- function(input, .f0, distance = 1){
  .output <- purrr::map2_lgl(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}


#' @rdname innermap
#' @export
#'

innermap_int <- function(input, .f0, distance = 1){
  .output <- purrr::map2_int(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}


#' @rdname innermap
#' @export
#'

innermap_dbl <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dbl(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}

#' @rdname innermap
#' @export
#'


innermap_chr <- function(input, .f0, distance = 1){
  .output <- purrr::map2_chr(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}



#' @rdname innermap
#' @export
#'
innermap_raw <- function(input, .f0, distance = 1){
  .output <- purrr::map2_raw(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}

#' @rdname innermap
#' @export
#'
innermap_dfr <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dfr(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}

#' @rdname innermap
#' @export
#'


innermap_dfc <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dfc(input[c(1:(length(input)-distance))],
                             input[c((1+distance):length(input))],
                             .f0)
  return(.output)
}
