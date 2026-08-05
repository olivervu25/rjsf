#' Simulate a compartmental model using JSF
#'
#' This is a general R wrapper around the Python `jsf` simulator.
#' It accepts an initial state, a Python rate function, reactant and product
#' stoichiometry matrices, and JSF configuration options.
#'
#' @param x0 Numeric vector of initial states.
#' @param rates Python callable rate function, usually created with
#'   `reticulate::py_eval()`.
#' @param reactant Matrix where each row gives the reactants for one reaction.
#' @param product Matrix where each row gives the products for one reaction.
#' @param do_disc Integer vector indicating which species may be treated
#'   discretely/stochastically.
#' @param t_max Final simulation time.
#' @param species_names Optional character vector of species names.
#' @param dt Time step for the continuous/ODE part of JSF.
#' @param switching_threshold Switching threshold. Can be a scalar or one value
#'   per species.
#' @param enforce_do Integer vector controlling enforced discrete behaviour.
#'   Defaults to zero for all species.
#' @param method JSF simulation method.
#' @param return_type Output type. Either `"data.frame"` or `"JSFResult"`.
#'
#' @return If `return_type = "data.frame"`, a data frame with a `time` column
#'   and one column per species. If `return_type = "JSFResult"`, a `JSFResult`
#'   object.
#' @examples
#' \dontrun{
#' library(reticulate)
#'
#' rates_lv <- reticulate::py_eval(
#'   "lambda x, t: [2.0 * x[0], 1.5 * x[1], 0.05 * x[0] * x[1]]"
#' )
#'
#' result <- jsf_simulate(
#'   x0 = c(prey = 50, predator = 10),
#'   rates = rates_lv,
#'   reactant = matrix(
#'     c(
#'       1, 0,
#'       0, 1,
#'       1, 1
#'     ),
#'     ncol = 2,
#'     byrow = TRUE
#'   ),
#'   product = matrix(
#'     c(
#'       2, 0,
#'       0, 0,
#'       0, 2
#'     ),
#'     ncol = 2,
#'     byrow = TRUE
#'   ),
#'   do_disc = c(1, 1),
#'   t_max = 10,
#'   dt = 0.01,
#'   switching_threshold = c(30, 30),
#'   species_names = c("prey", "predator"),
#'   return_type = "JSFResult"
#' )
#'
#' result
#' summary(result)
#' plot(result)
#' }
#' @export
jsf_simulate <- function(
    x0,
    rates,
    reactant,
    product,
    do_disc,
    t_max,
    dt,
    switching_threshold,
    tau_threshold = NULL,
    tau_epsilon = 0.03,
    critical_threshold = 10,
    tau_debug = FALSE,
    tau_debug_every = 20,
    tau_debug_max = 30,
    species_names = NULL,
    enforce_do = NULL,
    method = "operator-splitting",
    return_type = c("data.frame", "JSFResult")
) {
  if (!jsf_available()) {
    stop(
      "Python package `jsf` is not available.",
      "Check your reticulate Python environment.",
      call. = FALSE
    )
  }

  n_species <- length(x0)

  return_type <- match.arg(return_type)

  if (!is.numeric(dt) || length(dt) != 1 || dt <= 0) {
    stop("`dt` must be a positive numeric scalar.", call. = FALSE)
  }

  if (!is.numeric(t_max) || length(t_max) != 1 || t_max <= 0) {
    stop("`t_max` must be a positive numeric scalar.", call. = FALSE)
  }

  if (is.null(species_names)) {
    species_names <- names(x0)
  }

  if (is.null(species_names)) {
    species_names <- paste0("species_", seq_len(n_species))
  }

  if (length(species_names) != n_species) {
    stop("`species_names` must have the same length as `x0`.", call. = FALSE)
  }

  if (length(do_disc) != n_species) {
    stop("`do_disc` must have the same length as `x0`.", call. = FALSE)
  }

  if (is.null(enforce_do)) {
    enforce_do <- rep(0L, n_species)
  }

  if (length(enforce_do) != n_species) {
    stop("`enforce_do` must have the same length as `x0`.", call. = FALSE)
  }

  if (length(switching_threshold) == 1) {
    switching_threshold <- rep(switching_threshold, n_species)
  }

  if (length(switching_threshold) != n_species) {
    stop(
      "`switching_threshold` must be either a scalar or have the same length as `x0`.",
      call. = FALSE
    )
  }

  reactant_mat <- as.matrix(reactant)
  product_mat <- as.matrix(product)

  if (!all(dim(reactant_mat) == dim(product_mat))) {
    stop("`reactant` and `product` must have the same dimensions.", call. = FALSE)
  }

  if (ncol(reactant_mat) != n_species) {
    stop(
      "The number of columns in `reactant` and `product` must match the length of `x0`.",
      call. = FALSE
    )
  }

  nu_mat <- product_mat - reactant_mat

  matrix_to_list <- function(mat) {
    lapply(seq_len(nrow(mat)), function(i) {
      as.list(as.integer(mat[i, ]))
    })
  }

  jsf <- reticulate::import("jsf")

  stoich <- list(
    nu = matrix_to_list(nu_mat),
    DoDisc = as.list(as.integer(do_disc)),
    nuReactant = matrix_to_list(reactant_mat),
    nuProduct = matrix_to_list(product_mat)
  )

  if (is.null(tau_threshold)) {
    tau_threshold <- switching_threshold
  }

  if (length(tau_threshold) == 1) {
    tau_threshold <- rep(tau_threshold, length(x0))
  }

  if (length(tau_threshold) != n_species) {
    stop(
      "`tau_threshold` must be either NULL, a scalar, or have the same length as `x0`.",
      call. = FALSE
    )
  }

  if (!is.numeric(tau_epsilon) || length(tau_epsilon) != 1 || tau_epsilon <= 0) {
    stop("`tau_epsilon` must be a positive numeric scalar.", call. = FALSE)
  }

  if (!is.numeric(critical_threshold) || length(critical_threshold) != 1 || critical_threshold < 0) {
    stop("`critical_threshold` must be a non-negative numeric scalar.", call. = FALSE)
  }

  opts <- list(
    EnforceDo = as.list(as.integer(enforce_do)),
    dt = as.numeric(dt),
    SwitchingThreshold = as.list(as.numeric(switching_threshold)),
    TauThreshold = as.list(as.numeric(tau_threshold)),
    TauEpsilon = as.numeric(tau_epsilon),
    CriticalThreshold = as.integer(critical_threshold),
    TauDebug = isTRUE(tau_debug),
    TauDebugEvery = as.integer(tau_debug_every),
    TauDebugMax = as.integer(tau_debug_max)
  )

  sim <- jsf$jsf(
    as.list(as.numeric(x0)),
    rates,
    stoich,
    t_max = as.numeric(t_max),
    config = opts,
    method = method
  )

  out <- data.frame(
    time = unlist(sim[[2]])
  )

  for (i in seq_len(n_species)) {
    out[[species_names[i]]] <- unlist(sim[[1]][[i]])
  }

  out <- out[out$time <= as.numeric(t_max), ]
  row.names(out) <- NULL

  if (return_type == "data.frame") {
    return(out)
  }

  as_jsf_result(
    out,
    method = method,
    config = list(
      dt = dt,
      switching_threshold = switching_threshold,
      enforce_do = enforce_do,
      do_disc = do_disc
    )
  )
}
