#' Adds zeros to the end of hs column to make both lolumns of equal length
#'
#'

trailingDigits <- function(from, to, digit) {

  from_len <- stringr::str_length(from)
  to_len   <- stringr::str_length(to)

  to <- ifelse(from_len > to_len,
                 paste0(to,
                        vapply(from_len - to_len,
                               FUN = function(x) {
                                 paste0(rep.int(digit, times = x), collapse = "")
                               },
                               FUN.VALUE = character(1)
                        )
                 ),
                 to
  )

  to
}
