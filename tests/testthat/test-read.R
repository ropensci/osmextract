test_that("oe_read: simplest examples work", {
  f = system.file("its-example.osm.pbf", package = "osmextract")
  osm_data = oe_read(f)
  # result is sf object:
  expect_s3_class(object = osm_data, class = "sf")
  # linestring geometry is default:
  expect_equal(as.character(unique(sf::st_geometry_type(osm_data))), "LINESTRING")
  osm_data_points = oe_read(f, layer = "points")
  expect_equal(as.character(unique(sf::st_geometry_type(osm_data_points))), "POINT")
})
