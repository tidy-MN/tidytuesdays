
```r
library(tidyverse)
#---------------------------------------------------------------------------------------------------------------
# This function takes in a data frame and creates 2 new dataframe
# The new data frames are returned as a list
#---------------------------------------------------------------------------------------------------------------
get_new = function(a){
  b = a %>% mutate(b = x*2)
  bb = a %>% mutate(bb = x*3)
  bb = rbind(bb, bb)
  
  ret_list = list(b, bb)
  return(ret_list)
  
}
#---------------------------------------------------------------------------------------------------------------

# Create a data frame
a = data.frame(x = c(1,2), y = c("a","b"), day = c(as.Date(c("20020202", "20020302"), format= '%Y%m%d')))

# Call function to create 2 data frames
newb =  get_new(a)

# Assign values from list to data frames. 
newb2 = as.data.frame(newb[1])
newb3 = as.data.frame(newb[2])
#---------------------------------------------------------------------------------------------------------------

```
