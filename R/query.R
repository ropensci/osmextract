#' Convert a list to a character strings representing a query
#'
#' @param query_list
#'
#' @return
#' @export
#'
#' @examples
#' oe_query(query_list = list(overwrite = TRUE))
#' oe_query(query_list = list(overwrite = TRUE, where = "some query"))
oe_query = function(query_list = NULL) {

  browser()
  list_classes = sapply(query_list, class)

  logical_queries = query_list[list_classes == "logical"]
  logicals = lapply(query_list, oe_query_logical)

  character_queries = query_list[list_classes == "character"]
  characters = lapply(query_list, oe_query_character)

  unlist(logicals, characters)

}
oe_query_logical = function(x) {
  paste0("--", names(x))
}
oe_query_character = function(x) {
  argument = paste0("-", names(x))
  value = x
  paste(argument, value)
}
