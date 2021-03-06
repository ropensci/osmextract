test_that("oe_find: simplest example works", {
  # Fill the tempdir without downloading a new file
  file.copy(
    system.file("its-example.osm.pbf", package = "osmextract"),
    to = file.path(tempdir(), "its-example.osm.pbf")
  )
  oe_vectortranslate(
    file_path = file.path(tempdir(), "its-example.osm.pbf"),
    quiet = TRUE
  )

  # Run the code and tests
  its_leeds_find = oe_find(
    "ITS Leeds",
    download_directory = tempdir(),
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)

  # Clean tempdir
  file.remove(its_leeds_find)
})

test_that("download_if_missing in oe_find works", {
  skip_on_cran()
  skip_if_offline()

  # Test that tempdir is really empty
  expect_true(!file.exists(file.path(tempdir(), "its-example.osm.pbf")))

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

  # Clean tempdir
  file.remove(its_leeds_find)
})
