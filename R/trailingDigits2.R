trailingDigits2 <- function(client, howmany, digit) {
  paste0(client, 
         vapply(howmany,
                FUN = function(x) {
                  paste0(rep.int(digit, times = x), collapse = "")
                },
                FUN.VALUE = character(1)
         ))
  
}
