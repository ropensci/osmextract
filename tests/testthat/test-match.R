test_that("Regular character matching works", {
  expect_match(
    oe_match("Italy")$url,
    "italy"
  )
})
test_that("Regular spatial matching works", {
  milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
  expect_match(
    oe_match(milan_duomo)$url,
    "italy"
  )
  expect_match(
    oe_match(c(9.1916, 45.4650))$url,
    "italy"
  )
})
test_that("Matching with bbbike works", {
  expect_match(
    oe_match("Leeds", provider = "bbbike")$url,
    "Leeds"
  )
})


