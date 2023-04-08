library(tidyverse)
library(jpgrid)
library(hexSticker)

pkgload::load_all()

theme_set(theme_void())

font_logo <- "Poppins"
sysfonts::font_add_google(font_logo)

# logo --------------------------------------------------------------------

file_logo <- "man/figures/logo.png"

fill_logo <- "firebrick"
color_logo <- "snow"

JGD2011 <- 6668

plot_grid_city <- grid_city |>
  mutate(grid = grid_convert(grid, "80km")) |>
  distinct(grid) |>
  grid_as_sf(crs = JGD2011) |>

  mutate(fill = if_else(as.character(grid) == "3653",
                        "fill_logo",
                        "color_logo")) |>

  ggplot() +
  geom_sf(aes(fill = fill),
          show.legend = FALSE,
          color = fill_logo) +
  scale_fill_manual(values = c(fill_logo = fill_logo,
                               color_logo = color_logo))

sticker(plot_grid_city,
        package = "",
        filename = file_logo,

        s_width = 1.6,
        s_height = 1.6,
        s_x = 1,
        s_y = 1,

        h_fill = fill_logo,
        h_color = "transparent") +
  geom_url(url = "jpstat",
           x = 0.975,
           y = 0.225,
           family = font_logo,
           fontface = "bold.italic",
           size = 22,
           color = color_logo) +
  theme(plot.margin = margin(r = -1.5,
                             l = -1.5))

save_sticker(file_logo)
usethis::use_logo(file_logo)

# appId <- keyring::key_get("estat-api")
#
# # Population
# popdens_2015 <- estat(appId = appId,
#                       statsDataId = "0000010201",
#                       lang = "E")
#
# popdens_2015 <- popdens_2015 |>
#   activate(tab) |>
#   select() |>
#
#   activate(cat01) |>
#   filter(name == "#A01202_Population per 1 km2 of inhabitable area") |>
#   select() |>
#
#   activate(area) |>
#   rekey("pref") |>
#   filter(name != "All Japan") |>
#   select(code) |>
#
#   activate(time) |>
#   filter(name == "2015") |>
#   select() |>
#
#   collect(n = "popdens_per_1km2") |>
#   mutate(pref_code = pref_code |>
#            str_extract("^\\d{2}") |>
#            as.integer(),
#          popdens_per_1km2 = parse_number(popdens_per_1km2))
#
# japan <- rnaturalearth::ne_states("japan",
#                                   returnclass = "sf") |>
#   select(iso_3166_2, name) |>
#   mutate(pref_code = iso_3166_2 |>
#            str_extract("(?<=JP-)\\d{2}") |>
#            as.integer()) |>
#   select(!iso_3166_2)
#
# plot_popdens_2015 <- japan |>
#   left_join(popdens_2015,
#             by = "pref_code") |>
#   ggplot(aes(fill = popdens_per_1km2)) +
#   geom_sf(show.legend = FALSE,
#           color = "transparent") +
#   scale_fill_viridis_c(option = "turbo",
#                        trans = "log10")
#
# sticker(plot_popdens_2015,
#         package = "",
#         filename = file_logo,
#
#         s_width = 2.0,
#         s_height = 2.0,
#         s_x = 1,
#         s_y = 0.9,
#
#         h_fill = fill_logo,
#         h_color = "transparent") +
#   geom_url(url = "jpstat",
#            x = 0.975,
#            y = 0.225,
#            family = font_logo,
#            fontface = "bold.italic",
#            size = 22,
#            color = color_logo) +
#   theme(plot.margin = margin(r = -1,
#                              l = -1))
#
# save_sticker(file_logo)
# usethis::use_logo(file_logo)
