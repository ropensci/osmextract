# packages ----------------------------------------------------------------
library(rvest)
library(sf)
library(purrr)
library(httr)
library(sf)
library(s2)
devtools::load_all(".")
library(conflicted)

# Starting point is: http://download.openstreetmap.fr/
# A list of extract sources is here: https://wiki.openstreetmap.org/wiki/Planet.osm#Country_and_area_extracts

# Define a function that will be used for all poly folders
my_organize_osm_data = function(poly_folder, level, parent = NA, verbose = TRUE) {
  # Help for debugging
  if (verbose) {
    message("URL: ", poly_folder, "\n", "Level: ", level)
  }

  # Download and restructure poly folder
  my_data = read_html(poly_folder) %>%
    html_node("table") %>%
    html_table() %>%
    janitor::clean_names()

  # Extract poly files
  poly_files = grep("\\.poly", my_data[["name"]], value = TRUE)

  # Build URLs
  poly_urls = paste0(poly_folder, poly_files)
  # Download .poly files and convert them to MULTIPOLYGON format
  multipoly = lapply(
    X = poly_urls,
    FUN = read_poly
  )
  multipoly_sfc = do.call("c", multipoly)

  # Extract names (everything that is before '.poly')
  names = regmatches(poly_files, regexpr("\\S+(?=\\.poly)", poly_files, perl = TRUE))

  # Build openstreetmap_fr_zones
  zones = st_sf(
    data.frame(
      id = names,
      name = stringr::str_to_title(gsub("[-_]", " ", names)),
      parent = parent,
      level = level,
      pbf = gsub("\\.poly", "-latest.osm.pbf", gsub("polygons", "extracts", poly_urls)),
      stringsAsFactors = FALSE
    ),
    geometry = multipoly_sfc,
    stringsAsFactors = FALSE
  )

  # Add file size
  zones$pbf_file_size = map_dbl(
    .x = zones$pbf,
    .f = function(x) {
      my_HEAD = HEAD(x)

      if (httr::status_code(my_HEAD) == 200) {
        return(as.numeric(headers(my_HEAD)$`content-length`))
      }
      NA_real_
    }
  )

  # Check if there is any sub-zone and repeat the same stuff (i.e. this function
  # has a recursive structure)
  sub_folders = grep("/", my_data[["name"]], value = TRUE)

  # There is a weird folder named "merge" which contains weird values. I will exclude it.
  sub_folders <- setdiff(sub_folders, "merge/")

  if (length(sub_folders) > 0L) {
    for (i in sub_folders) {
      zones = rbind(
        zones,
        my_organize_osm_data(
          poly_folder = paste0(poly_folder, i),
          level = level + 1L,
          parent = gsub("/", "", i)
        )
      )
    }
  }

  zones
}

openstreetmap_fr_zones = my_organize_osm_data("http://download.openstreetmap.fr/polygons/", level = 1L)

# Exclude NA in pbf
openstreetmap_fr_zones = openstreetmap_fr_zones[!is.na(openstreetmap_fr_zones$pbf_file_size), ]

# Rebuild the geometries
st_geometry(openstreetmap_fr_zones) <- st_as_sfc(
  s2_rebuild(s2_geog_from_wkb(st_as_binary(st_geometry(openstreetmap_fr_zones)), check = FALSE))
)

# Unfortunately, there are 2 problematic areas that wrap the dateline. For
# simplicity, I will remove them.
openstreetmap_fr_zones <- openstreetmap_fr_zones[st_is_valid(openstreetmap_fr_zones), ]

# The end
usethis::use_data(openstreetmap_fr_zones, overwrite = TRUE, version = 3, compress = "xz")
