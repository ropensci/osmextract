test_that("simplest examples in oe_match works", {
  expect_match(oe_match("Italy")$url, "italy")
  expect_match(oe_match("Leeds", provider = "bbbike")$url, "Leeds")
  expect_match(oe_match("RU", match_by = "iso3166_1_alpha2")$url, "russia")

  expect_error(oe_match("Isle Wight"))
  expect_match(oe_match("Isle Wight", max_string_dist = 3)$url, "isle-of-wight")
})

test_that("Places with length gt 1 fails: ", {
  expect_error(oe_match(c("Italy", "Spain")))
})

test_that("oe_match with different providers and match_by args", {
  expect_error(oe_match("Italy", provider = "XXX"))
  expect_error(oe_match("Italy", match_by = "XXX"))
})

test_that("oe_match and quiet", {
  expect_message(oe_match("London", max_string_dist = 3, quiet = FALSE))
})

test_that("oe_match with new classes", {
  expect_error(oe_match(c(1 + 2i, 1 - 2i)))
})

test_that("oe_match and sfc", {
  milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
  expect_match(oe_match(milan_duomo)$url, "italy")
})

test_that("oe_match and numeric input", {
  expect_match(oe_match(c(9.1916, 45.4650))$url, "italy")
})

test_that("oe_match with multiple spatial matches", {
  # See https://github.com/ITSLeeds/osmextract/issues/98
  # The following test is used to check that in case a single point intersects multiple areas, then oe_match will select the area whose centroid is closest to the input point.
  problem <- c(4.91069, 52.27786)
  expect_match(oe_match(problem, provider = "bbbike")$url, "Amsterdam")
})
