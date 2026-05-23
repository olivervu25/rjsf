test_that("jsf_sir returns valid output", {
  out <- jsf_sir(t_max = 5)

  expect_s3_class(out, "data.frame")
  expect_true(all(c("time", "S", "I", "R") %in% names(out)))

  expect_true(all(out$time >= 0))
  expect_true(max(out$time) <= 5)

  expect_true(all(out$S >= 0))
  expect_true(all(out$I >= 0))
  expect_true(all(out$R >= 0))
})
