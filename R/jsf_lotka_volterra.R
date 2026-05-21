#' Simulate a Lotka-Volterra predator-prey model using JSF
#'
#' This function runs a simple Lotka-Volterra predator-prey model using the
#' Python `jsf` package through `reticulate`.
#'
#' @param prey0 Initial prey population.
#' @param predator0 Initial predator population.
#' @param prey_birth Prey birth rate.
#' @param predation Predation rate.
#' @param predator_death Predator death rate.
#' @param t_max Final simulation time.
#' @param dt Time step for the continuous/ODE part of JSF.
#' @param switching_threshold Switching threshold for both species.
#'
#' @return A data frame with columns `time`, `prey`, and `predator`.
#' @export

jsf_lotka_volterra <- function(
  prey0 = 50,
  predator0 = 10,
  prey_birth = 2.0,
  predation = 0.05,
  predator_death = 1.5,
  t_max = 10,
  dt = 0.01,
  switching_threshold = 30
){
  jsf <- reticulate::import("jsf")

  x0 <- list(
    as.numeric(prey0),
    as.numeric(predator0)
  )

  rates <- reticulate::py_eval(sprintf(
    "lambda x, t: [%f * x[0], %f * x[1], %f * x[0] * x[1]]",
    prey_birth,
    predator_death,
    predation
  ))

  reactant <- list(
    list(1L, 0L),
    list(0L, 1L),
    list(1L, 1L)
  )

  product <- list(
    list(2L, 0L),
    list(0L, 0L),
    list(0L, 2L)
    )

  nu <- list(
    list(1L, 0L),
    list(0L, -1L),
    list(-1L, 1L)
  )

  stoich <- list(
    nu = nu,
    DoDisc = list(1L, 1L),
    nuReactant = reactant,
    nuProduct = product
    )

  opts <- list(
    EnforceDo = list(0L, 0L),
    dt = as.numeric(dt),
    SwitchingThreshold = list(
      as.numeric(switching_threshold),
      as.numeric(switching_threshold)
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

  data.frame(
    time = unlist(sim[[2]]),
    prey = unlist(sim[[1]][[1]]),
    predator = unlist(sim[[1]][[2]])
    )

  out <- data.frame(
    time = unlist(sim[[2]]),
    prey = unlist(sim[[1]][[1]]),
    predator = unlist(sim[[1]][[2]])
  )

  out <- data.frame(
    time = unlist(sim[[2]]),
    prey = unlist(sim[[1]][[1]]),
    predator = unlist(sim[[1]][[2]])
  )

  out <- out[out$time <= as.numeric(t_max), ]
  row.names(out) <- NULL

  out
}
