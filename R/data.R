#' HS->FCL country/year specific mapping table.
#' 
#' A dataset containing mapping table from Harmonized System country specific 
#' codes to FAO Commodity List codes.
#'
#' @format A data frame with 5922649 rows and 9 columns
#' \describe{
#'   \item{validyear}{Integer. Year for which the correspondence is valid. NA 
#'   in case the correspondence is not year-specific and valid for all years. 
#'   Probably there are could be conflicts between year-nonspecific 
#'   correspondences from MDB files produced in different years.}
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