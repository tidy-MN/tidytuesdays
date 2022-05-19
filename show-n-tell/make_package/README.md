# :package: Take home your very own package

> It’s crafting time\!

## Why a package?

Packages are the heart of R. They are what give R its versatility,
free-ness, and open sourceness. Making one is probably one of the best
ways to understand them. Trust me, they are simpler than they look. But
why make one?

  - To share code
  - To share data (type `starwars` after loading `library(dplyr)`)
  - To connect to data sources online
  - To share specialized plots, maps, and color themes
  - …

### Package How-to’s

References for today:

  - Mostly Hillary Parker’s [Writing your first :cat: package from
    scratch](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/)
  - Extras from Hadley Wickham’s [R
    Packages](http://r-pkgs.had.co.nz/intro.html)

## Step 0: Pre-reqs

First, get the helpful package `devtools` to make creating packages much
easier.

``` r
install.packages("devtools")

library(devtools)
library(roxygen2)
```

## Step 1: Write a function

Say you have some code:

``` r
# Pet message
favorite_pet <- "doggies"

favorite_pet <- toupper(favorite_pet)

msg <- paste0("The best pets in the whole wide world are ", favorite_pet, "!!! No contest. At all.")

print(msg)
```

    ## [1] "The best pets in the whole wide world are DOGGIES!!! No contest. At all."

To turn it into a function, wrap your code in `function(){` *your code
here* `}` and then assign it a name. Let’s call it `say_msg <-`.

``` r
say_msg <- function() {
  
  # Pet message
  favorite_pet <- "doggies"
  
  favorite_pet <- toupper(favorite_pet)
  
  msg <- paste0("The best pets in the whole wide world are ", favorite_pet, "!!! No contest. At all.")

  print(msg)
  
}
```

## Step 2: Add some flexibility

Where possible, use arguments to let your function adapt to serve many
users and situations. For example, there might exist a person somewhere
far away who doesn’t only love doggies, but also loves puppies. Let’s
make the `favorite_pet` text be an optional argument in our function so
it can take on any text the user wants. We’ll call the argument `my_fave
=`.

``` r
say_msg <- function(my_fave = "puppies") {
  
  # Pet message
  favorite_pet <- my_fave
  
  favorite_pet <- toupper(favorite_pet)
  
  msg <- paste0("The best pets in the whole wide world are ", favorite_pet, "!!! No contest. At all.")

  print(msg)
  
}
```

## Step 3: Create a new package folder

Two options:

1.  If you’re already in the directory where you want your package to
    live, run `create("pets")`
2.  Otherwise, go to `File` \> `New project...` \> `New Directory` \> `R Package`
      - Name your package
      - Browse to the location you want to save your package
      - Leave the remaining defaults for now
3.  Delete the NAMESPACE file from the package folder

## Step 4: Create a file for your function

Save your function script with the name `say_msg.R` into the `R/` folder
of your package. In general, every function in your package will have
its own file. This makes it easier to find a file you need to update,
and to see what is in a package at a glance.

## Step 5: Document your function

People may not know how to use your function the first time. Let’s add
some documentation about what the function does, its arguments, and what
the defaults are. You can even add some examples. This is what will show
up in R in the **Help** window when you type `?your_function`.

Function documentation is written using special comments above your
function. For example:

``` r
#' A Happy Pet Message
#'
#' This function expresses your love of pets.
#' @param my_fave Your favorite animal. Default = "puppies".
#' @keywords pets
#' @export
#' @examples
#' say_msg("little dogs")
#' say_msg()

say_msg <- function(my_fave = "puppies") {
  ...
  ...
```

## Step 5: Run `document()`

Run `document()` in the console.

> If you get an error concerning the NAMESPACE file, delete the
> NAMESPACE file from the package folder. Now re-run `document()`.

Open the `man/` folder. You should see a `.Rd` file now. That's the help window that will appear for people when they type `?say_msg `.

## Step 6: Run `install()`

Run `install()` in the console.

## Step 7: Update the `DESCRIPTION` file

Add a description and your name to the DESCRIPTION file.

## Step 8: Create an overview / help page for your pacakge

In the `R/` folder, create a new script named `pets.R`. Add the
following documentation comments using the same syntax as before for the
function.

``` r
#' Pets: A package for exclaiming your love of pets.
#'
#' The Pets package provides an incredibly important tool 
#' to voice your love of doggies.
#' 
#' @section Pets functions:
#' Pets has one function: say_msg()
#'
#' @docType package
#' @name pets
NULL
```

Run `document()`. Run `install()`.

## :star: Bonus steps

### Share

**GitHub** Add your package to our
[MPCA-data](https://github.com/MPCA-data) github page (or your own).

Others can install and use it.

You can install my “pets” package from github using
`remotes::install_github("MPCA-data/pets")`.

**X-drive**

WHen someone shares their package on the X-drive, you can install it the
same way we’ve been installing our own package. Use
`devtools::install("X:/super long/package location/pets")`.
