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
collect.resas <- function(x,
                          to_snakecase = TRUE,
                          names_sep = "/", ...) {
  setup <- attr(x, "setup")
  setup$query <- resas_query(x)

  collect_resas(setup,
                args = list(to_snakecase = to_snakecase,
                            names_sep = names_sep))
}

collect_resas <- function(setup, args) {
  setup |>
    resas_get() |>
    resas_rectangle(args = args)
}

resas_rectangle <- function(x, args) {
  if (is.data.frame(x)) {
    x
  } else if (is_named(x)) {
    x <- x |>
      purrr::modify(function(x) {
        resas_rectangle(x,
                        args = args)
      }) |>
      resas_flatten(args = args)

    sizes <- list_sizes(x)
    n <- vec_size(x)
    loc_1 <- vec_as_location(sizes == 1L, n)
    loc_n <- vec_as_location(sizes > 1L, n)

    if (vec_size(loc_n) <= 1L) {
      resas_cbind(x,
                  args = args)
    } else {
      loc_n |>
        purrr::map(function(loc_n) {
          resas_rectangle(x[c(loc_1, loc_n)],
                          args = args)
        })
    }
  } else if (vec_is_list(x)) {
    x <- purrr::modify(x,
                       function(x) {
                         resas_rectangle(x,
                                         args = args)
                       })
    x_1 <- x[[1L]]
    if (vec_is_list(x_1)) {
      nms <- names(x_1)
      to_snakecase <- resas_to_snakecase(args)
      nms |>
        set_names(to_snakecase(nms)) |>
        purrr::map(function(nm) {
          x <- x |>
            purrr::modify(function(x) {
              x[[nm]]
            })
          resas_rectangle(x,
                          args = args)
        })
    } else {
      vec_rbind(!!!x)
    }
  } else {
    x
  }
}

resas_flatten <- function(x, args) {
  to_snakecase <- resas_to_snakecase(args)
  x <- x |>
    purrr::imap(function(x, nm) {
      if (vec_is_list(x)) {
        x |>
          set_names(stringr::str_c(to_snakecase(nm), names2(x),
                                   sep = args$names_sep))
      } else {
        list(x) |>
          set_names(nm)
      }
    })
  vec_c(!!!unname(x))
}

resas_unpack <- function(x, args) {
  cols <- vec_as_location(purrr::map_lgl(x, is.data.frame), ncol(x))
  x |>
    tidyr::unpack(cols,
                  names_sep = args$names_sep)
}

resas_cbind <- function(x, args) {
  to_snakecase <- resas_to_snakecase(args)
  vec_cbind(!!!x) |>
    resas_unpack(args = args) |>
    dplyr::rename_with(to_snakecase)
}

resas_to_snakecase <- function(args) {
  if (args$to_snakecase) {
    str_to_snakecase
  } else {
    identity
  }
}
