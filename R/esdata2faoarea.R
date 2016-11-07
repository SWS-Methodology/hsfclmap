#' Converts column `reporter` from Geonom codes to FAO area list codes.
#' 
#' @param data Data frame with Eurostat trade data, containing 
#'   column called `reporter`.
#' @param g2fmap Geonom to FAO area list mapping table: data frame 
#'   containing columns geonom and fao.
#'   
#' @return Data frame, similar to the original `data`, but 
#'   codes in `reporter` column converted.
#' @import dplyr
#' @export

esdata2faoarea <- function(data, g2fmap) {
  
  data %>% 
    left_join(g2fmap %>% 
                select_(geonom = ~code,
                        fao    = ~active), 
              by = c("reporter" = "geonom")) %>% 
    select_(~-reporter) %>% 
    rename_(reporter = ~fao)
  
}
