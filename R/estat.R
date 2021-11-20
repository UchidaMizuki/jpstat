#' Set appId of e-Stat API
#'
#' @param appId An appId of e-Stat API.
#'
#' @return No output.
#'
#' @export
estat_set_appId <- function(appId) {
  japanstat_global$appId <- appId
  invisible()
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
                  appId = NULL) {
  appId <- appId %||% japanstat_global$appId
  stopifnot(!is.null(appId))

  query <- list(statsDataId = statsDataId,
                appId = appId)

  meta_info <- httr::GET(japanstat_global$url_estat,
                         # config = httr::add_headers(`Accept-Encoding` = "gzip"),
                         path = c(japanstat_global$path_estat, "getMetaInfo"),
                         query = query)

  httr::stop_for_status(meta_info)

  meta_info <- httr::content(meta_info)
  meta_info <- meta_info$GET_META_INFO

  if (meta_info$RESULT$STATUS != 0) {
    stop(meta_info$RESULT$ERROR_MSG)
  }

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
  names(meta_info)[names(meta_info) == "CLASS"] <- "data"
  meta_info$data <- purrr::modify(meta_info$data,
                                  function(data) {
                                    data <- dplyr::bind_rows(data)
                                    names(data) <- stringr::str_remove(names(data), "^@")
                                    data
                                  })
  meta_info$col <- purrr::modify(meta_info$data,
                                 function(data) {
                                   names(data)
                                 })
  meta_info$new_name <- meta_info$id

  out <- structure(meta_info,
                   class = "estat")
  attr(out, "table_info") <- table_info
  out
}

#'
#'
#' @export
estat_table_info <- function(x) {
  attr(x, "table_info")
}

#'
#'
#' @export
print.estat <- function(x, ...) {
  active_id <- attr(x, "active_id") %||% ""

  cat_subtle("# Keys\n")
  print_keys(x, active_id)
  cat_subtle("#\n")

  if (active_id == "") {
    cat_subtle("# No active key\n")
  } else {
    data <- x$data[x$id == active_id][[1L]]
    col <- x$col[x$id == active_id][[1L]]
    data <- select(data, dplyr::all_of(col))
    data <- vctrs::new_data_frame(data,
                                  class = c("tbl_estat", "tbl"))
    attr(data, "id") <- active_id
    print(data)
  }
}

print_keys <- function(x, active_id) {
  checkbox <- dplyr::if_else(x$id == active_id,
                             cli::symbol$checkbox_on,
                             cli::symbol$checkbox_off)
  id <- str_pad_common(x$id)
  name <- str_pad_common(x$name)
  new_name <- str_pad_common(x$new_name)

  size <- purrr::map_dbl(x$data,
                         function(data) {
                           vctrs::vec_size(data)
                         })
  size <- stringr::str_glue("[{size}]")
  size <- str_pad_common(size)

  col <- purrr::map_chr(x$col,
                        function(col) {
                          stringr::str_c(col,
                                         collapse = ", ")
                        })

  writeLines(pillar::style_subtle(stringr::str_glue("# {checkbox} {id}: {name} > {new_name} {size} ({col})")))
}

#' @export
tbl_sum.tbl_estat <- function(x, ...) {
  id <- attr(x, "id")
  header <- NextMethod()
  names(header) <- stringr::str_glue("A {id} data")
  header
}
