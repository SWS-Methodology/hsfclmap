#' HS->FCL country/year specific mapping table.
#' 
#' A dataset containing mapping table from Harmonized System country specific 
#' codes to FAO Commodity List codes.
#'
#' @format A data frame with 5922649 rows and 9 columns
#' \describe{
#'   \item{validyear}{Integer. "It refers to the first year that the HS6+ code was used by the country in its files" (Carola).}
#'   \item{area}{Integer. FAO area code.}
#'   \item{flow}{Interger. Import/Export}
#'   \item{fromcode}{Character. Starting HS code.}
#'   \item{tocode}{Character. Ending HS code.}
#'   \item{fcl}{Interger. FCL code.}
#'   \item{mdbyear}{Integer. Year for which the original MDB-file was produced.}
#'   \item{mdbarea}{Character. Area name from the original MDB-file.}
#'   \item{mdbfcl}{Character. FCL code from the original MDB-file. It is as 
#'   it was, not converted to integer and can differ from area column.}
#' }
"hsfclmap2"

#' Trade flows adjustments from MDB files
#'
#' @format A data frame
"adjustments"

#' HS->FCL country/year specific mapping table without duplicate links.
#' 
#' A dataset containing mapping table from Harmonized System country specific 
#' codes to FAO Commodity List codes. Also columns for dubugging of MDB-export process excluded.
#'
#' @format A data frame with 885013 rows and 6 columns
#' \describe{
#'   \item{startyear}{Integer. Year starting from which specified link is actual.}
#'   \item{area}{Integer. FAO area code.}
#'   \item{flow}{Interger. Import/Export}
#'   \item{fromcode}{Character. Starting HS code.}
#'   \item{tocode}{Character. Ending HS code.}
#'   \item{fcl}{Interger. FCL code.}
#' }
"hsfclmap3"

#' 6-digit HS codes what are of FAO's interest
#'
#' Taken from `HS2012-6 digits Standard.xls` provided by Claudia and stored in `data-raw` folder of hsfclmap package.
#'   
#' @format A character vector of length 1061
"hs6faointerest"

#' Another variant of HS codes of FAO's interest
#' 
#' Probably this one is better than previous `hs6faointerest` 
#'   as we got it after Carola discovered a mistake in old data set.
#' 
#' @format A data frame with 42 rows and 2 columns
#' \describe{
#'   \item{FromCode}{Numeric. Lower limit of HS range.}
#'   \item{ToCode}{Numeric. Upper limit of HS range.}
#' }
#' 
#' @examples 
#' \dontrun{
#'    ... %>% 
#'    # Subselection of HS6 falling in intervals
#'    # http://stackoverflow.com/a/24766832
#'    filter_(~findInterval(
#'      hs6,
#'      as.vector(do.call(rbind, hs6agri))) %% 2 != 0) %>% 
#'    ...
#' }
"hs6agri"