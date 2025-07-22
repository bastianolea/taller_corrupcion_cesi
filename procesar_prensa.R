library(dplyr)
library(tidytext)
library(readr)

prensa <- read_csv2("datos/prensa_datos_muestra.csv")


prensa


eliminar <- c("2025", "lee", "julio", "si", "tras", "dos", "martes", "content", "https", "lunes", "media.biobiochile.cl", "uploads", "wp",
              "c", "right", "top", "exante's", "ad", "server", "banner", "si", "dos", "us")

palabras <- prensa |> 
  unnest_tokens(output = "palabras",
                input = cuerpo) |> 
  filter(!palabras %in% stopwords::stopwords("es"),
         !palabras %in% eliminar)

palabras |> 
  group_by(fuente) |> 
  count(palabras, sort = TRUE) |> 
  print(n = 30)


palabras |> 
  # slice(1:10) |> 
  mutate(mes = lubridate::month(fecha, label = TRUE, locale = "es-CL")) |> 
  group_by(mes) |> 
  count(palabras, sort = TRUE) |> 
  group_by(mes) |> 
  slice_max(n, n = 10) |> 
  arrange(mes, n) |> 
  print(n = 30)

palabras_mes <- palabras |> 
  mutate(mes = lubridate::month(fecha, label = TRUE, locale = "es-CL")) |> 
  group_by(mes) |> 
  count(palabras, sort = TRUE) |> 
  group_by(mes) |> 
  slice_max(n, n = 15) |> 
  arrange(mes, n)

library(ggplot2)

palabras_mes |> 
  group_by(mes) |> 
  mutate(orden = 1:n()) |> 
  ggplot() +
  aes(mes, orden, fill = n) +
  geom_tile() +
  geom_text(aes(label = palabras), color = "white") +
  scale_fill_viridis_c()


