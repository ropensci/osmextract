# Auxiliary functions (not exported)
'%!in%' <- function(x, y) !('%in%'(x,y))

osmext_available_providers <- function() {
  c(
    "geofabrik",
    "test"
    )
}
