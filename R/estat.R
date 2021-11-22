#' Set appId of e-Stat API
#'
#' @param appId An appId of e-Stat API.
#'
#' @return No output.
#'
#' @export
estat_set_apikey <- function(appId) {
  japanstat_global$estat_apikey <- appId
  invisible()
}

estat_get <- function(path, query) {
  out <- httr::GET(japanstat_global$estat_url,
                   config = httr::add_headers(`Accept-Encoding` = "gzip"),
                   path = c(japanstat_global$estat_path, path),
                   query = query)
  httr::stop_for_status(out)
  httr::content(out)
}

#'
#'
#' @param statsDataId A statistical data ID on e-Stat.
#' @param appId An appId of e-Stat API.
#'
#'
#'
#' @export
estat <- function(statsDataId,
                  appId = NULL,
                  lang = c("J", "E"),
                  query = NULL) {
  appId <- appId %||% japanstat_global$estat_apikey
  stopifnot(!is.null(appId))

  lang <- rlang::arg_match(lang, c("J", "E"))

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

#'
#'
#' @export
estat_table_info <- function(x) {
  attr(x, "table_info")
}

# printing ----------------------------------------------------------------

#' @export
print.estat <- function(x, ...) {
  active_id <- attr(x, "active_id") %||% ""

  cat_subtle("# Keys\n")
  print_keys(x, active_id)
  cat_subtle("#\n")

  if (active_id == "") {
    cat_subtle("# No key is selected.\n")
  } else {
    items <- vctrs::vec_slice(x$items, x$id == active_id)[[1L]]
    vars <- vctrs::vec_slice(x$vars, x$id == active_id)[[1L]]
    items <- select(items, dplyr::all_of(vars))
    items <- vctrs::new_data_frame(items,
                                   class = c("tbl_estat", "tbl"))
    attr(items, "id") <- active_id
    print(items)
  }
}

print_keys <- function(x, active_id) {
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

tbl_sum.tbl_estat <- function(x, ...) {
  id <- attr(x, "id")
  header <- NextMethod()
  names(header) <- stringr::str_glue("The {id} items")
  header
}
