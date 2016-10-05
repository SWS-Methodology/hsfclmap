# Getting of specific files from MDB folders to reduce transfer size

directory <- file.path("C:", "users", "alexa", "Documents", "Countries")
target_dir <- file.path("C:", "users", "alexa", "Documents", "Countries_copy")



areas_years <- data.frame(dirnames = dir(directory, full.names = F), stringsAsFactors = F) %>%
  filter(str_detect(dirnames, "^[A-Z]{3}_[1-2][0-9]{3}$")) %>%
  mutate(area = str_extract(dirnames, "^[A-Z]{3}"),
         year = as.integer(str_extract(dirnames, "[1-2][0-9]{3}$"))) 


copyresults <- vapply(areas_years$dirnames, function(x) {
  countrydir <- file.path(target_dir, x)
  mdbname <- paste0(x, ".mdb")
  dir.create(countrydir)
  
  file.copy(file.path(directory, x, mdbname), file.path(countrydir, mdbname))
 
}, logical(1L))


list.files(full.names = TRUE, recursive = TRUE, include.dirs = TRUE)