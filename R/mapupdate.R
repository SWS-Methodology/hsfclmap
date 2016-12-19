#' Adds updates to HS->FCL map
#' 
#' Usually updates contain one HS code instead of HS range. The function duplicates HS column into `fromcode` and `tocode` columns and adds `rownumb` column based on the latest (the maximal) value available in the mapping table.
#' 
#' @import dplyr
#' @export

mapupdate <- function(
  maptable,
  update,
  startyear = NULL,
  endyear = 2050L) {
  
  stopifnot(all(colnames(maptable) %in% 
                  c("area", "flow", "fromcode",
                    "tocode", "fcl", "startyear", 
                    "endyear", "recordnumb")))
  
  stopifnot(all(colnames(update) %in% 
                  c("area", "flow", "fromcode",
                    "fcl")))
  
  if(!"startyear" %in% colnames(update) & is.null(startyear))
    stop("Start year is not provided")
  
  if(!is.null(startyear) & !"startyear" %in% colnames(update))
    update$startyear <- startyear
  
  if(!"endyear" %in% colnames(update))
    update$endyear <- endyear
  
  # tocode
  
  if(!"tocode" %in% colnames(update))
    update$tocode <- update$fromcode
  
  # Check on duplicates
  if(nrow(update) > nrow(distinct(update))) {
    update <- distinct(update) 
    warning("Duplicates in update data set were removed")
  }
  
  # Records numbering
  nextrecordnumb <- max(maptable$recordnumb) + 1L
  
  update$recordnumb <- seq.int(from = nextrecordnumb, 
                               length.out = nrow(update))
  
  bind_rows(maptable, update)
}
