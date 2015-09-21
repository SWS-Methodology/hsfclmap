library(dplyr, warn.conflicts = F)
library(stringr)
library(hsfclmap)
data("hsfclmap2")

hsfclmap <- hsfclmap2 %>%
  filter(mdbyear == 2011)



## lengthes of codes don't match

hsfclmap <- hsfclmap %>%
  mutate_(notequal = ~str_length(fromcode) != str_length(tocode))


hsfclmap <- hsfclmap %>%
  mutate_each_(funs(as.numeric),
               lazyeval::interp(~ends_with("code"))) %>%
  mutate_(codediff = ~tocode - fromcode)

# Difference between codes

## TO less than FROM
hsfclmap <- hsfclmap %>%
  mutate_(tolessfrom = ~tocode < fromcode)


## TO bigger than lead FROM
hsfclmap <- hsfclmap %>%
  mutate_(tomoreleadfrom = ~tocode > lead(fromcode))

## Too big difference between TO and LESS

## Length of HS codes

# hsfclmap <- hsfclmap %>%
#   mutate_(
