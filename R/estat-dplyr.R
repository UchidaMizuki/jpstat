#'
#'
#' @export
filter.estat <- function(.data, ..., .preserve = FALSE) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  data <- .data$data[.data$id == active_id][[1L]]
  data <- filter(data, ...,
                 .preserve = .preserve)
  .data$data[.data$id == active_id] <- list(data)
  .data
}

#'
#'
#' @export
select.estat <- function(.data, ...) {
  active_id <- attr(.data, "active_id")
  stopifnot(!is.null(active_id))

  data <- .data$data[.data$id == active_id][[1L]]
  data <- select(data, ...)
  .data$col[.data$id == active_id] <- list(names(data))
  .data
}
