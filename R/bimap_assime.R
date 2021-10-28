bimap_assime <- function(.x, .y, .depth, .f, ..., .ragged = FALSE){


  if (!is_integerish(.depth, n = 2, finite = TRUE)) {
    abort("`.depth` length must equal 2")
  }

  if(any(.depth<0)){
    .depth[.depth<0] <- (c(vec_depth(.x), vec_depth(.y)) + .depth)[.depth<0]
  }

  .depthDiff <- abs(.depth[1] - .depth[2])

  if(.depth[1]<.depth[2]){
    return(purrr::map_depth(.x = .y, .depthDiff,
                     innermap::bimap_sime, .y = .x, .depth = .depth[2], .f=.f, ..., .ragged = .ragged))
  }
  if(.depth[1]>.depth[2]){
    return(purrr::map_depth(.x = .x, .depthDiff,
                     innermap::bimap_sime, .y = .y, .depth = .depth[2], .f = .f, ..., .ragged = .ragged))
  }

  if(.depth[1] == .depth[2]){
    return(innermap::bimap_sime(.x, .y, .depth[1], .f =.f, ..., .ragged = .ragged))
  }

}
