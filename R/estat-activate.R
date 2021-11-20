estat_activate <- function(x, id, new_name) {
  stopifnot(id %in% x$id)

  if (!is.null(new_name)) {
    x$new_name[x$id == id] <- new_name
  }
  attr(x, "active_id") <- id
  x
}

#' @rdname estat_activate
#'
#' @export
estat_activate_tab <- function(x,
                               new_name = NULL) {
  estat_activate(x, "tab", new_name)
}

#' @rdname estat_activate
#'
#' @export
estat_activate_time <- function(x,
                                new_name = NULL) {
  estat_activate(x, "time", new_name)
}

#' @rdname estat_activate
#'
#' @export
estat_activate_area <- function(x,
                                new_name = NULL) {
  estat_activate(x, "area", new_name)
}

#' @rdname estat_activate
#'
#' @export
estat_activate_cat <- function(x, n,
                               new_name = NULL) {
  n <- stringr::str_pad(n, 2,
                        pad = "0")
  cat_n <- stringr::str_c("cat", n)

  estat_activate(x, cat_n, new_name)
}
