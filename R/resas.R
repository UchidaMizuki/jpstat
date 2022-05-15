resas_path <- function(x) {
  x %>%
    stringr::str_extract("(?<=/)api/.+(?=\\.html$)")
}

resas_docs <- function(setup) {
  sections <- stringr::str_glue("{setup$url}docs/{setup$path}.html") %>%
    rvest::read_html() %>%
    rvest::html_elements("body > div > article > section")

  for (section in sections) {
    h1 <- section %>%
      rvest::html_elements("h1") %>%
      rvest::html_text()

    if (!vctrs::vec_is_empty(h1) && h1 == "parameters") {
      parameters <- section %>%
        rvest::html_table() %>%
        dplyr::mutate(Description = .data$Description %>%
                        stringr::str_extract("^[^\\n]+(?=$|\\n)") %>%
                        stringr::str_remove("\\s+$"),
                      Required = .data$Required == "true") %>%
        dplyr::rename_with(stringr::str_to_lower)
    }
    if (!vctrs::vec_is_empty(h1) && h1 == "responses") {
      responses <- section %>%
        rvest::html_table() %>%
        dplyr::mutate(Description = .data$Description %>%
                        stringr::str_extract("^[^\\n]+(?=$|\\n)") %>%
                        stringr::str_remove("\\s+$")) %>%
        dplyr::rename_with(stringr::str_to_lower)
    }
  }

  list(parameters = parameters,
       responses = responses)
}

resas_query_value <- function(x) {
  out <- x %>%
    purrr::discard(is.na) %>%
    stringr::str_c(collapse = ",")

  if (out == "") {
    NULL
  } else {
    out
  }
}

resas_query <- function(x, query) {
  parameters <- x %>%
    activate("param")
  query_parameters <- parameters$value %>%
    purrr::map(resas_query_value) %>%
    set_names(parameters$attrs$name)

  compact_query(!!!attr(x, "setup")$query,
                !!!query_parameters,
                !!!query)
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

  locs <- which(purrr::map_lgl(result, is.list))

  size <- vec_size(locs)
  out <- vec_init(list(), size)
  for (i in seq_len(size)) {
    out[[i]] <- resas_unnest_recursive(c(result[-locs], result[locs[[i]]]))
  }

  names(out) <- names(result)[locs]
  out
}

resas_unnest_recursive <- function(x) {
  if (is_named(x)) {
    locs <- which(purrr::map_lgl(x, is.list))

    for (loc in locs) {
      x[[loc]] <- resas_unnest_recursive(x[[loc]])
    }

    x %>%
      tibble::as_tibble() %>%
      tidyr::unnest_wider(locs,
                          names_sep = "/")
  } else {
    x %>%
      dplyr::bind_rows() %>%
      resas_unnest_recursive()
  }
}

#' Get parameters of 'RESAS' data
#'
#' @param X_API_KEY An 'X-API-KEY' of 'RESAS' API.
#' @param path A 'RESAS' API path.
#' @param query A list of queries.
#' @param .rename_params Rename parameters to snake cases?
#' @param .rename_resps Rename responses to snake cases?
#' @param .names_sep_resps What to replace the "/" in the responses with?
#'
#' @return A `resas` object.
#'
#' @seealso <https://opendata.resas-portal.go.jp/>
#'
#' @export
resas <- function(X_API_KEY, path,
                  query = list(),
                  .rename_params = TRUE,
                  .rename_resps = TRUE,
                  .names_sep_resps = "_") {
  path <- resas_path(path)

  setup <- list(url = "https://opendata.resas-portal.go.jp/",
                X_API_KEY = X_API_KEY,
                path = path,
                query = query)
  docs <- resas_docs(setup)

  # parameters
  parameters <- docs$parameters
  parameters$width_description <- pillar::get_max_extent(parameters$description)
  parameters_keys <- parameters$name
  if (.rename_params) {
    parameters_keys <- str_to_snakecase(parameters_keys)
  }
  parameters <- navigatr::new_menu(key = parameters_keys,
                                   value = list(structure(NA_character_,
                                                          class = "resas_parameters_item")),
                                   attrs = parameters,
                                   class = "resas_parameters")

  # responses
  responses <- docs$responses
  responses_attrs <- responses %>%
    dplyr::mutate(name = .data$name %>%
                    stringr::str_remove("^/result/"))
  responses_keys <- responses_attrs$name
  if (.rename_resps) {
    responses_keys <- str_to_snakecase(responses_keys)
  }
  responses_keys <- responses_keys %>%
    stringr::str_replace_all("/", .names_sep_resps %||% "/")
  responses <- navigatr::new_menu(key = responses_keys,
                                  value = list(structure(list(),
                                                         class = "resas_responses_item")),
                                  attrs = responses_attrs,
                                  class = "resas_responses")

  navigatr::new_menu(key = c("param", "resp"),
                     value = list(parameters, responses),
                     setup = setup,
                     class = "resas")
}

#' @export
collect.resas <- function(x,
                          query = list(),
                          simplify = TRUE, ...) {
  setup <- attr(x, "setup")
  setup$query <- resas_query(x, query)

  out <- setup %>%
    resas_get() %>%
    resas_unnest()

  responses <- x %>%
    activate("resp")
  nms_old <- responses$attrs$name
  nms_new <- responses$key
  out <- out %>%
    purrr::modify(function(x) {
      loc <- nms_old %in% names(x)

      nms_old_in_x <- nms_old[loc]
      nms_new_in_x <- nms_new[loc]

      x <- x[nms_old_in_x]
      names(x) <- nms_new_in_x
      x
    })

  if (simplify && is_scalar_list(out)) {
    out <- out[[1L]]
  }
  out
}

#' @export
collect.resas_parameters <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}

#' @export
collect.resas_parameters_item <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}

#' @export
collect.resas_responses <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}

#' @export
collect.resas_responses <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}



# printing ----------------------------------------------------------------

#' @export
vec_ptype_abbr.resas_parameters <- function(x) {
  "parameters"
}

#' @importFrom pillar obj_sum
#' @export
obj_sum.resas_parameters_item <- function(x) {
  description <- attr(x, "description")
  width_description <- attr(x, "width_description")

  if (is.null(description)) {
    "resas_parameters_item"
  } else {
    out <- paste(pillar::align(description, width_description),
                 cli::symbol$arrow_right)
    query_value <- resas_query_value(x)

    if (is.null(query_value)) {
      out <- paste(out, "NULL")
    } else {
      out <- paste(out, encodeString(query_value, quote = "\""))
    }
    out
  }
}

#' @export
print.resas_parameters_item <- function(x, ...) {
  out <- x
  attributes(out) <- NULL
  print(out)

  invisible(x)
}

#' @export
vec_ptype_abbr.resas_responses <- function(x) {
  "responses"
}

#' @importFrom pillar obj_sum
#' @export
obj_sum.resas_responses_item <- function(x) {
  attr(x, "description") %||% "resas_responses_item"
}

#' @export
print.resas_responses_item <- function(x, ...) {
  print(NULL)
  invisible(x)
}
