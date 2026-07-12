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

#' Access 'RESAS' data (defunct)
#'
#' `r lifecycle::badge("defunct")`
#'
#' The 'RESAS' API (<https://opendata.resas-portal.go.jp/>) was discontinued on
#' 2025-03-24, and accounts as well as API keys were deleted. Therefore
#' `resas()` no longer works and has been made defunct.
#'
#' As an alternative for prefectural and municipal data, consider the
#' MLIT Data Platform (DPF) GraphQL API (<https://www.mlit-data.jp/>).
#'
#' @param ... Ignored.
#'
#' @return This function always errors.
#'
#' @keywords internal
#' @export
resas <- function(...) {
  lifecycle::deprecate_stop(
    when = "0.5.0",
    what = "resas()",
    details = c(
      x = "The 'RESAS' API was discontinued on 2025-03-24 and is no longer available.",
      i = "Consider the MLIT Data Platform (DPF) GraphQL API instead: <https://www.mlit-data.jp/>."
    )
  )
}
