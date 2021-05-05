#' Convert a list to a character strings representing a query
#'
#' @param query_list
#'
#' @return
#' @export
#'
#' @examples
#' oe_query(query_list = list(overwrite = TRUE))
#' oe_query(query_list = list(overwrite = TRUE, f = "GPKG"))
#' oe_query(query_list = list(f = "GPKG", t_srs = "EPSG:32633"))
#' its = oe_get("ITS Leeds", quiet = FALSE, download_directory = tempdir())
#' # mapview::mapview(its[1:5, ]) # find suitable subset
#' its_sample_union = sf::st_union(its[1:5, ])
#' its_polygon = sf::st_convex_hull(its_sample_union)
#' its_poly_txt = sf::st_as_text(its_polygon)
#' q = oe_query(list(clipdst = its_poly_txt))
#' its2 = oe_get("ITS Leeds", quiet = FALSE, download_directory = tempdir(),
#'   vectortranslate_options = q)
#' plot(its$geometry, col = "grey")
#' plot(its_polygon, add = TRUE)
oe_query = function(query_list = NULL) {

  # browser()
  list_names = names(query_list)
  list_classes = sapply(query_list, class)

  logical_queries = query_list[list_classes == "logical"]
  logicals = sapply(names(logical_queries), oe_query_l)

  character_queries = query_list[list_classes == "character"]
  characters = mapply(oe_query_c, names(character_queries), character_queries)

  x = c(logicals, characters)
  paste(x[!sapply(x,is.null)], collapse = " ")

}
oe_query_l = function(q) {
  paste0("--", q)
}
oe_query_c = function(v, q) {
  argument = paste0("-", v)
  paste(argument, q)
}
