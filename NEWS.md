# hsfclmap 0.2.0.9000

* `hsfclmap2` dataset is updated and now includes all available 
  mapping tables starting from the earliest year (1992).
* `read_from_mdb.R` script updated:

    * It can read MDB files on Windows with RODBC package (R 32 bits has to
      be used).
    * Anonymous function for extracting of mapping records got a name.
    * Some workarounds added to deal with problematic records.
  
# hsfclmap 0.1.0

Initial release. It includes records starting from 2009.
