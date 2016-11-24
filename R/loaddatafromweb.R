#' Loads table for conversion of Geonom to FAO area list.
#' 
#' @return geonom2fao R-object stored in faoswsTrade package.
#' 
#' @details The function created to avoid working with local files. 
#' It downloads the object from GitHub repository.
#' @export
#' 
loaddatafromweb <- function(url) {
  
  file2save <- tempfile(fileext = ".RData")
  
  download.file(
    url,
    destfile = file2save,
    quiet = TRUE)
  
  load(file2save, envir = environment())
  
  file.remove(file2save)
  rm(list = c("file2save", "url"))
  
  stopifnot(length(ls()) == 1L)
  
  eval(parse(text = ls()))
}
