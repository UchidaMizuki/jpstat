library(tidyverse)
library(jpgrid)
library(hexSticker)

pkgload::load_all()

theme_set(theme_void())

font_logo <- "Poppins"

sysfonts::font_add_google(font_logo)

# logo --------------------------------------------------------------------

file_logo <- "man/figures/logo.png"

fill_logo <- "#BC002D"
color_logo <- "snow"

JGD2011 <- 6668

appId <- keyring::key_get("estat-api")

# Population
popdens_2015 <- estat(appId = appId,
                      statsDataId = "0000010201",
                      lang = "E")

popdens_2015 <- popdens_2015 |>
  activate(tab) |>
  select() |>

  activate(cat01) |>
  filter(name == "#A01202_Population per 1 km2 of inhabitable area") |>
  select() |>

  activate(area) |>
  rekey("pref") |>
  filter(name != "All Japan") |>
  select(code) |>

  activate(time) |>
  filter(name == "2015") |>
  select() |>

  collect(n = "popdens_per_1km2") |>
  mutate(pref_code = pref_code |>
           str_extract("^\\d{2}") |>
           as.integer(),
         popdens_per_1km2 = parse_number(popdens_per_1km2))

japan <- rnaturalearth::ne_states("japan",
                                  returnclass = "sf") |>
  select(iso_3166_2, name) |>
  mutate(pref_code = iso_3166_2 |>
           str_extract("(?<=JP-)\\d{2}") |>
           as.integer()) |>
  select(!iso_3166_2)

bbox_japan <- grid_city2015 |>
  mutate(grid = grid_80km(grid)) |>
  distinct(grid) |>
  sf::st_bbox()

plot_popdens_2015 <- japan |>
  left_join(popdens_2015,
            by = "pref_code") |>
  ggplot(aes(fill = popdens_per_1km2)) +
  geom_sf(show.legend = FALSE,
          color = "transparent") +
  scale_fill_viridis_c(option = "turbo",
                       trans = "log10") +
  coord_sf(xlim = bbox_japan[c("xmin", "xmax")],
           ylim = bbox_japan[c("ymin", "ymax")])

sticker(plot_popdens_2015,
        package = "",
        filename = file_logo,

        s_width = 2.0,
        s_height = 2.0,
        s_x = 1,
        s_y = 0.8,

        h_fill = fill_logo,
        h_color = "transparent") +
  geom_url(url = "jpstat",
           x = 0.975,
           y = 0.225,
           family = font_logo,
           fontface = "bold.italic",
           size = 22,
           color = color_logo) +
  theme(plot.margin = margin(r = -1,
                             l = -1))

save_sticker(file_logo)
usethis::use_logo(file_logo)
