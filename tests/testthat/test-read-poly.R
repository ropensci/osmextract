test_that("read-poly: simplest example work", {
  toy_poly <- c(
    "test_poly",
    "first_area",
    "0 0",
    "0 1",
    "1 1",
    "1 0",
    "0 0",
    "END",
    "END"
  )
  out <- read_poly(toy_poly)
  manual_output <- sf::st_sfc(
    sf::st_multipolygon(
      list(list(rbind(c(0, 0), c(0, 1), c(1, 1), c(1, 0), c(0, 0))))
    ),
    crs = "OGC:CRS84"
  )
  expect_identical(out, manual_output)
  expect_error(read_poly(1))
})

test_that("read-poly: polygon with hole", {
  toy_poly <- c(
    "test_poly",
    "first_area",
    "0 0",
    "0 1",
    "1 1",
    "1 0",
    "0 0",
    "END",
    "!hole",
    "0.25 0.25",
    "0.75 0.25",
    "0.75 0.75",
    "0.25 0.75",
    "0.25 0.25",
    "END",
    "END"
  )
  out <- read_poly(toy_poly)
  manual_output <- sf::st_sfc(
    sf::st_multipolygon(
      list(list(
        rbind(c(0, 0), c(0, 1), c(1, 1), c(1, 0), c(0, 0)),
        rbind(c(0.25, 0.25), c(0.75, 0.25), c(0.75, 0.75), c(0.25, 0.75), c(0.25, 0.25))
      ))
    ),
    crs = "OGC:CRS84"
  )
  expect_identical(out, manual_output)
})

test_that("read-poly:two polygons", {
  toy_poly <- c(
    "test_poly",
    "first_area",
    "0 0",
    "0 1",
    "1 1",
    "1 0",
    "0 0",
    "END",
    "second_area",
    "1 1",
    "2 1",
    "2 2",
    "1 2",
    "1 1",
    "END",
    "END"
  )
  out <- read_poly(toy_poly)
  manual_output <- sf::st_sfc(
    sf::st_multipolygon(
      list(
        list(rbind(c(0, 0), c(0, 1), c(1, 1), c(1, 0), c(0, 0))),
        list(rbind(c(1, 1), c(2, 1), c(2, 2), c(1, 2), c(1, 1)))
      )
    ),
    crs = "OGC:CRS84"
  )
  expect_identical(out, manual_output)
})

test_that("read-poly: read from file", {
  toy_poly <- c(
    "test_poly",
    "first_area",
    "0 0",
    "0 1",
    "1 1",
    "1 0",
    "0 0",
    "END",
    "END"
  )
  toy_poly_file <- tempfile(fileext = ".poly")
  writeLines(toy_poly, toy_poly_file)
  out <- read_poly(toy_poly_file, crs = 4326)
  manual_output <- sf::st_sfc(
    sf::st_multipolygon(
      list(list(rbind(c(0, 0), c(0, 1), c(1, 1), c(1, 0), c(0, 0))))
    ),
    crs = 4326
  )
  expect_identical(out, manual_output)
  expect_error(
    object = read_poly("nonesitingfile.poly"),
    class = "osmext-read_poly-noURLorFileExists"
  )
})

test_that("read-poly: read from URL", {
  skip_on_cran()
  skip_if_offline("github.com")
  toy_poly <- read_poly("https://raw.githubusercontent.com/ropensci/osmextract/master/inst/toy-example.poly")
  milan_duomo <- sf::st_sfc(sf::st_point(c(9.1895, 45.4646)), crs = 4326)
  expect_true(
    object = sf::st_contains(toy_poly, milan_duomo, sparse = FALSE)
  )
})
