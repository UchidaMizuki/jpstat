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
      param <- section %>%
        rvest::html_table() %>%
        dplyr::mutate(Description = .data$Description %>%
                        stringr::str_extract("^[^\\n]+(?=$|\\n)") %>%
                        stringr::str_remove("\\s+$"),
                      Required = .data$Required == "true") %>%
        dplyr::rename_with(stringr::str_to_lower)
    }
    if (!vctrs::vec_is_empty(h1) && h1 == "responses") {
      resp <- section %>%
        rvest::html_table() %>%
        dplyr::mutate(Description = .data$Description %>%
                        stringr::str_extract("^[^\\n]+(?=$|\\n)") %>%
                        stringr::str_remove("\\s+$")) %>%
        dplyr::rename_with(stringr::str_to_lower)
    }
  }

  list(param = param,
       resp = resp)
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
  param <- x %>%
    activate("param")
  query_param <- param$value %>%
    purrr::map(resas_query_value) %>%
    set_names(param$attrs$name)

  compact_query(!!!attr(x, "setup")$query,
                !!!query_param,
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
      tidyr::unnest_wider(dplyr::all_of(locs),
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
                  query = list()) {
  path <- resas_path(path)

  setup <- list(url = "https://opendata.resas-portal.go.jp/",
                X_API_KEY = X_API_KEY,
                path = path,
                query = query)
  docs <- resas_docs(setup)

  # param
  param <- docs$param
  param$width_description <- pillar::get_max_extent(param$description)
  param_keys <- str_to_snakecase(param$name)
  param <- navigatr::new_menu(key = param_keys,
                              value = list(navigatr::new_empty_item(class = "resas_param_item")),
                              attrs = param,
                              class = "resas_param")

  # resp
  resp <- docs$resp
  resp_attrs <- resp %>%
    dplyr::mutate(name = .data$name %>%
                    stringr::str_remove("^/result/"))
  resp_keys <- resp_attrs$name %>%
    str_to_snakecase() %>%
    stringr::str_replace_all("/", "_")

  resp <- navigatr::new_menu(key = resp_keys,
                             value = list(navigatr::new_empty_item(class = "resas_resp_item")),
                             attrs = resp_attrs,
                             class = "resas_resp")

  navigatr::new_menu(key = c("param", "resp"),
                     value = list(param, resp),
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

  resp <- x %>%
    activate("resp")
  nms_old <- resp$attrs$name
  nms_new <- resp$key
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
collect.resas_param <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}

#' @export
collect.resas_param_item <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}

#' @export
collect.resas_resp <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}

#' @export
collect.resas_resp <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.resas(...)
}



# printing ----------------------------------------------------------------

#' @export
vec_ptype_abbr.resas_param <- function(x) {
  "parameters"
}

#' @export
obj_sum.resas_param_item <- function(x) {
  description <- attr(x, "description")
  width_description <- attr(x, "width_description")

  if (is.null(description)) {
    "resas_param_item"
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
vec_ptype_abbr.resas_resp <- function(x) {
  "responses"
}

#' @export
obj_sum.resas_resp_item <- function(x) {
  attr(x, "description") %||% "resas_resp_item"
}
