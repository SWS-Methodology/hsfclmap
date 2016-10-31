alignHSLength <- function(hs, mapdataset) {
  
  stopifnot(length(unique(mapdataset$area)) == 1)
  stopifnot(length(unique(mapdataset$flow)) == 1)
  stopifnot(all(stringr::str_detect(hs, "^\\d+$")))
  stopifnot(all(stringr::str_detect(mapdataset$fromcode, "^\\d+$")))
  stopifnot(all(stringr::str_detect(mapdataset$tocode, "^\\d+$")))
  
  maxhslength   <- max(stringr::str_length(hs))
  maxfromlength <- max(stringr::str_length(mapdataset$fromcode))
  maxtolength   <- max(stringr::str_length(mapdataset$tocode))
  maxlength     <- max(maxhslength, maxtolength, maxfromlength)
  
  hs <- as.numeric(stringr::str_pad(
    hs,
    width = maxlength, 
    side  = "right",
    pad   = "0"
  ))
  
  mapdataset$fromcode <- as.numeric(stringr::str_pad(
    mapdataset$fromcode,
    width = maxlength, 
    side  = "right",
    pad   = "0"
  ))
  
  mapdataset$tocode <- as.numeric(stringr::str_pad(
    mapdataset$tocode,
    width = maxlength, 
    side  = "right",
    pad   = "9"
  ))
  
  list(hs = hs,
       mapdataset = mapdataset)
  
}