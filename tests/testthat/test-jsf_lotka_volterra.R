test_that("jsf_lotka_volterra returns valid output", {
  out <- jsf_lotka_volterra(t_max = 2)

  expect_s3_class(out, "data.frame")
  expect_true(all(c("time", "prey", "predator") %in% names(out)))

  expect_true(all(out$time >= 0))
  expect_true(max(out$time) <= 2)

  expect_true(all(out$prey >= 0))
  expect_true(all(out$predator >= 0))
})
