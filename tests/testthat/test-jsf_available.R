test_that("jsf_available returns a logical scalar", {
  result <- jsf_available()

  expect_type(result, "logical")
  expect_length(result, 1)
})
