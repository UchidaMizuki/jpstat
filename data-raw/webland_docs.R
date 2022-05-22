library(tidyverse)
library(rvest)

# webland_docs --------------------------------------------------------------
# https://www.land.mlit.go.jp/webland/api.html

webland_docs <- read_html("https://www.land.mlit.go.jp/webland/api.html") |>
  html_elements("table.api_table") |>
  map(html_table) |>
  set_names(c("param_trade", "resp_trade", "param_city", "resp_city", "pref"))

names(webland_docs$param_trade) <- c("key", "description", "note", "required")
names(webland_docs$resp_trade) <- c("key", "description", "note")
names(webland_docs$param_city) <- c("key", "description", "note", "required")
names(webland_docs$resp_city) <- c("key", "description")

webland_docs$pref <- webland_docs$pref |>
  rename(pref_code = `都道府県コード`,
         pref_name_ja = `日本語表記`,
         pref_name_en = `英語表記`)

write_rds(webland_docs,
          "data-raw/webland_docs.rds")
