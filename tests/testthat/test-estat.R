


estat_set_appId(keyring::key_get("e-Stat-appId"))

statsDataId <- "0003411172"

.estat <- estat(statsDataId = statsDataId)

.estat %>%
  estat_activate_tab() %>%
  select(name) %>%
  filter(name == "人口")

# .estat1 <- estat(statsDataId = "0000033693")
# .estat2 <- estat(statsDataId = "0003038586")
