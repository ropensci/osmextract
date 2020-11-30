test_that("oe_update(): simplest example works", {
  skip_if_offline()
  fake_dir = tempdir()
  oe_get(
    "ITS Leeds",
    provider = "test",
    download_directory = fake_dir,
    download_only = TRUE
  )
  expect_error(oe_update(fake_dir, quiet = TRUE), NA)
  expect_message(oe_update(fake_dir, quiet = FALSE))
})
