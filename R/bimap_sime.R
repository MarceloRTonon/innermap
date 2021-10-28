bimap_sime <- function(.x, .y, .depth, .f, ..., .ragged = FALSE) {


  if (!is_integerish(.depth, n = 1, finite = TRUE)) {
    abort("`.depth` must be a single number")
  }


  if (.depth < 0) {
    .depth <- vec_depth(.x) + .depth
  }

  .f <- as_mapper(.f, ...)
    map2_depth_rec(.x = .x, .y = .y, .depth, .f, ..., .ragged = .ragged, .atomic = FALSE)
}



map2_depth_rec <- function(.x,
                           .y,
                           .depth,
                           .f,
                           ...,
                           .ragged,
                           .atomic) {
  if (.depth < 0) {
    abort("Invalid depth")
  }

  if (all(.atomic)) {
    if (!.ragged) {
      abort(paste("List", enexpr(.x), "not deep enough"))
    }
    return(map2(.x, .y, .f, ...))
  }

  if (.depth == 0) {
    return(.f(.x, .y, ...))
  }

  if (.depth == 1) {
    return(map2(.x, .y, .f, ...))
  }

  # Should this be replaced with a generic way of figuring out atomic
  # types?
  .atomic <- c(is_atomic(.x),is_atomic(.y))

  map2(.x, .y, function(x, y) {
    map2_depth_rec(x, y, .depth - 1, .f, ..., .ragged = .ragged, .atomic = .atomic)
  })
}
