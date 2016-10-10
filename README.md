# hsfclmap
The package contains country-specific HS->FCL map and adjustments (aka Notes) extracted from Jellyfish MDB files

## data-raw folder

* [Trade_Country-Registry.xlsx](hsfclmap/data-raw/Trade_Country-Registry.xlsx). Original Excel table from Onno with correspondence map of country codes in MDB files and FAO Area List.
* [read_from_mdb.R](hsfclmap/data-raw/read_from_mdb.R). Main script for importing HS->FCL mapping records from Jellyfish MDB files to R data frame.
* [notes_from_mdb.R](hsfclmap/data-raw/notes_from_mdb.R). Script for importing adjustments (aka Notes) from MDB files. Contains a batch of tests to check adjustments logic.
* [copy_mdb_files.R](hsfclmap/data-raw/copy_mdb_files.R). Script for copying of required only MDB files from the original folder with many copies and duplicates. 