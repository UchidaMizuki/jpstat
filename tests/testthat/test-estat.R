appId <- keyring::key_get("e-Stat-appId")

statsDataId <- "0003411172"

.estat <- estat(statsDataId = statsDataId,
                appId = appId)

.estat$meta_info %>%
  tidyr::unnest_wider("meta_info")
  tidyr::unnest_longer("CLASS")
