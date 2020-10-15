#' Apply a function a list or atomic vector using its two elements each time
#'
#' The innermap function applies a function to a list or atomic vectors using its two of their elements in sequence as input. It is different from purrr::accumulate since it does not use any of its output as an input.
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
#'
#' @return
#'    * innermap returns a list with the lenght equals  of the input minus the distance argument..
#'    * innermap_lgl, innermap_dbl, innermap_int, innermap_chr and innermpa_raw return a atomic vector the type of the pronoun, with the lenght equals of the input minus the distance argument.
#'    * innermap_dfr and innermap_dfc returns a data.frame
#'
#' @examples
#'
#' inputVec <- 1:30
#'
#' outputVec <- innermap(inputVec, ~ `+`)
#'
#' outputVec2 <- innermap_dbl(inputVec,
#'                            distance = 3,
#'                            function(x,y) x * y)
#'
#' crzletters <- innermap_chr(letters, distance =1, paste0)
#' @export
#'
#'
innermap <- function(input, .f0, distance = 1){
  .output <- purrr::map2(c(1:(length(input)-distance)), c((1+distance):length(input)),
                  function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}


#' @rdname innermap
#' @export
#'
innerma_lgl <- function(input, .f0, distance = 1){
  .output <- purrr::map2_lgl(c(1:(length(input)-distance)), c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}


#' @rdname innermap
#' @export
#'

innermap_int <- function(input, .f0, distance = 1){
  .output <- purrr::map2_int(c(1:(length(input)-distance)),
                             c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}


#' @rdname innermap
#' @export
#'

innermap_dbl <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dbl(c(1:(length(input)-distance)), c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}

#' @rdname innermap
#' @export
#'


innermap_chr <- function(input, .f0, distance = 1){
  .output <- purrr::map2_chr(c(1:(length(input)-distance)), c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}



#' @rdname innermap
#' @export
#'
innermap_raw <- function(input, .f0, distance = 1){
  .output <- purrr::map2_raw(c(1:(length(input)-distance)), c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}

#' @rdname innermap
#' @export
#'
innermap_dfr <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dfr(c(1:(length(input)-distance)), c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}

#' @rdname innermap
#' @export
#'


innermap_dfc <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dfc(c(1:(length(input)-distance)), c((1+distance):length(input)),
                             function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}
