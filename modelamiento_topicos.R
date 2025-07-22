library(tidytext)
library(stringr)
library(tidyr)
library(readr)
library(dplyr)

prensa <- read_csv2("datos/prensa_datos_muestra.csv")

palabras <- prensa %>%
  slice(1:2000) |> 
  unnest_tokens(palabra, cuerpo, )

eliminar <- c("2025", "lee", "julio", "si", "tras", "dos", "martes", "content", "https", "lunes", "media.biobiochile.cl", "uploads", "wp",
              "c", "right", "top", "exante's", "ad", "server", "banner", "si", "dos", "us", "100", "00", "2024", 1:99)

conteo <- palabras %>%
  filter(!palabra %in% stopwords::stopwords("es")) |> 
  filter(!palabra %in% eliminar) |> 
  count(titulo, palabra, sort = TRUE)

noticias_dtm <- conteo %>%
  cast_dtm(titulo, palabra, n)

noticias_dtm

library(topicmodels)

noticias_lda <- LDA(noticias_dtm, k = 18, control = list(seed = 1234))

noticias_lda

noticias_lda_td <- tidy(noticias_lda)


top_terminos <- noticias_lda_td %>%
  group_by(topic) %>%
  slice_max(beta, n = 15) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terminos |> 
  select(-beta) |> 
  group_by(topic) |> 
  mutate(id = 1:n()) |> 
  pivot_wider(names_from = topic, values_from = term) |> 
  select(-id)


noticias_gamma <- tidy(noticias_lda, matrix = "gamma")

noticias_topicos <- noticias_gamma |> 
  group_by(document) |> 
  slice_max(gamma)





prensa_topicos <- prensa %>%
  slice(1:2000) |> 
  left_join(noticias_topicos, by = c("titulo"="document"))

prensa_topicos
