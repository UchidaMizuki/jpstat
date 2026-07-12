library(tidyverse)

# internal ----------------------------------------------------------------

resas_v1_docs <- read_rds("data-raw/resas_v1_docs.rds")

usethis::use_data(resas_v1_docs, overwrite = TRUE, internal = TRUE)
