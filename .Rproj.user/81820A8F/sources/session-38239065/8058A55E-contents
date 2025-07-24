library(readr)

noticias <- read_csv2("datos/noticias.csv")


noticias

library(tidytext)

palabras <- noticias |> 
  unnest_tokens(output = "palabras",
                input = cuerpo) 

palabras

palabras <- noticias |> 
  unnest_tokens(output = "palabras",
                input = cuerpo) |> 
  filter(!palabras %in% stopwords::stopwords("es"))

palabras


eliminar <- c("2025", "lee", "julio", "si", "tras", "dos", "martes", "content", "https", "lunes", "media.biobiochile.cl", "uploads", "wp")

palabras <- noticias |> 
  unnest_tokens(output = "palabras",
                input = cuerpo) |> 
  filter(!palabras %in% stopwords::stopwords("es"),
         !palabras %in% eliminar)

palabras |> 
  filter(palabras  == "jara") |> 
  distinct(titulo)

palabras |> 
  filter(palabras  == "kast") |> 
  distinct(titulo)

