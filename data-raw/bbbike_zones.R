# packages
library(sf)
library(jsonlite)
library(purrr)
library(httr)
# install.packages("htmltab")
library(htmltab)
bbbike_zones = htmltab("https://download.bbbike.org/osm/bbbike/")[-1, ]
names(bbbike_zones)

bbbike_zones = janitor::clean_names(bbbike_zones)
bbbike_zones$name = stringr::str_remove(bbbike_zones$name, pattern = "/")

# Check the result
str(bbbike_zones, max.level = 1, nchar.max = 64, give.attr = FALSE)

# get bounds:
browseURL("https://download.bbbike.org/osm/bbbike/Aachen")
browseURL("https://download.bbbike.org/osm/bbbike/Aachen/Aachen.poly")
system("wget https://download.bbbike.org/osm/bbbike/Aachen/Aachen.poly")
# aachen_poly = read_sf("Aachen.poly") # failes
# system("npm install polytogeojson")
# # in bash
# var polytogeojson = require('polytogeojson');
download.file("https://github.com/ustroetz/polygon2osm/raw/master/polygon2geojson.py", "polygon2geojson.py")
system("python3 polygon2geojson.py Aachen.poly")
aachen_poly = read_sf("Aachen.geojson")
mapview::mapview(aachen_poly) # it is indeed Aachen!

# functionalise it
u = "https://download.bbbike.org/osm/bbbike/Aachen/Aachen.poly"
d = "bbbike_polys"
dir.create(d)
poly_to_sf = function(u, d) {
  bn = basename(u)
  fp = file.path(d, bn)
  fg = file.path(d, gsub(pattern = ".poly", replacement = ".geojson", x = bn))
  download.file(url = u, destfile = fp)
  msg = paste("python3 polygon2geojson.py", fp)
  system(msg)
  sf::read_sf(fg)
}

head(bbbike_zones)
bbbike_zones$base_url = paste0("https://download.bbbike.org/osm/bbbike/", bbbike_zones$name)
bbbike_zones$poly_url = paste0(bbbike_zones$base_url, "/", bbbike_zones$name, ".poly")
bbbike_zones$poly_url[1] == u # bingo!
bbbike_zones$pbf = paste0(bbbike_zones$base_url, "/", bbbike_zones$name, ".osm.pbf")

bbbike_zones$pbf[1] == "https://download.bbbike.org/osm/bbbike/Aachen/Aachen.osm.pbf"

aachen_poly2 = poly_to_sf(u = bbbike_zones$poly_url[1], d = d)
identical(aachen_poly, aachen_poly2) # True that
bbbike_zone_polygon_list = lapply(bbbike_zones$poly_url, poly_to_sf, d = d)
# bbbike_zone_polygons = do.call(what = c, args = bbbike_zone_polygon_list) # failed
bbbike_zone_polygons = do.call(what = rbind, args = bbbike_zone_polygon_list) # worked!
class(bbbike_zone_polygons)
saveRDS(bbbike_zone_polygons, "bbbike_zone_polygons.Rds")

bbbike_zones_final = sf::st_sf(bbbike_zones, geometry = bbbike_zone_polygons$geometry)
plot(bbbike_zones_final) # cities worldwide

bbbike_zones = bbbike_zones_final
# Add the pbf file size
bbbike_zones$pbf_file_size = map_dbl(
  .x = bbbike_zones$pbf,
  .f = function(x) as.numeric(headers(HEAD(x))$`content-length`)
)
usethis::use_data(bbbike_zones, version = 3, overwrite = TRUE)

# tidy up
zip(zipfile = "bbbike_polys.zip", files = "bbbike_polys")
piggyback::pb_upload("bbbike_polys.zip")
piggyback::pb_upload("polygon2geojson.py")
piggyback::pb_upload("Aachen.geojson")
piggyback::pb_upload("Aachen.poly")
