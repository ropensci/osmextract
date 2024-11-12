test_that("oe_providers works correctly", {
  expect_message(oe_providers(quiet = FALSE), class = "oe_providers_Info")
})
