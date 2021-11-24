
# census_2020 -------------------------------------------------------------

pkgload::load_all()

estat_set_apikey(keyring::key_get("estat-api"))
estat_census_2020 <- estat("https://www.e-stat.go.jp/dbview?sid=0003433219")

usethis::use_data(estat_census_2020,
                  overwrite = TRUE)
