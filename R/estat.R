#' @export
estat <- function(statsDataId, appId) {
  query <- list(statsDataId = statsDataId,
                appId = appId)
  query <- purrr::compact(query)

  meta_info <- httr::GET(URL_ESTAT,
                         config = httr::add_headers(`Accept-Encoding` = "gzip"),
                         path = stringr::str_c(URL_ESTAT_API, "getMetaInfo"),
                         query = query)

  httr::warn_for_status(meta_info)

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
                                                      collapse = "_")
                                     })

  meta_info <- meta_info$CLASS_INF$CLASS_OBJ
  meta_info <- tibble::tibble(meta_info = meta_info)
  meta_info <- tidyr::unnest_wider(meta_info, "meta_info")
  list(meta_info = meta_info,
       table_info = table_info)
}
