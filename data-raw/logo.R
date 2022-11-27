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
pop_2015 <- estat(appId = appId,
                  statsDataId = "0000020201",
                  lang = "E")

pop_2015 <- pop_2015 |>
  activate(tab) |>
  select() |>

  activate(cat01) |>
  filter(name == "A1101_Total population (Both sexes)") |>
  select() |>

  activate(area) |>
  rekey("city") |>
  select(code, name) |>

  activate(time) |>
  filter(name == "2015") |>
  select() |>

  collect(n = "pop") |>
  mutate(pop = parse_number(pop))

# habitable_area
habitable_area_2015 <- estat(appId = appId,
                             statsDataId = "0000020202",
                             lang = "E")

habitable_area_2015 <- habitable_area_2015 |>
  activate(tab) |>
  select() |>

  activate(cat01) |>
  filter(name == "B1103_Inhabitable area") |>
  select() |>

  activate(area) |>
  rekey("city") |>
  select(code, name) |>

  activate(time) |>
  filter(name == "2015") |>

  collect(n = "habitable_area_ha") |>
  mutate(habitable_area_ha = parse_number(habitable_area_ha,
                                          na = "-"))

popdens_2015 <- grid_city2015 |>
  group_by(city_code) |>
  mutate(size_city_code = n()) |>
  inner_join(pop_2015 |>
               select(city_code, pop),
             by = "city_code") |>
  inner_join(habitable_area_2015 |>
               select(city_code, habitable_area_ha),
             by = "city_code") |>
  mutate(across(c(pop, habitable_area_ha),
                ~ .x / size_city_code)) |>
  select(!size_city_code) |>

  mutate(grid = grid_80km(grid)) |>
  group_by(grid) |>
  summarise(across(c(pop, habitable_area_ha),
                   partial(sum,
                           na.rm = TRUE))) |>
  mutate(popdens_per_ha = pop / habitable_area_ha) |>
  select(!c(pop, habitable_area_ha)) |>
  sf::st_as_sf(crs = JGD2011)

plot_popdens_2015 <- popdens_2015 |>
  ggplot(aes(fill = popdens_per_ha)) +
  geom_sf(show.legend = FALSE,
          color = fill_logo) +
  scale_fill_viridis_c(option = "turbo",
                       trans = "log10")

sticker(plot_popdens_2015,
        package = "",
        filename = file_logo,

        s_width = 1.6,
        s_height = 1.6,
        s_x = 1,
        s_y = 1,

        h_fill = fill_logo,
        h_color = "transparent") +

        # spotlight = TRUE,
        # l_x = 1,
        # l_y = 1,
        # l_width = 6,
        # l_height = 6) +
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
