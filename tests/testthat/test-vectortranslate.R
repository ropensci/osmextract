# Prepare for the tests
its_match = oe_match("ITS Leeds", provider = "test")
its_pbf = oe_download(
  file_url = its_match$url,
  file_size = its_match$file_size,
  download_directory = tempdir(),
  provider = "test"
)

test_that("oe_vectortranslate: simplest examples work", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_equal(tools::file_ext(its_gpkg), "gpkg")
})

test_that("oe_vectortranslate returns file_path is .gpkg exists", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  new_its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_equal(its_gpkg, new_its_gpkg)
})

test_that("oe_vectortranslate adds new tags", {
  its_gpkg = oe_vectortranslate(
    its_pbf,
    extra_tags = "oneway",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, quiet = TRUE)), collapse = "-"),
    "oneway"
  )
})

test_that("oe_vectortranslate adds new tags to existing file", {
  new_its_gpkg = oe_vectortranslate(its_pbf, extra_tags = c("oneway"), quiet = TRUE)
  expect_match(
    paste(names(sf::st_read(new_its_gpkg, quiet = TRUE)), collapse = "-"),
    "oneway"
  )
})

test_that("oe_get_keys: simplest examples work", {
  skip_if_offline()
  itsleeds_gpkg = oe_get(
    "itsleeds",
    provider = "test",
    download_only = TRUE,
    quiet = TRUE
  )
  expect_type(oe_get_keys(itsleeds_gpkg), "character")
})

test_that("oe_get_keys: returns error with wrong inputs", {
  expect_error(oe_get_keys("xxx.gpkg")) # file does not exist
  skip_if_offline()
  itsleeds_pbf = oe_get(
    "itsleeds",
    provider = "test",
    download_only = TRUE,
    skip_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_error(oe_get_keys(itsleeds_pbf)) # wrong format
})
