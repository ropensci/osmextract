context("test-get_geofabric")

test_that("get_geofabric works", {
  andorra_point = get_geofabric(name = "andorra",
                                layer = "points",
                                attributes = "shop")
  expect_true(nrow(andorra_point) > 1000)
  expect_true(length(andorra_point) == 12)
})
