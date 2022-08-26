test_that("oe_get_network: simplest examples work", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  expect_error(oe_get_boundary("ITS Leeds", quiet = TRUE), NA)
})
