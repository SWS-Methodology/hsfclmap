library(dplyr, warn.conflicts = F)
library(hsfclmap)
data("hsfclmap2")

hsfclmap <- hsfclmap2 %>%
  filter(mdbyear == 2011)

hsfclmap <- hsfclmap %>%
  mutate_each_(funs(as.numeric),
               lazyeval::interp(~ends_with("code"))) %>%
  mutate_(codediff = ~tocode - fromcode,
          codediffprop = ~codediff / tocode)

# Difference between codes

## TO less than FROM
hsfclmap <- hsfclmap %>%
  mutate_(tolessfrom = ~tocode < fromcode)

hsfclmap %>%
  filter(tolessfrom)

## TO less than lead FROM

## Too big difference between TO and LESS
