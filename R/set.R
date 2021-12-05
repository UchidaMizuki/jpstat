#' Set attributes
#'
#' @param i An attribute name.
#' @param value An attribute value
#'
#' @return No output.
#'
#' @examples
#' japanstat_set("estat_limit_collection", 1e5)
#' japanstat_set("estat_limit_items", 1e2)
#' @export
japanstat_set <- function(i, value) {
  japanstat_global[[i]] <- value
  invisible()
}

#' Set 'appId' of 'e-Stat' API
#'
#' @param appId An 'appId' of 'e-Stat' API.
#'
#' @return No output.
#'
#' @examples
#' estat_set_apikey("Your e-Stat appId")
#' @export
estat_set_apikey <- function(appId) {
  japanstat_global$estat_apikey <- appId
  invisible()
}
