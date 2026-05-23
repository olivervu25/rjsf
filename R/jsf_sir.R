#' Simulate an SIR epidemic model using JSF
#'
#' This function runs a simple SIR epidemic model using the Python `jsf`
#' package through `reticulate`.
#'
#' @param N Total population size.
#' @param I0 Initial infectious population.
#' @param beta Infection rate.
#' @param gamma Recovery rate.
#' @param t_max Final simulation time.
#' @param dt Time step for the continuous/ODE part of JSF.
#' @param switching_threshold_I Switching threshold for the infectious compartment.
#'
#' @return A data frame with columns `time`, `S`, `I`, and `R`.
#' @export
jsf_sir <- function(
    N = 1000,
    I0 = 10,
    beta = 0.5,
    gamma = 0.1,
    t_max = 60,
    dt = 0.1,
    switching_threshold_I = 10
) {
  if (!jsf_available()) {
    stop(
      "Python package `jsf` is not available. ",
      "Check your reticulate Python environment.",
      call. = FALSE
    )
  }

  jsf <- reticulate::import("jsf")

  S0 <- N - I0
  R0 <- 0

  x0 <- list(
    as.numeric(S0),
    as.numeric(I0),
    as.numeric(R0)
  )

  rates <- reticulate::py_eval(sprintf(
    "lambda x, t: [%f * x[0] * x[1] / %f, %f * x[1]]",
    beta,
    N,
    gamma
  ))

  reactant <- list(
    list(1L, 1L, 0L), # S + I -> 2I
    list(0L, 1L, 0L)  # I -> R
  )

  product <- list(
    list(0L, 2L, 0L),
    list(0L, 0L, 1L)
  )

  nu <- list(
    list(-1L, 1L, 0L),
    list(0L, -1L, 1L)
  )

  stoich <- list(
    nu = nu,
    DoDisc = list(0L, 1L, 0L),
    nuReactant = reactant,
    nuProduct = product
  )

  opts <- list(
    EnforceDo = list(0L, 0L, 0L),
    dt = as.numeric(dt),
    SwitchingThreshold = list(
      as.numeric(N),
      as.numeric(switching_threshold_I),
      as.numeric(N)
    )
  )

  sim <- jsf$jsf(
    x0,
    rates,
    stoich,
    t_max = as.numeric(t_max),
    config = opts,
    method = "operator-splitting"
  )

  out <- data.frame(
    time = unlist(sim[[2]]),
    S = unlist(sim[[1]][[1]]),
    I = unlist(sim[[1]][[2]]),
    R = unlist(sim[[1]][[3]])
  )

  out <- out[out$time <= as.numeric(t_max), ]
  row.names(out) <- NULL

  return(out)
}
