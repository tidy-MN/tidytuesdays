# Swirl Setup


## 1. Open RStudio and install `swirl`:

```r
install.packages("swirl")

library(swirl)
```

## 2. Download the collection of swirl courses from: https://github.com/swirldev/swirl_courses/archive/master.zip


## 3. Load a course into R:

```r    
install_course_zip("swirl_courses-master.zip", 
                   multi = TRUE, 
                   which_course="Getting and Cleaning Data")


# The easy method isn't working right now. Sad face.
## > install_course("Getting and Cleaning Data")
```

## 4. :penguin: Run swirl in the RStudio Console:

```r  
swirl()
```
