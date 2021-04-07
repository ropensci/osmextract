test_that("oe_find: simplest example works", {
  # Fill the tempdir
  oe_get("ITS Leeds", download_directory = tempdir(), quiet = TRUE)

  its_leeds_find = oe_find(
    "ITS Leeds",
    provider = "test",
    download_directory = tempdir(),
    download_if_missing = TRUE,
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
  file.remove(its_leeds_find)
})

test_that("download_if_missing in oe_find works", {
  # Test download_if_missing
  its_leeds_find = oe_find(
    "ITS Leeds",
    provider = "test",
    download_directory = tempdir(),
    download_if_missing = TRUE,
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
  file.remove(its_leeds_find)
})
