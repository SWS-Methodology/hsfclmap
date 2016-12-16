#' Adds updates to HS->FCL map
#' 
#' Usually updates contain one HS code instead of HS range. The function duplicates HS column into `fromcode` and `tocode` columns and adds `rownumb` column based on the latest (the maximal) value available in the mapping table.
