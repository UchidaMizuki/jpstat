estat_activate_impl <- function(x, id, name_to) {
  stopifnot(id %in% x$id)

  if (!is.null(name_to)) {
    vctrs::vec_slice(x$name_to, x$id == id) <- name_to
  }
  attr(x, "active_id") <- id
  x
}

#' Determine which \code{estat} object key to edit.
#'
#' @param x A \code{estat} object.
#' @param pattern Pattern to look for.
#' @param name_to New column name.
#'
#' @return The \code{estat} object which the selected key is active.
#'
#' @examples
#' estat_activate_tab(estat_census_2020)
#' estat_activate_cat(estat_census_2020, 1)
#' estat_activate_area(estat_census_2020)
#' estat_activate_time(estat_census_2020)
#' @export
estat_activate <- function(x, pattern,
                           name_to = NULL) {
  id <- vctrs::vec_slice(x$id, stringr::str_detect(x$name, pattern))
  stopifnot(rlang::is_scalar_character(id))

  estat_activate_impl(x, id, name_to)
}

#' @rdname estat_activate
#' @export
estat_activate_tab <- function(x,
                               name_to = NULL) {
  estat_activate_impl(x, "tab", name_to)
}

#' @rdname estat_activate
#' @export
estat_activate_time <- function(x,
                                name_to = NULL) {
  estat_activate_impl(x, "time", name_to)
}

#' @rdname estat_activate
#' @export
estat_activate_area <- function(x,
                                name_to = NULL) {
  estat_activate_impl(x, "area", name_to)
}

#' @rdname estat_activate
#'
#' @param n A category number.
#'
#' @export
estat_activate_cat <- function(x, n,
                               name_to = NULL) {
  n <- stringr::str_pad(n, 2,
                        pad = "0")
  cat_n <- stringr::str_c("cat", n)

  estat_activate_impl(x, cat_n, name_to)
}
