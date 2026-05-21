#' Check whether the Python jsf package is available
jsf_available <- function() {
  reticulate::py_module_available("jsf")
}
