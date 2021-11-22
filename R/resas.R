#'
#'
#' @export
resas_set_apikey <- function(X_API_KEY) {
  japanstat_global$resas_apikey <- X_API_KEY
  invisible()
}

resas_get <- function(path, query) {
  out <- httr::GET(japanstat_global$resas_url,
                   config = httr::add_headers(`X-API-KEY` = japanstat_global$resas_apikey),
                   path = stringr::str_c(japanstat_global$resas_path, path),
                   query = query)
  httr::stop_for_status(out)
  httr::content(out)
}

resas_get_parameter <- function(path) {
  path <- stringr::str_glue("{japanstat_global$resas_url}docs/{japanstat_global$resas_path}{path}.html")
  rvest::read_html(path)
}

#'
#'
#' @export
resas <- function() {

}
