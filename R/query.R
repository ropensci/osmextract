#' Convert a list to character strings for gdal_utils options
#'
#' @param vtlist
#'
#' @return
#' @export
#'
#' @examples
#' oe_vtlist(vtlist = list(overwrite = TRUE))
#' oe_vtlist(vtlist = list(overwrite = TRUE, f = "GPKG"))
#' oe_vtlist(vtlist = list(f = "GPKG", t_srs = "EPSG:32633"))
#' its = oe_get("ITS Leeds", quiet = FALSE, download_directory = tempdir())
#' # mapview::mapview(its[1:5, ]) # find suitable subset
#' its_sample_union = sf::st_union(its[1:5, ])
#' its_polygon = sf::st_convex_hull(its_sample_union)
#' its_poly_txt = sf::st_as_text(its_polygon)
#' spatial_extent = "-1.559184 53.807739 -1.557375 53.808094"
#' q = oe_vtlist(list(spat = spatial_extent))
#' q
#' its2 = oe_get("ITS Leeds", quiet = FALSE, download_directory = tempdir(),
#'   vectortranslate_options = q)
#' plot(its$geometry, col = "grey")
#' plot(its_polygon, add = TRUE)
oe_vtlist = function(vtlist = NULL, layer = "lines") {

  # browser()
  list_names = names(vtlist)
  list_classes = sapply(vtlist, class)

  logical_queries = vtlist[list_classes == "logical"]
  logicals = sapply(names(logical_queries), oe_vtlist_l)

  character_queries = vtlist[list_classes == "character"]
  characters = mapply(oe_vtlist_c, names(character_queries), character_queries)

  unname(unlist(c(logicals, characters)))

}
oe_vtlist_l = function(q) {
  paste0("--", q)
}
oe_vtlist_c = function(v, q) {
  argument = paste0("-", v)
  c(argument, q)
}
