# :book: Make a web book 

> The `bookdown` package is great for a wiki-type documentation of a long term project.
>
> You can include narrative next to images and charts and your analysis code.

#### Resources

- User guide: https://bookdown.org/yihui/bookdown/
- Book example: https://github.com/rstudio/bookdown-demo
- MPCA's air example: https://mpca-air.github.io/air-methods/  
- R textbook: https://r4ds.had.co.nz/


More on writing in R Markdown: [Data Reports with R](https://swcarpentry.github.io/r-novice-gapminder/15-knitr-markdown/index.html)


<br>

## First steps

We're kicking off with a 3-page book. 

1. Open R
    - Try https://rstudio.cloud if you have telework troubles
1. Create a new R project
    - File > New project... > Name it "my_book"
1. Install the R package `bookdown`

```r
install.packages("bookdown")
```

4. Create a new R file _(This will be your book's title or Home page)_
4. Paste this starter code into the file:

```r
---
title: "A Book"
author: "My name"
site: bookdown::bookdown_site
documentclass: book
output:
  bookdown::gitbook
  #bookdown::pdf_book: default
---
  
# Hello
  
Hi.

Bye.

```

6. Save the file as `index.Rmd` _(The Rmd extension stands for R markdown)_
7. Fix any spacing changes that occurred 
    - `title: ` and `# Hello` should start all the way to the left
8. Add an image by placing the following after the `# Hello` header
    - `![](link-to-my-image.png)`
    
This would show an image of a blue fish I had in my folder:   
`![](blue-fish.png)`  
![](https://i.pinimg.com/236x/09/3f/01/093f01c6016cf56b08598bb78604faf0--fish-template-santa-fe.jpg)

<br>

### New page!

1. Click `New File > R Markdown...`
1. Leave the default options and click `OK`
1. Delete the top header information starting and ending with the 3 ticks: `---`
1. Drop one of the `#` signs in front of "## R Markdown" to create a level 1 header
1. Save the file as `02-page_2` or `02-my_section_name`
1. Preview the page
    - Click the `Knit` button at the top left
    - It's under the .Rmd file tabs and has a __yarn__ icon

### Last page

1. Repeat the first 4 steps above to create a new page
1. Save the file as `03-page_3` or `03-my_section_name`
1. Preview the page _(click the `knit` button)_

### Build your book

1. Restart your R session
1. Open your book project
1. Click the `Build` tab in the top-right of RStudio's _Environment_ pane, near the `History` and `Connections` tabs
1. Click `Build Book`

<br>

## Bonus options 

### 1. Download as PDF

![](https://bookdown.org/yihui/bookdown/images/gitbook.png)

1. Create a new R file
1. Save it as `_output.yml`
1. Paste these configuration options into it:

```r
bookdown::gitbook:
  config:
    download: ["pdf", "epub"]
 
```
4. Save the file and re-build your book.

### 2. :warning: Stop the merged file warnings

> Tired of the warning to delete the merged file when _knitr_ runs into a mistake?  

Let's create one last options file named `_bookdown.yml` to tell R do this step for us.

1. Create a new R file
1. Save it as `_bookdown.yml`
1. Paste in these configuration options and save

```yml
book_filename: bookdown
delete_merged_file: true

```

### Happy booking! :pencil2: :tada:

