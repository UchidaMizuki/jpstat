#' Real estate transaction price information API (Real Estate Information Library)
#'
#' `r lifecycle::badge("experimental")`
#'
#' Collect data from the Real Estate Information Library
#' (不動産情報ライブラリ) API provided by Japan's Ministry of
#' Land, Infrastructure, Transport and Tourism (MLIT). This API replaced the
#' old "Land General Information System" (土地総合情報システム,
#' `webland`) API, which has been discontinued.
#'
#' Using this API requires an API key. Apply for one at
#' <https://www.reinfolib.mlit.go.jp/api/request/> and set it with
#' `Sys.setenv(REINFOLIB_API_KEY = )`.
#'
#' @param lang Language, `"ja"` (Japanese) or `"en"` (English).
#'
#' @return `webland_trade()` a `webland_trade` object. By creating a query with
#' `itemise()` and applying `collect()`, the real estate transaction prices are
#' collected. `year` and `quarter` are required, and at least one of
#' `pref_code`, `city_code` or `station_code` must be supplied.
#'
#' `webland_city()` a `webland_city` object. Obtains a list of municipalities in
#' a prefecture in the same way as `webland_trade()`.
#'
#' @examples
#' \dontrun{
#' # Set the API key issued by the Real Estate Information Library
#' Sys.setenv(REINFOLIB_API_KEY = "Your API key")
#'
#' # Collect trade data
#' webland_trade() |>
#'   itemise(year = "2015",
#'           quarter = "1",
#'           city_code = "13102") |>
#'   collect()
#'
#' # Collect municipalities
#' webland_city() |>
#'   itemise(pref_code = "13") |>
#'   collect()
#' }
#'
#' @name webland
#' @export
webland_trade <- function(lang = c("ja", "en")) {
  lang <- rlang::arg_match(lang)
  setup <- list(lang = lang)

  params <- tibble::tribble(
    ~key,                   ~description,                                          ~required,
    "year",                 "取引年 (year)",                                       TRUE,
    "quarter",              "四半期 (quarter)",                                    TRUE,
    "pref_code",            "都道府県コード (area)",                FALSE,
    "city_code",            "市区町村コード (city)",               FALSE,
    "station_code",         "駅コード (station)",                              FALSE,
    "price_classification", "価格情報区分 (priceClassification)",     FALSE
  )
  width <- pillar::get_max_extent(params$description)
  value <- purrr::map2(params$description, params$required,
                       function(description, required) {
                         new_webland_value(description, width, required)
                       })

  navigatr::new_nav_input(key = params$key,
                          value = value,
                          setup = setup,
                          class = "webland_trade")
}

#' @rdname webland
#' @export
webland_city <- function(lang = c("ja", "en")) {
  lang <- rlang::arg_match(lang)
  setup <- list(lang = lang)

  description <- "都道府県コード (area)"
  width <- pillar::get_max_extent(description)

  navigatr::new_nav_input(key = "pref_code",
                          value = list(new_webland_value(description, width, TRUE)),
                          setup = setup,
                          class = "webland_city")
}

# Mapping from `itemise()` keys to Real Estate Information Library API parameters.
webland_param_names <- c(year = "year",
                         quarter = "quarter",
                         pref_code = "area",
                         city_code = "city",
                         station_code = "station",
                         price_classification = "priceClassification")

webland_query <- function(x) {
  query <- purrr::map2(x$key, x$value,
                       function(key, value) {
                         value <- vec_data(value)
                         if (vec_is_empty(value)) {
                           character()
                         } else {
                           commas0(value)
                         }
                       }) |>
    set_names(unname(webland_param_names[x$key]))
  compact_query(!!!query)
}

webland_get <- function(url, query, lang) {
  key <- Sys.getenv("REINFOLIB_API_KEY")
  if (key == "") {
    rlang::abort(c("`REINFOLIB_API_KEY` does not exist.",
                   i = "Please set the key with `Sys.setenv(REINFOLIB_API_KEY = )`.",
                   i = "An API key can be obtained at <https://www.reinfolib.mlit.go.jp/api/request/>."))
  }

  out <- httr2::request(url) |>
    httr2::req_headers(`Ocp-Apim-Subscription-Key` = key) |>
    httr2::req_url_query(!!!query, language = lang) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (!identical(out$status, "OK")) {
    rlang::abort(stringr::str_glue("The Real Estate Information Library API returned status `{out$status %||% 'unknown'}`."))
  }
  out$data
}

#' @export
collect.webland_trade <- function(x, ...) {
  setup <- attr(x, "setup")
  query <- webland_query(x)

  if (vec_is_empty(query$year) || vec_is_empty(query$quarter)) {
    abort("`year` and `quarter` are required.")
  }
  if (!any(c("area", "city", "station") %in% names(query))) {
    abort("At least one of `pref_code`, `city_code` or `station_code` is required.")
  }

  webland_get("https://www.reinfolib.mlit.go.jp/ex-api/external/XIT001",
              query = query,
              lang = setup$lang) |>
    dplyr::bind_rows() |>
    dplyr::rename_with(str_to_snakecase)
}

#' @export
collect.webland_city <- function(x, ...) {
  setup <- attr(x, "setup")

  pref_code <- vec_data(vec_slice(x$value, x$key == "pref_code")[[1L]])
  if (vec_size(pref_code) != 1L) {
    abort("The size of `pref_code` must be 1.")
  }

  webland_get("https://www.reinfolib.mlit.go.jp/ex-api/external/XIT002",
              query = list(area = pref_code),
              lang = setup$lang) |>
    dplyr::bind_rows() |>
    dplyr::rename(city_code = "id",
                  city_name = "name")
}

# value -------------------------------------------------------------------

new_webland_value <- function(description, width, required) {
  new_vctr(character(),
           description = description,
           width = width,
           required = required,
           class = "webland_value")
}

#' @export
obj_sum.webland_value <- function(x) {
  description <- attr(x, "description")
  width <- attr(x, "width")
  required <- attr(x, "required")

  required <- if (required) " (Required)" else ""

  stringr::str_c(pillar::align(description, width), ": ", commas(vec_data(x)), required)
}
