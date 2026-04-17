test_that("oe_providers works correctly", {
  expect_s3_class(oe_providers(), class = "data.frame")
})
