#' Set 'X_API_KEY' of 'RESAS' API
#'
#' @param X_API_KEY An X_API_KEY of 'RESAS' API.
#'
#' @export
resas_set_apikey <- function(X_API_KEY) {
  japanstat_global$resas_apikey <- X_API_KEY
  invisible()
}

resas_path <- function(x) {
  x %>%
    stringr::str_remove(stringr::str_glue("^.*{japanstat_global$resas_path}")) %>%
    stringr::str_remove("\\.html$")
}

resas_get <- function(path, query) {
  out <- httr::GET(japanstat_global$resas_url,
                   config = httr::add_headers(`X-API-KEY` = japanstat_global$resas_apikey),
                   path = stringr::str_c(japanstat_global$resas_path, path),
                   query = query)
  httr::stop_for_status(out)
  httr::content(out)
}

#' Get parameters of 'RESAS' data
#'
#' @seealso <https://opendata.resas-portal.go.jp/>
#'
#' @export
resas <- function(path) {
  path <- resas_path(path)
  path <- stringr::str_glue("{japanstat_global$resas_url}docs/{japanstat_global$resas_path}{path}.html")

  section <- rvest::read_html(path) %>%
    rvest::html_elements("body > div > article > section")

  for (i in seq_along(section)) {
    h1 <- section[[i]] %>%
      rvest::html_elements("h1") %>%
      rvest::html_text()

    if (!vctrs::vec_is_empty(h1) && h1 == "parameters") {
      parameters <- section[[i]] %>%
        rvest::html_table()
    }
    if (!vctrs::vec_is_empty(h1) && h1 == "responses") {
      responses <- section[[i]] %>%
        rvest::html_table()
    }
  }

  if (vctrs::vec_is_empty(parameters)) {
    parameters <- tibble::tibble(name = character(),
                                 name_to = character(),
                                 parameter = character(),
                                 required = logical(),
                                 description = character())
  } else {
    parameters <- parameters %>%
      dplyr::rename_with(stringr::str_to_lower)
    parameters$name_to <- str_to_snakecase(parameters$name)
    parameters$parameter <- NA_character_
    parameters$required <- !is.na(parameters$required) & parameters$required == "true"
    parameters$description <- parameters$description %>%
      stringr::str_remove_all("[:space:]")
    parameters <- parameters[c("name", "name_to", "parameter", "required", "description")]
  }

  if (vctrs::vec_is_empty(responses)) {
    responses <- tibble::tibble(name = character(),
                                name_to = character(),
                                description = character())
  } else {
    responses <- responses %>%
      dplyr::rename_with(stringr::str_to_lower)
    responses$name_to <- NA_character_
    responses$description <- responses$description %>%
      stringr::str_remove_all("[:space:]")
    responses <- responses[c("name", "name_to", "description")]
  }

  structure(list(parameters = vctrs::new_data_frame(parameters,
                                                    class = c("resas_parameters", "tbl")),
                 responses = vctrs::new_data_frame(responses,
                                                   class = c("resas_responses", "tbl"))),
            class = "resas")
}

#' @importFrom pillar tbl_format_header
#' @export
pillar::tbl_format_header

#' @export
tbl_format_header.resas_parameters <- function(x, setup) {
  pillar::style_subtle("# Parameters")
}

# print.resas_parameters <- function(x, ...) {
#   cat_subtle("# Parameters\n")
#
#   id <- stringr::str_c("[", x$id, "]") %>%
#     str_pad_common("left")
#   name <- str_pad_common(x$name)
#   required <- dplyr::if_else(x$required,
#                              "(required)",
#                              "") %>%
#     str_pad_common()
#
#   writeLines(pillar::style_subtle(stringr::str_glue("{id} {name} {required}")))
# }

resas_rectangle <- function(data) {

}
