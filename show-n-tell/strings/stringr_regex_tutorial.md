stringr and regex tutorial
================
Derek Nagel
11/3/2020

## stringr package

stringr is an R package that is part of the tidyverse. stringr has many
functions for searching and manipulating strings. You can install
stringr using either `install.packages("stringr")` or
`install.packages("tidyverse")`.

## What is regex?

Regex is short for regular expression. Regex is a text string with some
characters having special meanings used to find matches in another
string. Regex is used in many programming languages and software
including R, Python, and Tableau.

## stringr / regex cheat sheet

<https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_strings.pdf>

## Using stringr and regex to get data from email signatures

``` r
#Load tidyverse if installed, otherwise just load stringr
if(!require(tidyverse)) library(stringr)

kristie <- "Kristie Ellickson, PhD (she/her/hers) | Research Scientist
Air Modeling and Risk Evaluation
Environmental Analysis & Outcomes
Minnesota Pollution Control Agency
520 Lafayette Rd  |  St Paul, MN
651-757-2050
kristie.ellickson@state.mn.us"

jennifer <- "Jennifer Hains
Research Scientist | Family Home Visiting Program 
Minnesota Department of Health 
Office: 651-201-5004
Jennifer.Hains@state.mn.us
 
Pronouns: She/Her/Hers"

derek <- "Derek C. Nagel | Research Analyst
Minnesota Pollution Control Agency (MPCA)
520 Lafayette Rd, St Paul, MN 55155
651-757-2518
derek.nagel@state.mn.us

Pronouns: He/Him/His"

staff <- c(kristie = kristie, jennifer = jennifer, derek = derek)

#Search for "Pollution" in staff info
str_view(staff, "Pollution")
```

![](stringr_regex_tutorial_files/figure-gfm/staff_info-1.png)<!-- -->

``` r
#Check which staff work for MPCA using str_detect
staff[str_detect(staff, "Pollution")] %>% names()
```

## [1] "kristie" "derek"

``` r
#Check which staff work for MPCA or MDH with |
staff[str_detect(staff, "Pollution|Health")] %>% names()
```

## [1] "kristie"  "jennifer" "derek"

``` r
#Extract all first names
str_extract(staff, "[:alpha:]+")
```

## [1] "Kristie"  "Jennifer" "Derek"

``` r
#You can also use \\w which will match any letter or number
str_extract(staff, "\\w+")
```

## [1] "Kristie"  "Jennifer" "Derek"

``` r
#[:alpha:] not inclusive of special characters in names such as - and '
str_extract("O'Brian", "[:alpha:]+")
```

## [1] "O"

``` r
#Use [] to include any character in set
str_extract("O'Brian", "[[:alpha:]-']+")
```

## [1] "O'Brian"

``` r
str_extract("O'Brian", "[\\w-']+")
```

## [1] "O'Brian"

``` r
#Find first number
str_view(staff, "[:digit:]+")
```

![](stringr_regex_tutorial_files/figure-gfm/staff_info-2.png)<!-- -->

``` r
#\\d also works
str_view(staff, "\\d+")
```

![](stringr_regex_tutorial_files/figure-gfm/staff_info-3.png)<!-- -->

Note that there are two  in front of the d. This is because  is an
escape character in R and an escape character in regex, so you need two
; one to do the escape in R and one to do the escape in the regex match.
You can use `cat()` to check what R is actually interpreting a string
as.

```r
#Produces error
#cat("\d")

cat("\\d")
```

## \d

``` r
#If you want to match a \, you need to use \\\\. The 1st and 3rd \ do the escaping in R. The 2nd and 4th are for the regex match.

cat("\\\\")
```

## \\

``` r
#Extract phone number
str_view(staff, "\\d+-\\d+-\\d+")
```

