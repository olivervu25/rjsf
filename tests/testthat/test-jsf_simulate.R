test_that("jsf_simulate works for Lotka-Volterra", {
  rates_lv <- reticulate::py_eval(
    "lambda x, t: [2.0 * x[0], 1.5 * x[1], 0.05 * x[0] * x[1]]"
  )

  out <- jsf_simulate(
    x0 = c(prey = 50, predator = 10),
    rates = rates_lv,
    reactant = matrix(
      c(
        1, 0,
        0, 1,
        1, 1
      ),
      ncol = 2,
      byrow = TRUE
    ),
    product = matrix(
      c(
        2, 0,
        0, 0,
        0, 2
      ),
      ncol = 2,
      byrow = TRUE
    ),
    do_disc = c(1, 1),
    t_max = 2,
    dt = 0.01,
    switching_threshold = c(30, 30),
    species_names = c("prey", "predator")
  )

  expect_s3_class(out, "data.frame")
  expect_true(all(c("time", "prey", "predator") %in% names(out)))
  expect_true(all(out$time >= 0))
  expect_true(max(out$time) <= 2)
  expect_true(all(out$prey >= 0))
  expect_true(all(out$predator >= 0))
})

test_that("jsf_simulate works for SIR", {
  N <- 1000
  beta <- 0.5
  gamma <- 0.1

  rates_sir <- reticulate::py_eval(sprintf(
    "lambda x, t: [%f * x[0] * x[1] / %f, %f * x[1]]",
    beta,
    N,
    gamma
  ))

  out <- jsf_simulate(
    x0 = c(S = 990, I = 10, R = 0),
    rates = rates_sir,
    reactant = matrix(
      c(
        1, 1, 0,
        0, 1, 0
      ),
      ncol = 3,
      byrow = TRUE
    ),
    product = matrix(
      c(
        0, 2, 0,
        0, 0, 1
      ),
      ncol = 3,
      byrow = TRUE
    ),
    do_disc = c(0, 1, 0),
    t_max = 5,
    dt = 0.1,
    switching_threshold = c(N, 10, N),
    species_names = c("S", "I", "R")
  )

  expect_s3_class(out, "data.frame")
  expect_true(all(c("time", "S", "I", "R") %in% names(out)))
  expect_true(all(out$time >= 0))
  expect_true(max(out$time) <= 5)
  expect_true(all(out$S >= 0))
  expect_true(all(out$I >= 0))
  expect_true(all(out$R >= 0))
})
