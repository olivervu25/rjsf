test_that("new_jsf_result creates a JSFResult object", {
  state <- data.frame(
    prey = c(50, 51, 52),
    predator = c(10, 9, 9)
  )

  result <- new_jsf_result(
    time = c(0, 0.1, 0.2),
    state = state,
    config = list(dt = 0.1)
  )

  expect_true(S7::S7_inherits(result, JSFResult))
  expect_equal(result@time, c(0, 0.1, 0.2))
  expect_equal(result@state, state)
  expect_equal(result@species_names, c("prey", "predator"))
  expect_equal(result@method, "operator-splitting")
  expect_equal(result@config, list(dt = 0.1))
})

test_that("as_jsf_result converts data frame output", {
  df <- data.frame(
    time = c(0, 0.1, 0.2),
    S = c(990, 988, 985),
    I = c(10, 12, 15),
    R = c(0, 0, 0)
  )

  result <- as_jsf_result(
    df,
    config = list(model = "SIR", dt = 0.1)
  )

  expect_true(S7::S7_inherits(result, JSFResult))
  expect_equal(result@time, df$time)
  expect_equal(result@species_names, c("S", "I", "R"))
  expect_equal(result@state, df[, c("S", "I", "R")])
})

test_that("JSFResult validates time and state dimensions", {
  state <- data.frame(
    prey = c(50, 51),
    predator = c(10, 9)
  )

  expect_error(
    new_jsf_result(
      time = c(0, 0.1, 0.2),
      state = state
    ),
    "`@time`"
  )
})
