manualCorrections <- function(map) {
  map$tocode[map$area == "PAL" &
               map$fromcode == "29192" &
               map$tocode   == "19192" &
               map$fcl      == "1293"] <- "29192"


  # In any case it is a duplicate
  map$fromcode[map$area == "CAN" &
                 map$fromcode == "0708900000" &
                 map$tocode   == "0207430000" &
                 map$fcl      == "1075"]  <- "0207430000"

  map$tocode[map$area == "BEL" &
                 map$fromcode == "210609030" &
                 map$tocode   == "21069030" &
                 map$fcl      == "1232"]  <- "210609030"
  map

}
