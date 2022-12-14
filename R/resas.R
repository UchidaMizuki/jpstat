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
  out <- get_content(setup$url,
                     config = httr::add_headers(`X-API-KEY` = setup$X_API_KEY),
                     path = setup$path,
                     query = setup$query)

  if (identical(out, "400")) {
    abort("400 Bad Request")
  }

  out$result
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
    resas_rectangle()
}

resas_rectangle <- function(x) {
  if (is_named(x)) {
    x <- x |>
      purrr::modify(function(x) {
        if (vec_is_list(x)) {
          x <- resas_rectangle(x)
        }
        x
      })

    if (vec_is_list(x[[1L]])) {
      x <- x |>
        purrr::imap(function(x, nm) {
          x |>
            set_names(stringr::str_c(nm, names2(x),
                                     sep = "/"))
        })
      vec_c(!!!unname(x))
    } else {
      sizes <- list_sizes(x)
      n <- vec_size(x)
      loc_1 <- vec_as_location(sizes == 1L, n)
      loc_n <- vec_as_location(sizes > 1L, n)

      if (vec_size(loc_n) <= 1L) {
        vec_cbind(!!!x) |>
          resas_unpack()
      } else {
        loc_n |>
          purrr::map(function(loc_n) {
            vec_cbind(!!!x[c(loc_1, loc_n)]) |>
              resas_unpack()
          })
      }
    }
  } else {
    x <- purrr::modify(x, resas_rectangle)
    x_1 <- x[[1L]]

    if (vec_is_list(x_1)) {
      nms <- names(x_1)
      nms |>
        set_names() |>
        purrr::map(function(nm) {
          x <- x |>
            purrr::modify(function(x) {
              x[[nm]]
            })
          vec_rbind(!!!x)
        })
    } else {
      vec_rbind(!!!x)
    }
  }
}

resas_unpack <- function(x) {
  cols <- vec_as_location(purrr::map_lgl(x, is.data.frame), ncol(x))
  x |>
    tidyr::unpack(cols,
                  names_sep = "/")
}
