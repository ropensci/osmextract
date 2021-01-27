## code to prepare `test_zones` dataset goes here

## We want to create a super small dataset to be used for testing and examples.
## It uses the same structure as geofabrik_zones.

# The Isle of Wight example is created as follows:
library(osmextract)
oe_get(
  place = "Isle of Wight",
  download_directory = ".",
  skip_vectortranslate = TRUE,
  download_only = TRUE
)
piggyback::pb_upload("geofabrik_isle-of-wight-latest.osm.pbf")
iow_url = piggyback::pb_download_url("geofabrik_isle-of-wight-latest.osm.pbf")
test_zones = geofabrik_zones[geofabrik_zones$name == "Isle of Wight", c(1, 2, 3, 4, 7, 8)]
test_zones$pbf = iow_url # so we do not download from geofabrik
file.remove("geofabrik_isle-of-wight-latest.osm.pbf")

# Now we want an even smaller example
# @Andrea: I don't understand the following code. Ask @Robin.
# Get minimal .pbf file
# u = "https://osmaxx.hsr.ch/media/osmaxx/outputfiles/512a0f9b-7665-4078-80b1-77c4e4af3123/its-min_wgs-84_2020-07-12_pbf_full-detail.zip"
# download.file(u, destfile = "/tmp/its-min.zip")
# unzip("/tmp/its-min.zip", exdir = "/tmp")
# f = list.files("/tmp/pbf/", pattern = "pbf", full.names = TRUE)
# file.copy(f, "its-min.pbf")
# system("ls -hal *.pbf") # less than 100 km
# res = sf::read_sf("its-min.pbf", layer = "lines")
# mapview::mapview(res) # strange thing: contains lots of linestrings worldwide...
# res = sf::read_sf("its-osmaxx-2020-07.pbf", layer = "lines")
# mapview::mapview(res) # strange thing: contains lots of linestrings worldwide...
# From josm...
# res = sf::read_sf("its-example.osm")
# mapview::mapview(res)
# msg = "osmconvert its-example.osm -o=its-example.osm.pbf"
# system(msg)
# res = sf::read_sf("its-example.osm.pbf")
# res = sf::read_sf("its-example.osm.pbf", layer = "lines")
# mapview::mapview(res)
# system("ls -hal *.pbf") # 40 kb
# file.copy("its-example.osm.pbf", "inst/")

its_url = "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
test_zones[2, "id"] = "its"
test_zones[2, "name"] = "ITS Leeds"
test_zones[2, "parent"] = NA
test_zones[2, "level"] = NA
test_zones[2, "pbf_file_size"] = as.numeric(httr::headers(httr::HEAD(its_url))$`content-length`)
test_zones[2, "pbf"] = its_url
sf::st_geometry(test_zones)[2] = sf::st_as_sfc(sf::st_bbox(sf::st_read(its_url, "lines", quiet = TRUE)))

usethis::use_data(test_zones, overwrite = TRUE, version = 3)

