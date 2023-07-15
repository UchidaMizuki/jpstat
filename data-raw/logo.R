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
