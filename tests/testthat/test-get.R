test_that("oe_get: simplest examples work", {
  expect_s3_class(oe_get("ITS Leeds", provider = "test"), "sf")
})
