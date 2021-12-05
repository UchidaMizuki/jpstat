estat_stats_data_id <- function(statsDataId) {
  if (stringr::str_detect(statsDataId, "^\\d+$")) {
    statsDataId
  } else {
    # when statsDataId is url
    statsDataId <- stringr::str_extract(statsDataId, "(?<=\\?)[^\\?]+")
    statsDataId <- stringr::str_split(statsDataId, "&")
    statsDataId <- statsDataId[[1L]]
    statsDataId <- stringr::str_match(statsDataId, "(.+)=(.+)")

    nms <- statsDataId[, 2L]
    statsDataId <- statsDataId[, 3L]
    names(statsDataId) <- nms

    statsDataId <- vctrs::vec_slice(statsDataId, names(statsDataId) %in% c("statdisp_id", "sid"))
    statsDataId[[1L]]
  }
}

estat_get <- function(path, query) {
  out <- httr::GET(japanstat_global$estat_url,
                   config = httr::add_headers(`Accept-Encoding` = "gzip"),
                   path = c(japanstat_global$estat_path, path),
                   query = query)
  httr::stop_for_status(out)
  httr::content(out)
}

#' Get meta-information of 'e-Stat' data
#'
#' The \code{estat} gets the meta-information of a statistical table by using \code{getMetaInfo} of the 'e-Stat' API,
#' and returns an \code{estat} object that allows editing of meta-information by \code{filter} and \code{select}.
#'
#' @param statsDataId A statistical data ID on 'e-Stat'.
#' @param appId An 'appId' of 'e-Stat' API.
#' @param lang A language, Japanese (\code{"ja"}) or English (\code{"en"}).
#' @param query A list of additional queries.
#'
#' @return A \code{estat} object.
#'
#' @examples
#' \dontrun{
#' estat("https://www.e-stat.go.jp/dbview?sid=0003433219")
#' }
#'
#' @seealso <https://www.e-stat.go.jp>
#' @seealso <https://www.e-stat.go.jp/en>
#'
#' @export
estat <- function(statsDataId,
                  appId = NULL,
                  lang = c("ja", "en"),
                  query = NULL) {
  statsDataId <- estat_stats_data_id(statsDataId)

  appId <- appId %||% japanstat_global$estat_apikey
  stopifnot(!is.null(appId))

  lang <- rlang::arg_match(lang, c("ja", "en"))
  if (lang == "ja") {
    lang <- "J"
  } else if (lang == "en") {
    lang <- "E"
  }

  query <- c(list(statsDataId = statsDataId,
                  appId = appId,
                  lang = lang),
             query)
  query <- compact_query(query)

  meta_info <- estat_get(path = "getMetaInfo",
                         query = query)
  meta_info <- meta_info$GET_META_INFO

  estat_check_status(meta_info)

  meta_info <- meta_info$METADATA_INF

  table_info <- meta_info$TABLE_INF
  table_info <- tibble::enframe(table_info)
  table_info$value <- purrr::map_chr(table_info$value,
                                     function(value) {
                                       stringr::str_c(value,
                                                      collapse = "")
                                     })

  meta_info <- meta_info$CLASS_INF$CLASS_OBJ
  meta_info <- tibble::tibble(meta_info = meta_info)
  meta_info <- tidyr::unnest_wider(meta_info, "meta_info")
  names(meta_info) <- stringr::str_remove(names(meta_info), "^@")
  vctrs::vec_slice(names(meta_info), names(meta_info) == "CLASS") <- "items"
  meta_info$items <- purrr::modify(meta_info$items,
                                   function(items) {
                                     items <- dplyr::bind_rows(items)
                                     names(items) <- stringr::str_remove(names(items), "^@")
                                     items
                                   })
  meta_info$size_items_total <- purrr::map_dbl(meta_info$items,
                                               function(items) {
                                                 vctrs::vec_size(items)
                                               })
  meta_info$vars <- purrr::modify(meta_info$items,
                                  function(items) {
                                    names(items)
                                  })
  meta_info$new_name <- meta_info$id

  out <- structure(meta_info,
                   class = "estat")
  attr(out, "query") <- query
  attr(out, "table_info") <- table_info
  out
}

estat_check_status <- function(x) {
  if (x$RESULT$STATUS != 0) {
    stop(x$RESULT$ERROR_MSG)
  }
}

#' Get table information for 'e-Stat' data
#'
#' @param x A \code{estat} object.
#'
#' @return A \code{tbl} of the table information.
#'
#' @export
estat_table_info <- function(x) {
  attr(x, "table_info")
}

# printing ----------------------------------------------------------------

#' @export
print.estat <- function(x, ...) {
  active_id <- attr(x, "active_id")

  cat_subtle("# Keys\n")
  estat_print_keys(x, active_id)
  cat_subtle("#\n")

  if (is.null(active_id)) {
    cat_subtle("# No active key\n")
  } else {
    print(as_tibble(x))
  }
}

#' @importFrom tibble as_tibble
#' @export
tibble::as_tibble

#' @export
as_tibble.estat <- function(x, ...) {
  active_id <- attr(x, "active_id")

  if (is.null(active_id)) {
    out <- tibble::tibble()
  } else {
    out <- vctrs::vec_slice(x$items, x$id == active_id)[[1L]]
    vars <- vctrs::vec_slice(x$vars, x$id == active_id)[[1L]]
    out <- out[vars]
  }

  out
}

#' @importFrom rlang %||%
estat_print_keys <- function(x, active_id) {
  active_id <- active_id %||% ""

  checkbox <- dplyr::if_else(x$id == active_id,
                             cli::symbol$checkbox_on,
                             cli::symbol$checkbox_off)
  id <- str_pad_common(x$id)
  name <- str_pad_common(x$name)
  new_name <- str_pad_common(x$new_name)

  size <- purrr::map_dbl(x$items,
                         function(items) {
                           vctrs::vec_size(items)
                         })
  size <- stringr::str_glue("[{size}]")
  size <- str_pad_common(size)

  vars <- purrr::map_chr(x$vars,
                         function(vars) {
                           stringr::str_c(vars,
                                          collapse = ", ")
                         })

  writeLines(pillar::style_subtle(stringr::str_glue("# {checkbox} {id}: {name} > {new_name} {size} ({vars})")))
}
