#' @export
estat_set_url <- function(url) {
  japanstat_global$estat_url <- url
  invisible()
}

#' @export
estat_set_path <- function(path) {
  japanstat_global$estat_path <- path
  invisible()
}

#' @export
estat_set_limit_downloads <- function(limit_downloads) {
  japanstat_global$estat_limit_downloads <- limit_downloads
  invisible()
}

#' @export
estat_set_limit_items <- function(limit_items) {
  japanstat_global$estat_limit_items <- limit_items
  invisible()
}

#' Set language of e-Stat API
#'
#' @param lang A language of e-Stat API, Japanese (\code{"J"}) or English (\code{"E"}).
#'
#' @return No output.
#'
#' @export
estat_set_lang <- function(lang) {
  lang <- rlang::arg_match(lang, c("J", "E"))
  japanstat_global$lang <- lang
  invisible()
}

#' Set appId of e-Stat API
#'
#' @param appId An appId of e-Stat API.
#'
#' @return No output.
#'
#' @export
estat_set_apikey <- function(appId) {
  japanstat_global$estat_apikey <- appId
  invisible()
}
