test_that("oe_get_keys: simplest examples work", {
  skip_if_offline()
  itsleeds_gpkg <- oe_get("itsleeds", provider = "test", download_only = TRUE)
  expect_type(oe_get_keys(itsleeds_gpkg), "character")
})

test_that("oe_get_keys: returns error with wrong inputs", {
  expect_error(oe_get_keys("xxx.gpkg")) # file does not exist
  skip_if_offline()
  itsleeds_pbf <- oe_get("itsleeds", provider = "test", download_only = TRUE, skip_vectortranslate = TRUE)
  expect_error(oe_get_keys(itsleeds_pbf)) # wrong format
})
