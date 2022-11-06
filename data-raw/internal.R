library(tidyverse)

# internal ----------------------------------------------------------------

webland_docs <- read_rds("data-raw/webland_docs.rds")
resas_v1_docs <- read_rds("data-raw/resas_v1_docs.rds")

usethis::use_data(webland_docs, resas_v1_docs,
                  overwrite = TRUE,
                  internal = TRUE)
