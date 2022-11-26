library(tidyverse)
library(jpstat)
library(fs)
library(hexSticker)

font_logo_en <- "Poppins"
font_logo_ja <- "Noto Sans JP"

sysfonts::font_add_google(font_logo_en)
sysfonts::font_add_google(font_logo_ja)

# logo --------------------------------------------------------------------

file_logo <- "man/figures/logo.png"

fill_logo <- "#BC002D"
color_logo <- "snow"

pop_census_2020 <- estat(appId = keyring::key_get("estat-api"),
                         statsDataId = "0003445133",
                         lang = "E")

pop_census_2020 <- pop_census_2020 |>
  activate(tab) |>
  select() |>

  activate(cat01) |>
  filter(name == "Total") |>
  select() |>

  activate(cat02) |>
  rekey("sex") |>
  filter(name %in% c("Male", "Female")) |>
  select(name) |>

  activate(cat03) |>
  rekey("age") |>
  select(name) |>

  activate(area) |>
  filter(name == "Japan") |>
  select() |>

  activate(time) |>
  select() |>

  collect(n = "pop")

pop_census_2020 <- pop_census_2020 |>
  filter(str_detect(age_name, "^\\d+ years old")) |>
  mutate(sex = sex_name |>
           str_to_lower() |>
           as_factor(),
         age = age_name |>
           str_extract("^\\d+") |>
           as.integer(),
         pop = parse_number(pop)) |>
  select(sex, age, pop)

plot_pop_census_2020 <- pop_census_2020 |>
  mutate(pop = case_when(sex == "male" ~ -pop,
                         sex == "female" ~ pop)) |>
  add_row(sex = factor(c("male", "female")),
          age = -1,
          pop = 0) |>
  ggplot(aes(age, pop,
             fill = sex)) +
  geom_polygon(show.legend = FALSE) +
  geom_hline(yintercept = 0,
             color = fill_logo,
             linewidth = 1) +
  scale_y_continuous(limits = c(-max(pop_census_2020$pop) - 1, max(pop_census_2020$pop) + 1)) +
  scale_fill_manual(values = c(male = "cornflowerblue",
                               female = "lightcoral")) +
  coord_flip() +
  theme(plot.margin = margin(r = 10,
                             l = 10))

sticker(plot_pop_census_2020,
        package = "jpstat",
        filename = file_logo,

        s_width = 1.7,
        s_height = 0.95,
        s_x = 1,
        s_y = 1.35,

        p_size = 30,
        p_color = color_logo,
        p_y = 0.65,
        p_family = font_logo_en,
        p_fontface = "bold.italic",

        h_fill = fill_logo,
        h_color = "transparent",

        spotlight = TRUE,
        l_x = 1,
        l_y = 1,
        l_width = 6,
        l_height = 6) +
  geom_url(url = "ジェーピースタット",
           family = font_logo_ja,
           fontface = "bold",
           size = 8.5,
           color = color_logo) +
  theme(plot.margin = margin(r = -1.5,
                             l = -1.5))

save_sticker(file_logo)
usethis::use_logo(file_logo)
