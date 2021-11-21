activate_key <- function(x, id, new_name) {
  stopifnot(id %in% x$id)

  if (!is.null(new_name)) {
    vctrs::vec_slice(x$new_name, x$id == id) <- new_name
  }
  attr(x, "active_id") <- id
  x
}

#' @rdname activate_key
#'
#' @export
activate_tab <- function(x,
                         new_name = NULL) {
  activate_key(x, "tab", new_name)
}

#' @rdname activate_key
#'
#' @export
activate_time <- function(x,
                          new_name = NULL) {
  activate_key(x, "time", new_name)
}

#' @rdname activate_key
#'
#' @export
activate_area <- function(x,
                          new_name = NULL) {
  activate_key(x, "area", new_name)
}

#' @rdname activate_key
#'
#' @export
activate_cat <- function(x, n,
                         new_name = NULL) {
  n <- stringr::str_pad(n, 2,
                        pad = "0")
  cat_n <- stringr::str_c("cat", n)

  activate_key(x, cat_n, new_name)
}

#' @rdname activate_key
#'
#' @export
inactivate <- function(x) {
  attr(x, "active_id") <- NULL
  x
}
