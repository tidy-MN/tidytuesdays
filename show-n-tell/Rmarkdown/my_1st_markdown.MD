---
title: "My first markdown"
output:
  html_document: default
---


## 1. What is it?

> R Markdown keeps your plots, output, and analysis all in one place. No more outdated charts and data floating around.

> This is an R Markdown document. Markdown is a simple syntax for authoring HTML, PDF, and Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

## 2. A scary movie

> [Changing data: A Reproducible workflow](https://youtu.be/s3JldKoA0zw)

## 3. But why?

-   <https://slides.djnavarro.net/starting-rmarkdown/#17>

<br>

### YAML

The YAML ("YAML ain't markup language" or "Yet another markup language") is the document information stored atop the R Markdown document, bounded on each end by `---`. When you first create a new .Rmd, that will look something like this:

    ---
    title: "Document title"
    author: "Author"
    date: "MM/DD/YYYY"
    output: html_document
    ---

## 4. Demo time

```.r
library(tidyverse)
library(ggweekly) #remotes::install_github("gadenbuie/ggweekly")

start <- "2021-04-05"
end <- as.Date(start) + 8

ggweek_planner(
  start_day = start, 
  end_day = end,
  highlight_days = tibble(day = "2021-04-09", 
                          label = "HOTSPRINGS!!", 
                          color = "hotpink",
                          fill  = "hotpink")
) +
  labs(title = "My Yellowstone Trip")
```

My vacation will be starting on `r start`. Better start packing on `r as.Date(start) - 1` !



### Code chunk options

Chunk options are options designated in the code chunk header that determine what appears or does not appear for each chunk upon knitting (and a lot more, but we'll start there...). For more information on code chunk options in R Markdown, see Chapter 11 in the [R Markdown Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/chunk-options.html).

Chunk hooks can be added to individual code chunk headers (within the `{r}` atop the chunk), or applied globally by adding options to the `{r setup}` code chunk at the top of the document.

Here are some common hooks:

-   `echo = FALSE`: do not show the code in the knitted document
-   `include = FALSE`: do not include code or any outputs in knitted document
-   `message = FALSE`: suppress messages when knit
-   `warning = FALSE`: suppress warnings when knit
-   `eval = FALSE`: do not evaluate this code

## Customization

For today, we'll make changes to the YAML in our .Rmd to fancy our output document. Our customization will be related to our knitted HTML output, using the following:

-   `toc: true`: add a table of contents based on header hierarchies
-   `toc_float: true`: make it a floating TOC
-   `number_sections: true`: add numbered sections based on header hierarchy
-   `theme: _____`: add a bootstrap theme
-   `code_folding: hide`: code is default hidden, but available if the reader clicks on the 'Code' button created

For free bootstrap themes, visit: <https://bootswatch.com/3/>

To add options to the YAML, add them as "children" in the `html_document` subsection. Beware of spacing here: generally add 2 spaces of indentation for each new sublevel in the YAML hierarchy.

    ---
    title: "Level up in R Markdown"
    subtitle: "UCSB QMSS seminar series (February 2021)"
    author: "Allison Horst"
    output: 
      html_document:
        theme: flatly
        toc: true
        toc_float: true
        number_sections: true
        code_folding: hide
    ---

# Resources

-   [The R Markdown Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/) by Yihui Xie, Christophe Dervieux, Emily Riederer
-   [R Markdown: the Definitive Guide](https://bookdown.org/yihui/rmarkdown/) by Yihui Xie, J. J. Allaire, Garrett Grolemund
-   [RStudio's R Markdown site](https://rmarkdown.rstudio.com/)
-   [R Markdown Reference Guide](https://www.rstudio.com/wp-content/uploads/2015/03/rmarkdown-reference.pdf)
-   [RStudio's R Markdown lesson series](https://rmarkdown.rstudio.com/lesson-1.html)
-   Alison Hill's workshop on [Advanced R Markdown](https://alison.rbind.io/project/advanced-r-markdown/)
