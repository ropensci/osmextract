test_that("oe_update(): simplest example works", {
  # I always need internet connection when running oe_update()
  skip_on_cran()
  skip_if_offline("github.com")

  # expect_error(oe_update(tempdir(), quiet = TRUE), NA)

  # AG: I decided to comment out that test since I don't see any benefit testing
  # the "verbose" output during R CMD checks (that I rarely check manually)
  # expect_message(oe_update(fake_dir, quiet = FALSE))
  # file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})
