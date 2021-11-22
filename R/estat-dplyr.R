#'
#'
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

#'
#'
#' @export
select.estat <- function(.data, ...) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  items <- vctrs::vec_slice(.data$items, .data$id == active_id)[[1L]]
  items <- select(items, ...)
  vctrs::vec_slice(.data$vars, .data$id == active_id) <- list(names(items))
  .data
}

#'
#'
#' @export
slice.estat <- function(.data, ..., .preserve = FALSE) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  items <- vctrs::vec_slice(.data$items, .data$id == active_id)[[1L]]
  items <- slice(items, ...,
                 .preserve = .preserve)
  vctrs::vec_slice(.data$items, .data$id == active_id) <- list(items)
  .data
}
