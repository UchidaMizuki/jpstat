resas_set_apikey(keyring::key_get("resas-api"))

resas("https://opendata.resas-portal.go.jp/docs/api/v1/population/nature.html") -> res
res

resas_get("population/composition/perYear",
          query = list(prefCode = "13",
                       cityCode = "13101")) -> res1

res1 %>%
  listviewer::jsonedit()

res1 %>%
  listviewer::jsonedit()

tibble(data = res1["result"]) %>%
  unnest_wider(data,
               names_repair = function(x) {
                 stringr::str_c("result/", x)
               })
  dplyr::select(line) %>%
  unnest_auto(line) %>%
  unnest_auto(data)


  filter(b != "boundaryYear") %>%
  unnest_longer(data) %>%
  unnest_wider(data)
  unnest_longer(data,
                names_repair = ~ c("data", "b", "bb", "bbb"))
  unnest_auto_deep()
