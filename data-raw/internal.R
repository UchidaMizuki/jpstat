library(tidyverse)

# internal ----------------------------------------------------------------

webland_docs <- read_rds("data-raw/webland_docs.rds")

usethis::use_data(webland_docs,
                  overwrite = TRUE,
                  internal = TRUE)
