#' Get table information for 'e-Stat' data
#'
#' @param x A `estat` object.
#'
#' @return A `tbl_df` of the table information.
#'
#' @export
estat_table_info <- function(x) {
  lifecycle::deprecate_warn("0.3.0", "estat_table_info()", "summary()")

  stopifnot(
    any(c("estat", "tbl_estat") %in% class(x))
  )
  summary(x)
}
