#' Set attributes of 'e-Stat' API
#'
#' @param i An attribute name.
#' @param value An attribute value
#'
#' @return No output..
#'
#' @examples
#' estat_set("estat_limit_downloads", 1e5)
#' estat_set("estat_limit_items", 1e2)
#' @export
estat_set <- function(i, value) {
  japanstat_global[[i]] <- value
  invisible()
}

#' Set language of 'e-Stat' API
#'
#' @param lang A language of 'e-Stat' API, Japanese (\code{"J"}) or English (\code{"E"}).
#'
#' @return No output.
#'
#' @examples
#' estat_set_lang("J")
#' @export
estat_set_lang <- function(lang) {
  lang <- rlang::arg_match(lang, c("J", "E"))
  japanstat_global$lang <- lang
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
