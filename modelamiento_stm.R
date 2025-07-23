library(dplyr)
library(purrr)
library(furrr)
library(readr)
library(stm)
library(tidytext)
library(tictoc)

# cargar datos ----
prensa <- read_parquet("datos/prensa_corrupcion.parquet")


# procesamiento de texto necesario para el modelamiento
# en teoría no es necesario de usar, pero te genera los outputs necesarios para la siguiente función
processed <- stm::textProcessor(documents = prensa$cuerpo,
                                metadata = prensa,
                                lowercase = T, removestopwords = T, removepunctuation = T, removenumbers = T, verbose = F,
                                stem = FALSE, 
                                language = "spanish")

# preparar documentos
out <- stm::prepDocuments(processed$documents, processed$vocab, processed$meta,
                          lower.thresh = 5)

# buscar K ----
tic()
findingk_ver2 <- searchK(documents = out$documents,
                         vocab = out$vocab,
                         K = c(17, 18, 19, 20), # probar cantidades de k
                         data = out$meta, 
                         cores = 4,
                         init.type = "Spectral")
toc(); beepr::beep() # 416 segundos

plot(findingk_ver2)
# maximizar coherencia y held-out likelihood, minimizar residuales

# definir k en base a lo anterior
.k = 20


# calcular modelo ----
tic()
modelo_stm <- stm(documents = out$documents, 
                  vocab = out$vocab,
                  K = .k, 
                  max.em.its = 300, 
                  data = out$meta,
                  init.type = "Spectral")
toc() # 191 segundos


# plot(modelo_stm, n = 4)

labelTopics(modelo_stm)

# 2 ~ "economía",
# 3 ~ "delincuencia",
# 4 ~ "gobierno",
# 5 ~ "internacional",
# 6 ~ "parlamento",
# 11 ~ "justicia",
# 12 ~ "social",
# 13 ~ 

# topico 12

# agregar ids de noticias usadas para entrenar
modelo_stm$id <- ids_entrenamiento

# agregar metadatos
modelo_stm$out <- out 

# guardar ----
readr::write_rds(modelo_stm, "datos/modelo_stm.rds")

# out$meta$id
# names(modelo_stm)

