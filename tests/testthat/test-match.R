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

