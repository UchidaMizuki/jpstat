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
iretp_trade <- function(from, to, pref_code, city_code,
                        lang = c("ja", "en"),
                        .rename = TRUE) {
  from <- iretp_period(from)
  to <- iretp_period(to)

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
                     query = list(from = from$period,
                                  to = to$period,
                                  area = pref_code,
                                  city = city_code))
  httr::stop_for_status(trade)
  trade <- trade %>%
    httr::content() %>%
    purrr::chuck("data") %>%
    dplyr::bind_rows()

  if (.rename) {
    trade <- trade %>%
      dplyr::rename_with(str_to_snakecase) %>%
      dplyr::rename(city_code = "municipality_code",
                    pref_name = "prefecture",
                    city_name = "municipality")
  }
  trade
}

#' @rdname iretp_trade
#' @export
iretp_city <- function(pref_code,
                       lang = c("ja", "en"),
                       .rename = TRUE) {
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

  if (.rename) {
    names(city) <- c("city_code", "city_name")
  }
  city
}

iretp_period <- function(x) {
  if (stringr::str_detect(x, "^\\d{5}$")) {
    period <- x %>%
      stringr::str_match("^(\\d{4})(\\d)$")
    year <- as.integer(period[, 2])
    period <- as.integer(period[, 3])
  } else {
    stopifnot(lubridate::is.Date(x))

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
  }

  if (period == 1L) {
    month_from <- 1
    month_to <- 3
  } else if (period == 2L) {
    month_from <- 4
    month_to <- 6
  } else if (period == 3L) {
    month_from <- 7
    month_to <- 10
  } else if (period == 4L) {
    month_from <- 11
    month_to <- 12
  }

  stopifnot(year >= 2005,
            year > 2005 || period >= 3)

  list(period = stringr::str_c(year, period),
       ym_from = stringr::str_c(year,
                                stringr::str_pad(month_from, 2,
                                                 pad = "0"),
                                sep = "-"),
       ym_to = stringr::str_c(year,
                              stringr::str_pad(month_to, 2,
                                               pad = "0"),
                              sep = "-"))
}
