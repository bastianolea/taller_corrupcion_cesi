library(rvest)
library(dplyr)

sitio <- session("https://www.biobiochile.cl/lista/categorias/nacional") |>
  read_html_live()

titulos <- sitio |>
  html_elements(".article-text-container")

titulos |> html_text2()

enlaces <- titulos  |> 
  html_element("a") |>
  html_attr("href")

enlaces