#' Loads table for conversion of Geonom to FAO area list.
#' 
#' @return geonom2fao R-object stored in faoswsTrade package.
#' 
#' @details The function created to avoid working with local files. 
#' It downloads the object from GitHub repository.
#' @export
#' 
loadgeonom <- function() {
  
  file2save <- tempfile(fileext = ".RData")
  
  download.file(
    "https://github.com/SWS-Methodology/faoswsTrade/blob/master/data/geonom2fao.RData?raw=true", 
    destfile = file2save,
    quiet = TRUE)
  
  load(file2save, envir = environment())
  
  file.remove(file2save)
  
  geonom2fao
}
