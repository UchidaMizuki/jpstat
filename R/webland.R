#' Information on real estate transaction prices API
#'
#' `r lifecycle::badge("experimental")`
#'
#' Collect data from the information on real estate transaction prices API
#' provided by Japan's Ministry of Land, Infrastructure, Transport and Tourism.
#'
#' @param lang Language.
#'
#' @return `webland_trade()` a `webland_trade` object. By creating a query with `itemise()` and
#' applying `collect()`, The real estate transaction prices are collected.
#'
#' `webland_city()` a `webland_city` object. Obtains a list of target
#' municipalities in the same way as `webland_trade()`.
#'
#' @examples
#' \dontrun{
#' # Collect trade data
#' webland_trade() |>
#'   itemise(from = "20151",
#'           to = "20152",
#'           city_code = "13102") |>
#'   collect()
#'
#' # Collect target municipalities
#' webland_city() |>
#'   itemise(pref_code = "13") |>
#'   collect()
#' }
#'
#' @name webland
#' @export
webland_trade <- function(lang = c("ja", "en")) {
  lang <- rlang::arg_match(lang, c("ja", "en"))
  setup <- list(lang = lang)

  width <- pillar::get_max_extent(c("\u53d6\u5f15\u6642\u671fFrom",
                                    "\u53d6\u5f15\u6642\u671fTo",
                                    "\u90fd\u9053\u5e9c\u770c\u30b3\u30fc\u30c9",
                                    "\u5e02\u533a\u753a\u6751\u30b3\u30fc\u30c9"))
  navigatr::new_nav_input(key = c("from", "to", "pref_code", "city_code"),
                          value = list(new_vctr(character(),
                                                setup = setup,
                                                type = "from",
                                                width = width,
                                                class = "webland_time"),
                                       new_vctr(character(),
                                                setup = setup,
                                                type = "to",
                                                width = width,
                                                class = "webland_time"),
                                       new_vctr(character(),
                                                setup = setup,
                                                width = width,
                                                class = "webland_pref_code"),
                                       new_vctr(character(),
                                                setup = setup,
                                                width = width,
                                                class = "webland_city_code")),
                          setup = setup,
                          class = "webland_trade")
}

#' @rdname webland
#' @export
webland_city <- function(lang = c("ja", "en")) {
  lang <- rlang::arg_match(lang, c("ja", "en"))
  setup <- list(lang = lang)

  navigatr::new_nav_input(key = "pref_code",
                          value = list(new_vctr(character(),
                                                setup = setup,
                                                class = "webland_pref_code")),
                          setup = setup,
                          class = "webland_city")
}

#' @export
collect.webland_trade <- function(x, ...) {
  setup <- attr(x, "setup")

  url <- switch (
    setup$lang,
    ja = "https://www.land.mlit.go.jp/webland/api/TradeListSearch",
    en = "https://www.land.mlit.go.jp/webland_english/api/TradeListSearch"
  )

  key <- x$key
  query <- purrr::map2(x$key, x$value,
                       function(key, value) {
                         if (vec_size(value) > 1) {
                           abort(stringr::str_glue("The size of `{key}` must be 0 or 1."))
                         }

                         vec_data(value)
                       }) |>
    set_names(key)
  names(query)[key == "pref_code"] <- "area"
  names(query)[key == "city_code"] <- "city"

  httr2::request(url) |>
    httr2::req_url_query(!!!query) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    purrr::chuck("data") |>
    dplyr::bind_rows() |>
    dplyr::rename_with(str_to_snakecase) |>
    dplyr::rename(city_code = "municipality_code",
                  pref_name = "prefecture",
                  city_name = "municipality")
}

#' @export
collect.webland_city <- function(x, ...) {
  setup <- attr(x, "setup")

  url <- switch (
    setup$lang,
    ja = "https://www.land.mlit.go.jp/webland/api/CitySearch",
    en = "https://www.land.mlit.go.jp/webland_english/api/CitySearch"
  )

  pref_code <- vec_data(vec_slice(x$value, x$key == "pref_code")[[1L]])
  if (vec_size(pref_code) > 1) {
    abort("The size of `pref_code` must be 0 or 1.")
  }

  httr2::request(url) |>
    httr2::req_url_query(area = pref_code) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    purrr::chuck("data") |>
    dplyr::bind_rows() |>
    set_names(c("city_code", "city_name"))
}

#' @export
obj_sum.webland_time <- function(x) {
  type <- attr(x, "type")
  width <- attr(x, "width")

  x <- vec_data(x)

  if (!all(stringr::str_detect(x, "^\\d{5}$"))) {
    abort(stringr::str_glue("`{type}` must be a 5-digit number."))
  }

  year <- stringr::str_extract(x, "^\\d{4}(?=\\d$)")
  month <- stringr::str_extract(x, "(?<=^\\d{4})\\d$")

  out <- dplyr::case_when(month == "1" ~ stringr::str_glue("{year}-01--{year}-03"),
                          month == "2" ~ stringr::str_glue("{year}-04--{year}-06"),
                          month == "3" ~ stringr::str_glue("{year}-07--{year}-10"),
                          month == "4" ~ stringr::str_glue("{year}-11--{year}-12")) |>
    commas()
  description <- switch (
    type,
    from = "\u53d6\u5f15\u6642\u671fFrom",
    to = "\u53d6\u5f15\u6642\u671fTo"
  )

  stringr::str_c(pillar::align(description, width), ": ", out)
}

#' @export
obj_sum.webland_pref_code <- function(x) {
  setup <- attr(x, "setup")
  width <- attr(x, "width")

  col_pref_name <- switch (
    setup$lang,
    ja = "pref_name_ja",
    en = "pref_name_en"
  )

  pref_code <- as_pref_code(webland_docs$pref$pref_code)
  pref_name <- webland_docs$pref[[col_pref_name]]
  pref_name <- vec_slice(pref_name,
                         vec_match(vec_data(x), pref_code))

  out <- commas(stringr::str_c(vec_data(x), "_", pref_name))
  stringr::str_c(pillar::align("\u90fd\u9053\u5e9c\u770c\u30b3\u30fc\u30c9", width), ": ", out)
}

#' @export
obj_sum.webland_city_code <- function(x) {
  width <- attr(x, "width")

  out <- commas(stringr::str_c(vec_data(x)))
  stringr::str_c(pillar::align("\u5e02\u533a\u753a\u6751\u30b3\u30fc\u30c9", width), ": ", out)
}
