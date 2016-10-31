#' Looks for corresponding FCL codes in country-specific
#' mapping tables from MDB files
#'
#' @import dplyr
#' @export


hsInRange <- function(hs, areacode, flowname, mapdataset,
                      parallel = FALSE) {
  
  if(!all.equal(length(hs), 
                length(areacode), 
                length(flowname)))
    stop("Vectors of different length")
  
  df <- data_frame(hs = hs,
                   areacode = areacode,
                   flowname = flowname) %>% 
    mutate(id = row_number())
  
  df_fcl <- plyr::ddply(
    df,
    .variables = c("areacode", "flowname"),
    .fun = function(subdf) {
      
      # Subsetting mapping file
      mapdataset <- mapdataset %>%
        filter_(~area == subdf$areacode[1],
                ~flow == subdf$flowname[1])

      # If no corresponding records in map return empty df
      if(nrow(mapdataset) == 0) 
        return(data_frame(
          id = subdf$id,
          hs = subdf$hs,                                                
          fcl = as.integer(NA)))
      
      aligned <- alignHSLength(subdf$hs, mapdataset)
      
      subdf$hs <- aligned$hs
      mapdataset <- aligned$mapdataset
      
      fcl <- plyr::ldply(
        subdf$id,
        function(currentid) {
          
          hs <- subdf %>% 
            filter_(~id == currentid) %>% 
            select_(~hs) %>% 
            unlist() %>% unname()
          
          mapdataset <- mapdataset %>%
            filter_(~fromcode <= hs &
                      tocode >= hs)
          
          # If no corresponding HS range is available return empty integer
          if(nrow(mapdataset) == 0) fcl <- as.integer(NA)
          if(nrow(mapdataset) > 0) fcl <-  mapdataset %>%
            select_(~fcl) %>%
            unlist() %>% unname()
          
          data_frame(id = currentid, 
                     hs = hs,
                     fcl = fcl
                     )
                     
        }
      ) 
      
    },
    .parallel = parallel, 
    .progress = ifelse(interactive() & !parallel, "text", "none")
  )
  
  df <- df %>%
    rename_(hsorig = ~hs) %>% 
    left_join(df_fcl,
              by = c("id", "areacode", "flowname")) %>% 
    select_(~id, 
            area = ~areacode, 
            flow = ~flowname,
            ~hsorig,
            hsext = ~hs,
            ~fcl)

  
  df
  
}