![](stringr_regex_tutorial_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

``` r
#This is not very strict. If we have a date mixed in, it will extract the wrong thing.
str_view("11-3-2020 651-757-2518", "\\d+-\\d+-\\d+")
```

![](stringr_regex_tutorial_files/figure-gfm/unnamed-chunk-1-2.png)<!-- -->

``` r
#We can specify exactly how many digits must be present for a valid phone number using {}.
str_view("11-3-2020 651-757-2518", "\\d{3}-\\d{3}-\\d{4}")
```

![](stringr_regex_tutorial_files/figure-gfm/unnamed-chunk-1-3.png)<!-- -->

### Challenge 1:

How can you modify the regex search to find the phone numbers in all of
these strings?

``` r
phone_nums <- paste("My office number is", c("651-757-2518", "651 757 2518", "651.757.2518"))
phone_nums
```

    ## [1] "My office number is 651-757-2518" "My office number is 651 757 2518"
    ## [3] "My office number is 651.757.2518"

### Challenge 2:

Extract the pronouns from each of our info. Hint: To look for any number
of characters between a and b use {a,b}

### Challenge 3:

Extract our email addresses. Hint: Don’t forgot about the dots\!

## str\_replace

So far, we’ve been searching for string matches. We can also do string
replacements with `str_replace()`. Let’s use str\_replace to inflate our
job titles.

``` r
str_replace(staff, "Research \\w+", "Commissioner") %>% cat(sep = "\n\n\n")
```

    ## Kristie Ellickson, PhD (she/her/hers) | Commissioner
    ## Air Modeling and Risk Evaluation
    ## Environmental Analysis & Outcomes
    ## Minnesota Pollution Control Agency
    ## 520 Lafayette Rd  |  St Paul, MN
    ## 651-757-2050
    ## kristie.ellickson@state.mn.us
    ## 
    ## 
    ## Jennifer Hains
    ## Commissioner | Family Home Visiting Program 
    ## Minnesota Department of Health 
    ## Office: 651-201-5004
    ## Jennifer.Hains@state.mn.us
    ##  
    ## Pronouns: She/Her/Hers
    ## 
    ## 
    ## Derek C. Nagel | Commissioner
    ## Minnesota Pollution Control Agency (MPCA)
    ## 520 Lafayette Rd, St Paul, MN 55155
    ## 651-757-2518
    ## derek.nagel@state.mn.us
    ## 
    ## Pronouns: He/Him/His

Okay, that’s an extreme jump. Let’s promote ourselves more gradually.

``` r
job_titles <- c("Research \\w+", "Supervisor", "Manager", "Director", "Assistant Commissioner",
                "Commissioner")

promotions <- staff

str_view(promotions, job_titles[1])
```

![](stringr_regex_tutorial_files/figure-gfm/promotion-1.png)<!-- -->

``` r
for (i in 1:(length(job_titles) - 1)) {
  promotions <- str_replace(promotions, job_titles[i], job_titles[i+1])
  print(str_view(promotions, job_titles[i+1]))
}
```

## Backreferences

We’ve done direct replacements, but what if we want to refer to strings
we matched and move them around? We can use a backreference (backref) to
accomplish this.

``` r
#Match names
str_view(staff, "(\\w+)((?: [\\w.]+)?) (\\w+)")
```

![](stringr_regex_tutorial_files/figure-gfm/backref-1.png)<!-- -->

``` r
#Reorder names
str_replace(staff, "(\\w+)((?: [\\w.]+)?) (\\w+)", "\\3, \\1\\2")
```

    ## [1] "Ellickson, Kristie, PhD (she/her/hers) | Research Scientist\nAir Modeling and Risk Evaluation\nEnvironmental Analysis & Outcomes\nMinnesota Pollution Control Agency\n520 Lafayette Rd  |  St Paul, MN\n651-757-2050\nkristie.ellickson@state.mn.us"
    ## [2] "Hains, Jennifer\nResearch Scientist | Family Home Visiting Program \nMinnesota Department of Health \nOffice: 651-201-5004\nJennifer.Hains@state.mn.us\n \nPronouns: She/Her/Hers"                                                                  
    ## [3] "Nagel, Derek C. | Research Analyst\nMinnesota Pollution Control Agency (MPCA)\n520 Lafayette Rd, St Paul, MN 55155\n651-757-2518\nderek.nagel@state.mn.us\n\nPronouns: He/Him/His"

## What does that all mean?

  - Anything enclosed in `()` is a group. We can “capture” groups and
    then refer to the group in the replacement text.

  - `(\\w+)` means the first group is a word of one or more characters

  - The `?:` in `(?: [\\w.]+)` means we do not want that group to be
    captured. This is because this group is inside the group we actually
    want to capture. `[\\w.]+` matches any combination of one or more
    word characters and/or periods. This allows us to capture both
    middle initials and full middle names.

  - The `?` at the end of `(?: [\\w.]+)?` says to look for zero or more
    matches of the group which is a space followed by one or more word
    characters and/or periods. This means in cases where there are no
    middle names, the match will be a empty string `""`. We wrap that in
    `()` to get `((?: [\\w.]+)?)` because we want to capture then entire
    middle names substring including the space.

  - We require a mandatory space between the first/middle name and the
    last name and then capture the last name with another `(\\w+)`.

  - We want to have the last name (3rd captured group) first followed by
    a comma and space, then the first name (1st captured group), and
    then the middle name (2nd captured group). When we capture the
    middle name, we are also capturing the space, so we don’t want to
    add an extra space between those groups. \\1 refers to the 1st
    captured group, \\2 refers to the 2nd captured group, and so on.
    Putting it all together we get `\\3, \\1\\2` for the replacement.

### Challenge 4:

`str_replace(staff, "(\\w+)((?: [\\w.]+)?) (\\w+)", "\\3, \\1\\2")` will
not work correctly if a name has a hyphen or apostrophe in it. Edit the
code to include those characters.

### Challenge 5:

Convert `"Today is 11/3/2020"` to `"Today is 2020-11-3"` using
str\_replace.

### Challenge 6:

Convert the staff phone numbers from `###-###-####` to `(###) ###-####`
while keep the rest of the strings intact.
