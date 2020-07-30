test_that("oe_match: simplest examples work", {
  expect_match(oe_match("Italy")$url, "italy")
  expect_match(oe_match("Leeds", provider = "bbbike")$url, "Leeds")
})

test_that("oe_match: error with new classes", {
  expect_error(oe_match(c(1 + 2i, 1 - 2i)))
  # See #97 for new classes
})

test_that("oe_match: sfc_POINT objects", {
  # simplest example with geofabrik
  milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
  expect_match(oe_match(milan_duomo)$url, "italy")

  # simplest example with bbbike
  leeds = sf::st_sfc(sf::st_point(c(430147.8, 433551.5)), crs = 27700)
  expect_match(oe_match(leeds, provider = "bbbike")$url, "Leeds")

  # an sfc_POINT object that does not intersect anything
  # the point is in the middle of the atlantic ocean
  ocean = sf::st_sfc(sf::st_point(c(-39.325649, 29.967632)), crs = 4326)
  expect_error(oe_match(ocean), regexp = "input place does not intersect")
  expect_error(
    oe_match(ocean, provider = "bbbike"),
    regexp = "input place does not intersect"
  )

  # See https://github.com/ITSLeeds/osmextract/issues/98
  # an sfc_POINT that does intersect two cities with bbbike
  # the problem is (or, at least, it should be) less severe with geofabrik
  amsterdam_utrecht = sf::st_sfc(sf::st_point(c(4.988327, 52.260453)), crs = 4326)
  # the point is midway between amsterdam and utrecth, closer to Amsterdam, and
  # it intersects both bboxes
  expect_message(oe_match(amsterdam_utrecht, provider = "bbbike", quiet = FALSE))
  expect_match(oe_match(amsterdam_utrecht, provider = "bbbike")$url, "Amsterdam")
})

test_that("oe_match: numeric input", {
  expect_match(oe_match(c(9.1916, 45.4650))$url, "italy")
})

test_that("oe_match: different providers, match_by or max_string dist args", {
  expect_error(oe_match("Italy", provider = "XXX"))
  expect_error(oe_match("Italy", match_by = "XXX"))
  expect_match(oe_match("RU", match_by = "iso3166_1_alpha2")$url, "russia")

  expect_error(oe_match("Isle Wight"))
  expect_match(oe_match("Isle Wight", max_string_dist = 3)$url, "isle-of-wight")
  expect_message(oe_match("London", max_string_dist = 3, quiet = FALSE))

  # It returns a warning since Berin is matched both with Benin and Berlin
  expect_warning(oe_match("Berin"))
})


test_that("oe_match: Cannot specify more than one place", {
  # Characters
  expect_error(oe_match(c("Italy", "Spain")))
  expect_error(oe_match("Italy", "Spain"))

  # sfc_POINT
  milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
  leeds = sf::st_sfc(sf::st_point(c(430147.8, 433551.5)), crs = 27700)
  expect_error(oe_match(c(milan_duomo, leeds)))
  expect_error(oe_match(milan_duomo, leeds))

  # numeric
  expect_error(oe_match(c(9.1916, 45.4650, -1.543794, 53.698968)))
  expect_error(oe_match(c(9.1916, 45.4650), c(-1.543794, 53.698968)))
})
