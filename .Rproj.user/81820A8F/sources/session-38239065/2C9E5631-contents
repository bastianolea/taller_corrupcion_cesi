library(tidytext)
library(stringr)
library(tidyr)
library(arrow)
library(dplyr)

prensa <- read_parquet("datos/prensa_corrupcion.parquet")

# filtrar ----
conceptos <- c("cohecho",
               "corrupción",
               "fraude al fisco",
               "soborno",
               "horas extra",
               "malversación",
               "delitos tributarios",
               "falsificación de instrumento",
               "tráfico de influencias",
               "negociación incompatible",
               "administración desleal",
               "estafa"
)



prensa_corrupcion <- prensa |> 
  mutate(tema = str_detect(cuerpo_limpio,
                           paste(conceptos, collapse = "|")))


prensa_corrupcion |> 
  filter(tema) |> 
  slice_sample(n = 10) |> 
  select(titulo)

library(ggplot2)

prensa_corrupcion |> 
  count(fecha, tema) |> 
  ggplot() +
  aes(fecha, n, color = tema) +
  geom_line()

prensa_corrupcion |> 
  mutate(fecha = lubridate::floor_date(fecha, unit = "month")) |> 
  count(fecha, tema) |> 
  ggplot() +
  aes(fecha, n, color = tema) +
  geom_line()




# contar palabras ----
prensa_corrupcion |> 
  filter(tema)


palabras <- prensa_corrupcion |> 
  filter(tema) |> 
  unnest_tokens(output = "palabra",
                input = cuerpo_limpio) |> 
  filter(!palabra %in% stopwords::stopwords("es"))

palabras

palabras |> 
  filter(palabra  == "fraude") |> 
  distinct(titulo)

palabras |> 
  filter(palabra  == "fundación") |> 
  distinct(titulo)

palabras |> 
  filter(palabra  == "hermosilla") |> 
  distinct(titulo)

# contar por fuente
palabras |> 
  filter(palabra  == "hermosilla") |> 
  distinct(titulo, .keep_all = TRUE) |> 
  count(fuente, sort = TRUE)

# gráfico de términos ----
palabras |> 
  filter(palabra  == "hermosilla") |> 
  distinct(titulo, .keep_all = TRUE) |> 
  ggplot() +
  aes(fecha) +
  geom_density() +
  scale_x_date(date_breaks = "3 months",
               date_labels = "%m/%Y")

palabras |> 
  filter(palabra %in% c("hermosilla", "godoy", "jadue", "hassler", "barriga")) |> 
  distinct(titulo, .keep_all = TRUE) |> 
  ggplot() +
  aes(fecha, fill = palabra, color = palabra) +
  geom_density(alpha = 0.3) +
  scale_x_date(date_breaks = "3 months",
               date_labels = "%m/%Y")


# nubes de palabras ----
library(ggwordcloud)

palabras_conteo <- palabras |> 
  count(palabra, sort = TRUE) |> 
  mutate(p = n/sum(n))

palabras_conteo |> 
  filter(p > 0.001) |> 
  # crear variable que destaque palabras específicas
  mutate(clave = ifelse(palabra %in% c("hermosilla", "sauer", "jadue", "topelberg",
                                       "barriga", "hassler", "villalobos"),
                        "clave", "otras")) |>
  ggplot() +
  aes(label = palabra, size = n, 
      # mapear transparencia a la variable con palabras clave
      alpha = clave) +
  geom_text_wordcloud(shape = "circle",
                      color = "#543A74",
                      rm_outside = TRUE) +
  # especificar rango de tamaños
  scale_size_continuous(range = c(2, 8)) +
  # especificar nivel de transparencia de las palabras clave y de las demás
  scale_alpha_manual(values = c("clave" = 1, "otras" = 0.6))


## por fuente ----


palabras_fuente_conteo <- palabras |> 
  group_by(fuente) |> 
  count(palabra, sort = TRUE) |> 
  mutate(p = n/sum(n))

palabras_fuente_conteo |> 
  filter(fuente %in% c("24horas", "biobio", "cooperativa", "ciper")) |> 
  filter(p > 0.002) |> 
  # crear variable que destaque palabras específicas
  mutate(clave = ifelse(palabra %in% c("hermosilla", "sauer", "jadue", "topelberg", "jalaff",
                                       "barriga", "hassler", "villalobos", "chadwick", 
                                       "guerra", "vivanco"),
                        "clave", "otras")) |>
  ggplot() +
  aes(label = palabra, size = p, 
      # mapear transparencia a la variable con palabras clave
      alpha = clave) +
  geom_text_wordcloud(shape = "circle",
                      color = "#543A74",
                      rm_outside = TRUE) +
  # especificar rango de tamaños
  scale_size_continuous(range = c(2, 8)) +
  scale_alpha_manual(values = c("clave" = 1, "otras" = 0.6)) +
  facet_wrap(~fuente) +
  theme_minimal()



# correlación ----
library(widyr)

## por noticia ----
palabras_noticia_conteo <- palabras |> 
  group_by(titulo) |> 
  count(palabra, sort = T) |> 
  filter(n > 3)

correlacion_noticias <- palabras_noticia_conteo |> 
  ungroup() |> 
  pairwise_cor(palabra, titulo, n)  |> 
  filter(!is.na(correlation))

correlacion_noticias |> 
  filter(abs(correlation) > 0.3)

correlacion_noticias |> 
  filter(item1 == "hermosilla") |> 
  filter(abs(correlation) > 0.2)

correlacion_noticias |> 
  filter(item1 == "barriga") |> 
  filter(abs(correlation) > 0.1)


## por fuente ----

# correlación por fuentes
prensa_corrupcion |> distinct(fuente)

fuentes <- c("24horas", 
             "biobio", 
             "cooperativa", 
             "ciper",
             "cnnchile",
             "meganoticias",
             "t13")

library(purrr)

correlacion_fuente <- map(fuentes, 
                          \(.fuente) {
                            message("correlación ", .fuente)
                            
                            palabras |> 
                              filter(fuente == .fuente) |> 
                              group_by(titulo) |> 
                              count(palabra, sort = T) |> 
                              filter(n > 3) |> 
                              pairwise_cor(palabra, titulo, n) |> 
                              filter(!is.na(correlation)) |> 
                              mutate(fuente = .fuente) |> 
                              filter(abs(correlation) > 0.2)
                          })

correlacion_fuente |> 
  list_rbind() |> 
  filter(item1 == "barriga") |> 
  filter(abs(correlation) > 0.2) |> 
  group_by(fuente) |> 
  slice_max(abs(correlation), n = 3) |> 
  print(n = Inf)
