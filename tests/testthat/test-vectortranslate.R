# Prepare for the tests
its_match = oe_match("ITS Leeds", provider = "test")
its_pbf = oe_download(
  file_url = its_match$url,
  file_size = its_match$file_size,
  download_directory = tempdir(),
  provider = "test",
  quiet = TRUE
)

test_that("oe_vectortranslate: simplest examples work", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_equal(tools::file_ext(its_gpkg), "gpkg")
  file.remove(its_gpkg)
})

test_that("oe_vectortranslate returns file_path is .gpkg exists", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_message(
    oe_vectortranslate(its_pbf),
    "Skip vectortranslate operations."
  )
  file.remove(its_gpkg)
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
  file.remove(its_gpkg)
})

test_that("oe_vectortranslate adds new tags to existing file", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  new_its_gpkg = oe_vectortranslate(its_pbf, extra_tags = c("oneway"), quiet = TRUE)
  expect_match(
    paste(names(sf::st_read(new_its_gpkg, quiet = TRUE)), collapse = "-"),
    "oneway"
  )
  file.remove(new_its_gpkg)
})

test_that("oe_get_keys: simplest example works", {
  itsleeds_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_type(oe_get_keys(itsleeds_gpkg), "character")

  file.remove(itsleeds_gpkg)
})

test_that("oe_get_keys: returns error with wrong inputs", {
  expect_error(oe_get_keys("xxx.gpkg")) # file does not exist
})

test_that("oe_get_keys stop when there is no other_tags field", {
  my_vectortranslate <- c(
    "-f", "GPKG",
    "-overwrite",
    "-select", "highway",
    "lines"
  )
  oe_get(
    "ITS Leeds",
    vectortranslate_options = my_vectortranslate,
    download_directory = tempdir()
  )
  its <- oe_get("ITS Leeds", download_only = TRUE, download_directory = tempdir())
  expect_error(
    oe_get_keys(its),
    "The input file must have an other_tags field."
  )
  file.remove(oe_find("ITS Leeds", provider = "test", download_directory = tempdir()))
})
