# Stage 1 |  A Wampa Rumpus

<img src="https://i.ebayimg.com/images/g/gcQAAOSwkylfAyto/s-l1600.jpg" width="35%" align="right">

<br><br>

> It happened again. Foolhardy Luke has gotten himself into a pickle all by himself. This time he's stuck in a wampa cave and hanging upside down no less. And we were so looking forward to taking a nice nap while recharging our batteries. That will have to wait. 
>
> Lucky for Luke, I did just bump into a researcher at the cantina recently. They weren't happy about spilling their peas, but were pleased I agreed to help with their study. She mentioned she had been observing the movement patterns of wampas in the area. I think if we do a little data digging we could find an optimum time to rescue Luke. And if we're wrong, well, we won't be the one sneaking into the cave to find out. 
> That's Han's job. 

<br>

## Your Mission

- What hour of the day is the Wampa most likely to be absent from their cave?


### Required packages

```r
library(readr)
library(dplyr)
```

### Setup

- In RStudio, create a new project called `wampa`.

### Instructions

0. Download the 2 Excel files from [Wampa data](https://github.com/MPCA-data/tidytuesdays/tree/master/show-n-tell/R2D2_missions/stage_1_data)
    - Click the file name.
    - Click the `[ Download ]` button near the lower right-hand side.
    - Save directly to or move the files to a folder named `data` in your project folder.
1. Open each Excel file and save it as a.CSV file *(later on we'll learn how to read data directly from Excel & other data sources)*
    - <img src="https://cdn4syt-solveyourtech.netdna-ssl.com/wp-content/uploads/2016/03/excel-2013-save-as-csv-4.jpg" width="50%" >
    - Save the 2 CSV files to your project's `data` folder.
    - Keep clicking `Yes` if Excel trys to warn you about...losing formatting...yada-yada...
2. Read each of the CSV files into R using `read_csv()`
3. Use `bind_rows()` to combine the 2 data sets into a single table:
    - `all_data <- bind_rows(week1, week2)`
    - *This will be your super "ALL the data" table*
4. Use `summary()` to find the hour of day with the highest amount of **"time_spent_out_hunting"**. 
    - Hopefully Luke was caught by a very predictable wampa. 

<br>

**Final step:** Clap 5 times.  :clap::clap::clap::clap::clap: Out loud. For real. We are watching.

<br>

## Save and share
Send us your script and your best recommendation for the time of Luke's rescue mission. Han Solo will really appreciate it. We'll let you know how it goes. 

<br>

> ❤ 
> *-the Alliance*
