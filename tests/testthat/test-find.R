test_that("oe_find: simplest example works", {
  its_leeds_find <- oe_find(
    "ITS Leeds",
    provider = "test",
    download_if_missing = TRUE,
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")

  file.remove(its_leeds_find)
  its_leeds_find <- oe_find(
    "ITS Leeds",
    provider = "test",
    download_if_missing = TRUE,
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
})
