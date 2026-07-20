estat_stats_data_id <- function(statsDataId) {
  if (stringr::str_detect(statsDataId, "^\\d+$")) {
    statsDataId
  } else {
    # when statsDataId is a URL
    query <- httr2::url_parse(statsDataId)$query
    query <- query[names(query) %in% c("statdisp_id", "sid")]
    dplyr::first(query)
  }
}

estat_get <- function(path, setup) {
  appId <- Sys.getenv("ESTAT_API_KEY")
  if (appId == "") {
    cli::cli_abort(
      "{.envvar ESTAT_API_KEY} does not exist. Please set the key with
      {.code Sys.setenv(ESTAT_API_KEY = )}.",
      class = "jpstat_error_estat_missing_key"
    )
  }

  get_content(
    setup$url,
    headers = list(`Accept-Encoding` = "gzip"),
    path = c(setup$path, path),
    query = c(list(appId = appId), setup$query)
  )
}

#' Access 'e-Stat' data
#'
#' The `estat()` gets the meta-information of a statistical table by using `getMetaInfo` of the 'e-Stat' API,
#' and returns an `estat` object that allows editing of meta-information by `dplyr::filter()` and `dplyr::select()`.
#'
#' @param statsDataId A statistical data ID on 'e-Stat'.
#' @param lang A language, Japanese (`"J"`) or English (`"E"`).
#' @param query A list of additional queries.
#' @param path An e-Stat API path.
#'
#' @return A `estat` object.
#'
#' @examples
#' \dontrun{
#' Sys.setenv(ESTAT_API_KEY = "Your API key")
#' estat("https://www.e-stat.go.jp/dbview?sid=0003433219")
#' }
#'
#' @seealso <https://www.e-stat.go.jp>
#' @seealso <https://www.e-stat.go.jp/en>
#'
#' @export
estat <- function(
  statsDataId,
  lang = c("J", "E"),
  query = list(),
  path = "rest/3.0/app/json"
) {
  statsDataId <- estat_stats_data_id(statsDataId)
  lang <- arg_match(lang, c("J", "E"))
  query <- compact_query(statsDataId = statsDataId, lang = lang, !!!query)

  setup <- list(url = "https://api.e-stat.go.jp/", path = path, query = query)

  meta_info <- estat_get(path = "getMetaInfo", setup = setup) |>
    purrr::chuck("GET_META_INFO") |>
    estat_check_status() |>
    purrr::chuck("METADATA_INF")

  table_info <- meta_info |>
    purrr::chuck("TABLE_INF") |>
    tibble::enframe() |>
    dplyr::mutate(
      value = .data$value |>
        purrr::map_chr(\(x) {
          x |>
            stringr::str_c(collapse = " ")
        })
    )

  meta_info <- tibble::tibble(
    meta_info = meta_info |>
      purrr::chuck("CLASS_INF", "CLASS_OBJ")
  ) |>
    tidyr::unnest_wider("meta_info") |>
    dplyr::rename_with(\(x) {
      x |>
        stringr::str_remove("^@")
    }) |>
    dplyr::rename(key = "id", key_name = "name", value = "CLASS") |>
    dplyr::mutate(
      value = .data$value |>
        purrr::modify(\(x) {
          x |>
            dplyr::bind_rows() |>
            dplyr::rename_with(\(x) {
              x |>
                stringr::str_remove("^@")
            }) |>
            tibble::rowid_to_column(".estat_rowid") |>
            stickyr::new_sticky_tibble(
              cols = ".estat_rowid",
              col_show = !".estat_rowid",
              class = "tbl_estat"
            )
        }),
      codes = .data$value |>
        purrr::modify(\(x) x$code),
      width_key_name = .data$key_name |>
        pillar::get_max_extent()
    )

  navigatr::new_nav_menu(
    key = meta_info$key,
    value = meta_info$value,
    attrs = meta_info[c("key_name", "width_key_name")],

    setup = setup,
    query_name = meta_info$key,
    codes = meta_info$codes,
    table_info = table_info,

    class = "estat"
  )
}

estat_check_status <- function(x) {
  if (x$RESULT$STATUS != 0) {
    cli::cli_abort(x$RESULT$ERROR_MSG, class = "jpstat_error_estat_api")
  }
  x
}

#' Summarize the table information of an 'e-Stat' table
#'
#' `summary()` returns the table-level metadata (title, survey date,
#' publisher, and so on) of an `estat` object created by [estat()].
#'
#' @param object An `estat` or `tbl_estat` object.
#' @param ... Ignored.
#'
#' @return A `tibble` of table information.
#'
#' @export
summary.estat <- function(object, ...) {
  attr(object, "table_info")
}

#' @rdname summary.estat
#' @export
summary.tbl_estat <- function(object, ...) {
  object |>
    deactivate() |>
    summary()
}

