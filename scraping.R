library(rvest)
library(dplyr)

# scraping de enlaces a noticias
sitio <- "https://www.biobiochile.cl/lista/categorias/nacional" |>
  read_html()

titulos <- sitio |>
  html_elements(".article-text-container")

titulos |> html_text2()

enlaces <- titulos  |> 
  html_element("a") |>
  html_attr("href")

enlaces

# scraping de una noticia
enlace <- enlaces[1]

pagina <- enlace |> 
  read_html()

# título
titulo <- pagina |> 
  html_element(".post-title") |> 
  html_text2()

# fecha
pagina |> 
  html_elements(".post-date") |> 
  html_text2()

fecha <- enlace |> 
  stringr::str_extract("\\d{4}/\\d{2}/\\d{2}") |> 
  lubridate::as_date()

# cuerpo
cuerpo <- pagina |> 
  html_elements(".container-redes-contenido") |> 
  html_text2() |> 
  paste(collapse = "\n")


noticia <- tibble(titulo,
       fecha,
       cuerpo)

enlaces2 <- enlaces[!is.na(enlaces)]


# scraping de múltiples noticias
library(purrr)

noticias <- map(enlaces2, \(enlace) {
  
  message(enlace)
  
  pagina <- enlace |> 
    read_html()
  
  # título
  titulo <- pagina |> 
    html_element(".post-title") |> 
    html_text2()
  
  # fecha
  pagina |> 
    html_elements(".post-date") |> 
    html_text2()
  
  fecha <- enlace |> 
    stringr::str_extract("\\d{4}/\\d{2}/\\d{2}") |> 
    lubridate::as_date()
  
  # cuerpo
  cuerpo <- pagina |> 
    html_elements(".container-redes-contenido") |> 
    html_text2() |> 
    paste(collapse = "\n")
  
  
  noticia <- tibble(titulo,
                    fecha,
                    cuerpo,
                    enlace)
})

noticias2 <- noticias |> 
  list_rbind() |> 
  filter(!is.na(titulo))

noticias2

# guardar
write.csv2(noticias2, "datos/noticias.csv")
