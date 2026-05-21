#' Check whether the Python jsf package is available
#'
#' This function checks whether the Python `jsf` module can be found by
#' `reticulate` in the currently active Python environment.
#'
#' @return A single logical value. `TRUE` if `jsf` is available, otherwise `FALSE`.
#' @export
jsf_available <- function() {
  reticulate::py_module_available("jsf")
}