#' Collect data from an 'e-Stat' table
#'
#' `collect()` downloads the statistical values selected from an `estat`
#' object with `dplyr::filter()`, `dplyr::select()`, and
#' [navigatr::rekey()], and returns them as a tidy `tibble`. Large tables
#' are paginated automatically.
#'
#' @param x An `estat` or `tbl_estat` object.
#' @param n Name of the column that holds the observed values.
#' @param names_sep Separator used to combine a classification's key
#'   (e.g. `"area"`) with its selected columns (e.g. `"name"`) into new
#'   column names (e.g. `"area_name"`).
#' @param query A list of additional queries passed to 'e-Stat's
#'   `getStatsData` API.
#' @param limit Maximum number of records requested per page. 'e-Stat'
#'   caps this at 100000.
#' @param ... Ignored.
#'
#' @return A `tibble`.
#'
#' @examples
#' \dontrun{
#' Sys.setenv(ESTAT_API_KEY = "Your API key")
#' estat("https://www.e-stat.go.jp/dbview?sid=0003433219") |>
#'   dplyr::collect()
#' }
#'
#' @export
collect.estat <- function(
  x,
  n = "n",
  names_sep = "_",
  query = list(),
  limit = 100000L,
  ...
) {
  setup <- attr(x, "setup")
  setup$query <- estat_query(x, query)

  total <- estat_total(setup)
  query_name <- attr(x, "query_name")

  if (total == 0) {
    data <- vec_recycle(list(character()), vec_size(query_name) + 1L)
    names(data) <- c(query_name, n)
    data <- tibble::new_tibble(data)
  } else {
    start <- seq(1, total, limit)
    data <- purrr::map(
      start,
      function(start) {
        estat_collect(setup = setup, start = start, limit = limit, n = n)
      },
      .progress = TRUE
    ) |>
      purrr::list_rbind()
  }

  cols <- list(x$key, x$value, query_name, attr(x, "codes")) |>
    purrr::pmap(function(key, value, query_name, codes) {
      value |>
        tibble::as_tibble() |>
        dplyr::rename_with(
          \(x) {
            stringr::str_c(key, x, sep = names_sep)
          },
          !".estat_rowid"
        ) |>
        dplyr::mutate(
          !!query_name := codes[.data$.estat_rowid],
          .keep = "unused"
        )
    })

  for (i in vec_seq_along(query_name)) {
    data <- data |>
      dplyr::left_join(cols[[i]], by = query_name[[i]]) |>
      dplyr::select(!dplyr::all_of(query_name[[i]]))
  }

  data |>
    dplyr::relocate(!dplyr::all_of(n))
}

#' @rdname collect.estat
#' @export
collect.tbl_estat <- function(x, ...) {
  x |>
    deactivate() |>
    collect.estat(...)
}

estat_query <- function(x, query) {
  query_name <- x |>
    attr("query_name") |>
    stringr::str_to_sentence()
  query_name <- stringr::str_c("cd", query_name)

  query_codes <- purrr::map2(x$value, attr(x, "codes"), function(value, codes) {
    size <- vec_size(value)

    if (size == vec_size(codes)) {
      NULL
    } else {
      stringr::str_c(codes[value$.estat_rowid], collapse = ",")
    }
  })
  names(query_codes) <- query_name

  compact_query(
    !!!attr(x, "setup")$query,
    !!!query_codes,
    metaGetFlg = "N",
    !!!query
  )
}

estat_total <- function(setup) {
  setup$query <- c(setup$query, list(cntGetFlg = "Y"))

  total <- estat_get(path = "getStatsData", setup = setup) |>
    purrr::chuck("GET_STATS_DATA") |>
    estat_check_status() |>
    purrr::chuck("STATISTICAL_DATA", "RESULT_INF", "TOTAL_NUMBER")

  cli::cli_inform("The total number of data is {total}.")
  total
}

estat_collect <- function(setup, start, limit, n) {
  setup$query <- compact_query(
    !!!setup$query,
    startPosition = format(start, scientific = FALSE),
    limit = format(limit, scientific = FALSE)
  )
  estat_get(path = "getStatsData", setup = setup) |>
    purrr::chuck("GET_STATS_DATA") |>
    estat_check_status() |>
    purrr::chuck("STATISTICAL_DATA", "DATA_INF", "VALUE") |>
    dplyr::bind_rows() |>
    dplyr::rename_with(\(x) {
      x |>
        stringr::str_remove("^@")
    }) |>
    dplyr::rename(!!n := "$") |>
    dplyr::select(!dplyr::any_of("unit"))
}

# printing ----------------------------------------------------------------

#' @export
obj_sum.tbl_estat <- function(x) {
  attrs <- attributes(x)
  nms <- setdiff(names(x), ".estat_rowid")
  stringr::str_c(
    pillar::align(attrs$key_name, attrs$width_key_name),
    " ",
    "[",
    big_mark(vec_size(x)),
    "] ",
    "<",
    commas(nms),
    ">"
  )
}
