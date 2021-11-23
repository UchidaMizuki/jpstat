#' @importFrom dplyr filter
#' @export
dplyr::filter

#' @export
filter.estat <- function(.data, ..., .preserve = FALSE) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  items <- vctrs::vec_slice(.data$items, .data$id == active_id)[[1L]]
  items <- filter(items, ...,
                         .preserve = .preserve)
  vctrs::vec_slice(.data$items, .data$id == active_id) <- list(items)
  .data
}

#' @importFrom dplyr select
#' @export
dplyr::select

#' @export
select.estat <- function(.data, ...) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  items <- vctrs::vec_slice(.data$items, .data$id == active_id)[[1L]]
  items <- dplyr::select(items, ...)
  vctrs::vec_slice(.data$vars, .data$id == active_id) <- list(names(items))
  .data
}

#' @importFrom dplyr slice
#' @export
dplyr::slice

#' @export
slice.estat <- function(.data, ..., .preserve = FALSE) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  items <- vctrs::vec_slice(.data$items, .data$id == active_id)[[1L]]
  items <- dplyr::slice(items, ...,
                        .preserve = .preserve)
  vctrs::vec_slice(.data$items, .data$id == active_id) <- list(items)
  .data
}
