#' Get 'e-Stat' data
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param x A \code{estat} object.
#' @param value_name A column name of the value.
#' @param query A list of additional queries.
#'
#' @return A \code{tbl} of the downloaded data.
#'
#' @examples
#' \dontrun{
#' estat_download(estat_census_2020)
#' }
#'
#' @importFrom rlang %||%
#' @export
estat_download <- function(x,
                           value_name = "value",
                           query = NULL) {
  lifecycle::deprecate_warn("0.2.0", "estat_download()", "estat_collect()")

  estat_collect(x = x,
                value_name = value_name,
                query = query)
}
