#' @export
webland <- function(pref_code = NULL,
                    lang = c("ja", "en"),
                    query = list()) {
  lang <- rlang::arg_match(lang, c("ja", "en"))
  setup <- compact_query(url = "https://www.land.mlit.go.jp/webland/api.html",
                         pref_code = pref_code,
                         lang = lang,
                         query = query)

  if (is.null(pref_code)) {
    pref <- webland_docs$pref %>%
      dplyr::mutate(pref_name_en = .data$pref_name_en %>%
                      stringr::str_remove("\\sPrefecture$"))

    if (lang == "ja") {
      navigatr::new_select(key = pref$pref_name_ja,
                           value = list(navigatr::new_empty_item(class = "webland_pref_item")),
                           attrs = pref[c("pref_code", "pref_name_en")],
                           setup = setup,
                           class = "webland_pref")
    } else if (lang == "en") {
      navigatr::new_select(key = pref$pref_name_en,
                           value = list(navigatr::new_empty_item(class = "webland_pref_item")),
                           attrs = pref[c("pref_code", "pref_name_ja")],
                           setup = setup,
                           class = "webland_pref")
    }
  } else {
    # city
    city <- webland_city(pref_code,
                         lang = lang)
    city <- new_data_frame(city,
                           size_city_total = vec_size(city),
                           class = c("tbl_webland_city", "tbl"))

    # param
    param <- navigatr::new_form(key = c("from", "to"),
                                value = list(navigatr::new_empty_item(class = c("webland_param_item"))),
                                attrs = tibble::tibble(description = c("取引時期From", "取引時期To")) %>%
                                  dplyr::mutate(width_description = pillar::get_max_extent(description)),
                                class = "webland_param")

    # resp
    resp <- webland_docs$resp_trade
    resp <- navigatr::new_select(key = str_to_snakecase(resp$key),
                                 value = list(navigatr::new_empty_item(class = "webland_resp_item")),
                                 attrs = resp,
                                 class = "webland_resp")

    navigatr::new_menu(key = c("city", "param", "resp"),
                       value = list(city, param, resp),
                       setup = setup,
                       class = "webland")
  }
}

#' @export
obj_sum.webland_pref_item <- function(x) {
  pref_name <- attr(x, "pref_name_en") %||% attr(x, "pref_name_ja")

  if (is.null(pref_name)) {
    "webland_pref_item"
  } else {
    pref_name
  }
}

#' @export
collect.webland_pref <- function(x,
                                 query = list(), ...) {
  setup <- attr(x, "setup")
  x <- tibble::as_tibble(x)

  if (vec_size(x) != 1L) {
    abort("`select` only one prefecture.")
  }

  webland(x$attrs$pref_code,
          lang = setup$lang,
          query = setup$query)
}

#' @export
collect.webland_pref_item <- function(x, ...) {
  x %>%
    deactivate() %>%
    collect.webland_pref(...)
}

#' @export
vec_ptype_abbr.webland_param <- function(x) {
  "parameters"
}

#' @export
obj_sum.webland_param_item <- function(x) {
  description <- attr(x, "description")
  width_description <- attr(x, "width_description")

  if (is.null(description)) {
    "webland_param_item"
  } else {
    out <- stringr::str_c(pillar::align(description, width_description),
                          cli::symbol$arrow_right,
                          sep = " ")

    if (is_empty(x)) {
      out <- stringr::str_c(out, "NULL",
                            sep = " ")
    } else {
      out <- stringr::str_c(out,
                            encodeString(webland_period(x),
                                         quote = "\""),
                            sep = " ")
    }
    out
  }
}

#' @export
obj_sum.tbl_webland_city <- function(x) {
  out <- stringr::str_c("市区町村コード", cli::symbol$arrow_right,
                        sep = " ")

  size_city <- vec_size(x)
  size_city_total <- attr(x, "size_city_total")

  if (size_city == size_city_total) {

  } else {
    if (size_city > 1L) {
      abort()
    }


  }
}

#' @export
vec_ptype_abbr.webland_resp <- function(x) {
  "responses"
}

#' @export
obj_sum.webland_resp_item <- function(x) {
  attr(x, "description") %||% "webland_resp_item"
}


#' Information on real estate transaction prices API
#'
#' @param from A start time.
#' @param to An end time.
#' @param pref_code A prefecture code.
#' @param city_code A city code.
#' @param lang Language.
#' @param .rename Change the names?
#'
#' @seealso <https://www.land.mlit.go.jp/webland_english/servlet/MainServlet>
#' @seealso <https://www.land.mlit.go.jp/webland/api.html>
#'
#' @export
NULL

webland_trade <- function(from, to,
                          pref_code = NULL,
                          city_code = NULL,
                          lang = c("ja", "en"),
                          .rename = TRUE) {
  from <- webland_period(from)
  to <- webland_period(to)

  message(stringr::str_glue("The period is from {from$ym_from} to {to$ym_to}."))

  pref_code <- as_pref_code(pref_code)
  city_code <- as_city_code(city_code)

  lang <- rlang::arg_match(lang, c("ja", "en"))

  if (lang == "ja") {
    path <- "webland/api/TradeListSearch"
  } else if (lang == "en") {
    path <- "webland_english/api/TradeListSearch"
  }

  trade <- httr::GET("https://www.land.mlit.go.jp/",
                     path = path,
                     query = compact_query(from = from$period,
                                           to = to$period,
                                           area = pref_code,
                                           city = city_code))
  httr::stop_for_status(trade)
  trade <- trade %>%
    httr::content() %>%
    purrr::chuck("data") %>%
    dplyr::bind_rows()

  if (vec_size(trade) >= 1 && .rename) {
    trade <- trade %>%
      dplyr::rename_with(str_to_snakecase) %>%
      dplyr::rename(city_code = "municipality_code",
                    pref_name = "prefecture",
                    city_name = "municipality")
  }
  trade
}

webland_city <- function(pref_code,
                         lang = c("ja", "en")) {
  pref_code <- as_pref_code(pref_code)

  lang <- rlang::arg_match(lang, c("ja", "en"))

  if (lang == "ja") {
    path <- "webland/api/CitySearch"
  } else if (lang == "en") {
    path <- "webland_english/api/CitySearch"
  }

  city <- httr::GET("https://www.land.mlit.go.jp/",
                    path = path,
                    query = list(area = pref_code))
  httr::stop_for_status(city)
  city <- city %>%
    httr::content() %>%
    purrr::chuck("data") %>%
    dplyr::bind_rows()

  names(city) <- c("city_code", "city_name")
  city
}

webland_period <- function(x) {
  if (lubridate::is.Date(x)) {
    year <- lubridate::year(x)
    month <- lubridate::month(x)

    if (month %in% 1:3) {
      period <- 1L
    } else if (month %in% 4:6) {
      period <- 2L
    } else if (month %in% 7:10) {
      period <- 3L
    } else if (month %in% 11:12) {
      period <- 4L
    }
  } else {
    if (!stringr::str_detect(x, "^\\d{5}$")) {
      abort("Period must be a 5-digit number.")
    }

    period <- x %>%
      stringr::str_match("^(\\d{4})(\\d)$")
    year <- as.integer(period[, 2])
    period <- as.integer(period[, 3])
  }

  if (year < 2005 || year == 2005 && period < 3) {
    abort("Period must be after July 2005.")
  }

  stringr::str_c(year, period)
}
