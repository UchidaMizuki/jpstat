resas_path <- function(x) {
  x |>
    stringr::str_extract("(?<=(^|/))api/.+") |>
    stringr::str_remove("\\.html$")
}

resas_docs <- function(setup) {
  resas_v1_docs$docs |>
    dplyr::filter(.data$path == setup$path) |>
    dplyr::pull("doc") |>
    dplyr::first()
}

#' Access 'RESAS' data
#'
#' @param X_API_KEY An 'X-API-KEY' of 'RESAS' API.
#' @param path A 'RESAS' API path.
#'
#' @return A `resas` object.
#'
#' @seealso <https://opendata.resas-portal.go.jp/>
#'
#' @export
resas <- function(X_API_KEY, path) {
  path <- resas_path(path)

  setup <- list(url = "https://opendata.resas-portal.go.jp/",
                X_API_KEY = X_API_KEY,
                path = path)

  docs <- resas_docs(setup)
  parameters <- docs$parameters

  if (vec_is_empty(parameters)) {
    out <- collect_resas(setup)
  } else {
    width <- pillar::get_max_extent(parameters$description)
    value <- purrr::map2(parameters$description, parameters$required,
                         function(description, required) {
                           new_vctr(character(),
                                    description = description,
                                    width = width,
                                    required = required,
                                    class = "resas_value")
                         })

    out <- navigatr::new_nav_input(key = str_to_snakecase(parameters$name),
                                   value = value,
                                   setup = setup,
                                   docs = docs,
                                   class = "resas")
  }

  out
}

#' @export
obj_sum.resas_value <- function(x) {
  description <- attr(x, "description")
  width <- attr(x, "width")
  required <- attr(x, "required")

  if (required) {
    required <- " (Required)"
  } else {
    required <- ""
  }

  paste0(pillar::align(description, width), ": ", commas(vec_data(x)), required)
}

#' @export
summary.resas <- function(object, ...) {
  attr(object, "docs")
}

resas_query <- function(x) {
  key <- str_to_camelcase(x$key)
  value <- x$value |>
    purrr::map(~ {
      .x <- .x |>
        vec_data() |>
        commas0()

      if (.x == "") {
        return(character())
      } else {
        return(.x)
      }
    }) |>
    set_names(key)
  compact_query(!!!value)
}

resas_get <- function(setup) {
  get_content(setup$url,
              config = httr::add_headers(`X-API-KEY` = setup$X_API_KEY),
              path = setup$path,
              query = setup$query)
}

resas_unnest <- function(x) {
  if (identical(x, "400")) {
    abort("400 Bad Request")
  }

  result <- x$result

  if (is.null(result)) {
    abort(x$message)
  }

  if (is_named(result)) {
    locs <- which(purrr::map_lgl(result, is.list))

    size <- vec_size(locs)
    out <- vec_init(list(), size)
    for (i in seq_len(size)) {
      out[[i]] <- resas_unnest_recursive(c(result[-locs], result[locs[[i]]])) |>
        dplyr::rename_with(str_to_snakecase)
    }

    names(out) <- names(result)[locs]
  } else {
    out <- resas_unnest_recursive(result)
  }

  out
}

resas_unnest_recursive <- function(x) {
  if (is_named(x)) {
    locs <- which(purrr::map_lgl(x, is.list))

    for (loc in locs) {
      x[[loc]] <- resas_unnest_recursive(x[[loc]])
    }

    x |>
      tibble::as_tibble() |>
      tidyr::unnest_wider(dplyr::all_of(locs),
                          names_sep = "/")
  } else {
    x |>
      dplyr::bind_rows() |>
      resas_unnest_recursive()
  }
}

#' @export
collect.resas <- function(x, ...) {
  setup <- attr(x, "setup")
  setup$query <- resas_query(x)

  collect_resas(setup)
}

collect_resas <- function(setup) {
  setup |>
    resas_get() |>
    resas_unnest()
}
