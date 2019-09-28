## code to prepare `geofabric_urls` dataset goes here

library(tidyverse)
library(rvest)

base_url = "http://download.geofabrik.de/"
xpath = ".subregion+ td a"
d = read_html(base_url)
t = d %>% html_table() %>% .[[1]]
t = t[c(1, 3)]
h = d %>% html_nodes(xpath) %>% html_attr("href") %>% paste0(base_url, .)
t = t[2:nrow(t),]
names(t)[1:2] = c("name", "size_pbf")
t$pbf_url = h
# download.file(h[2], "/tmp/test.osm.pbf")
t$page_url = gsub(pattern = "-latest.osm.pbf", replacement = ".html", x = t$pbf_url)
t$part_of = "World"
t$level = names(hierarchy)[level]
t$continent = NA
t$country = NA
t$region = NA
t$subregion = NA
# t[[names(hierarchy)[level - 1]]] = n
# t[[names(hierarchy)[level]]] = t$name
t$level = NA
t$geometry_url = gsub(pattern = ".html", replacement = ".kml", x = t$page_url)

geometry = map(t$geometry_url, ~ sf::st_read(.))
geometry_sf = do.call(rbind, geometry)
t = sf::st_sf(t, geometry = sf::st_geometry(geometry_sf))
t_continents = t

# t_continents$name = "World"

# # for countries
# # u = "http://download.geofabrik.de/europe.html"
# u = t_continents$page_url[6]
# xpath = ".subregion+ td a"
# d = read_html(u)
# n = d %>% html_node("h2") %>% html_text()
# t = d %>% html_table()
# t = bind_rows(t[2:3])
# h = d %>% html_nodes(xpath) %>% html_attr("href") %>% paste0(base_url, .)
# summary(t$`Sub Region` == "")
# t = t[!t$`Sub Region` == "",]
# names(t)[1:2] = c("name", "size_pbf")
# t$level = "country"
# t$pbf_url = h
# # download.file(h[2], "/tmp/test.osm.pbf")
# t$page_url = gsub(pattern = "-latest.osm.pbf", replacement = ".html", x = t$pbf_url)
# t$part_of = n
# t$continent = NA
# t$country = NA
# t$region = NA
# t$subregion = NA

names(t_europe)

# t_all = bind_rows(t_continents, t)


# generalise the solution -------------------------------------------------

# hierarchy:
hierarchy = c(
  continent = 1,
  country = 2,
  region = 3,
  subregion = 4
)

get_geofrabric_urls = function(u, xpath = ".subregion+ td a", level = "country", continent = NA, country = NA, region = NA) {
  if(!identical(httr::status_code(httr::GET(u)), 200L)) return(NULL)
  if(is.character(level)) {
    level = hierarchy[level]
  }
  b_url = gsub(pattern = "[a-z|-]+.html", replacement = "", u)
  d = read_html(u)
  n = d %>% html_node("h2") %>% html_text()
  t = d %>% html_table()
  n_tables = length(t)
  # t[[1]] # mess
  # t[[2]] # mess

  if(n_tables == 1) return(NULL) # no urls in there
  if(n_tables == 2) {
    t = t[[2]]
    t
  } else t = do.call(rbind, t[2:3])
  if(nrow(t) <= 1) {
    return(NULL)
  } # it's empty, return NULL (for next stage)


  h = d %>% html_nodes(xpath) %>% html_attr("href") %>% paste0(b_url, .)
  t = t[!t$`Sub Region` == "",] # filter excess info
  col_has_mb = sapply(t, function(x) all(grepl(pattern = "B", x = x)))
  t = t[c(1, which(col_has_mb))]
  names(t)[1:2] = c("name", "size_pbf")
  t$pbf_url = h
  # download.file(h[2], "/tmp/test.osm.pbf")
  t$page_url = gsub(pattern = "-latest.osm.pbf", replacement = ".html", x = t$pbf_url)
  t$part_of = n
  t$level = names(hierarchy)[level]

  t$pbf_url = h
  # download.file(h[2], "/tmp/test.osm.pbf")
  t$page_url = gsub(pattern = "-latest.osm.pbf", replacement = ".html", x = t$pbf_url)
  t$part_of = n
  t$continent = NA
  t$country = NA
  t$region = NA
  t$subregion = NA

  t[[names(hierarchy)[level - 1]]] = n
  t[[names(hierarchy)[level]]] = t$name
  t$level = level
  t$geometry_url = gsub(pattern = ".html", replacement = ".kml", x = t$page_url)

  geometry = map(t$geometry_url, ~ sf::st_read(.))
  geometry_sf = do.call(rbind, geometry)
  t = sf::st_sf(t, geometry = sf::st_geometry(geometry_sf))

  t
}

# t_continents = get_geofrabric_urls(u = base_url)
t_countries_europe = get_geofrabric_urls(u = "http://download.geofabrik.de/europe.html")
# View(t_europe)
# t_all = rbind(t_continents, t_countries_europe)

t_countries_africa = get_geofrabric_urls(u = t_continents$page_url[1])
# t_countries_antarctica = get_geofrabric_urls(u = t_continents$page_url[2]) # NULL
# t_countries_asia = get_geofrabric_urls(u = t_continents$page_url[3]) # testing - fixed problem
# t_countries_oceana = get_geofrabric_urls(u = t_continents$page_url[4])
# t_all = rbind(t_continents, t_countries_africa, t_countries_europe, t_countries_asia)

t_countries = t_countries_africa
for(i in 2:nrow(t_continents)) {
  t_countries = rbind(t_countries, get_geofrabric_urls(u = t_continents$page_url[i], level = "country"))
}
t_all = rbind(t_continents, t_countries)

download.file(t_all$pbf_url[99], "/tmp/test.pbf")

# try getting regions
get_geofrabric_urls(t_countries$page_url[1]) # fails
get_geofrabric_urls(t_countries$page_url[2]) # fails
t_germany = t_countries %>% filter(name == "Germany")
t_subregions = get_geofrabric_urls(t_germany$page_url, level = "region") # works
t_regions = get_geofrabric_urls(t_countries$page_url[1])
for(i in 2:nrow(t_countries)) {
  t_regions = rbind(t_regions, get_geofrabric_urls(u = t_countries$page_url[i], level = "region"))
}

t_all = bind_rows(t_continents, t_countries, t_regions)

# try getting subregions
t_eng = t_regions %>%
  filter(name == "England")
t_subregions_of_england = get_geofrabric_urls(u = t_eng$page_url, level = "subregion") # fails
t_eng$page_url

t_subregions = get_geofrabric_urls(t_regions$page_url[1])
for(i in 2:nrow(t_regions)) {
  t_subregions = rbind(t_subregions, get_geofrabric_urls(u = t_regions$page_url[i], level = "subregion"))
}

t_all = rbind(t_continents, t_countries, t_regions, t_subregions)
mapview::mapview(t_all)

geofabric_zones = t_all

usethis::use_data(geofabric_zones)
