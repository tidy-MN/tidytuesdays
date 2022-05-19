Loon survey 2021
================

![](https://abcbirds.org/wp-content/uploads/2020/03/common-loon-for-blog.jpg)

<br>

## lubridate
### *Working with dates and times*

For easier date and time processing we'll be using the `lubridate` package. 

![](https://github.com/rstudio/hex-stickers/raw/master/thumbs/lubridate.png)

**View the big cheatsheet [HERE](https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf)**. 

It's a great reference when you are trying to manipulate dates or timezones in your data.

<br>


### **Objective**
> 
> The DNR has invited you to help organize a statewide loon
> survey next season. 
> 
> In 2021, they would like to perform a loon count once a week from May to
> October at three sites across Minnesota. 

<br>

Let's generate the full list of dates during this time span using the sequence date function: ` seq.Date()`

<br>

Run the code below to create a date for every possible day of the survey.

``` r
library(tidyverse)  #lubridate is included in the great tidyverse
library(lubridate)

start_date <- ymd("2021-05-01")

end_date   <- ymd("2021-10-31")

survey_window <- seq.Date(from = start_date, to = end_date, by = "day") # Sequence from start to end by 1 day
```

<br>

## :penguin: How many days will the survey run?

<br>

<details>
<summary>Show answer</summary>
  
> *184 days*

</details>

<br>

## 1. Scheduling weekdays

![](https://cdn.iconscout.com/icon/free/png-128/calendar-1562-518053.png)

There will be 3 survey locations: Bemidji, Minneapolis, and Ely. 
You are in charge of creating a schedule for each location. Here is the
one weekday when the volunteers are available at each location:

- Bemidji: ` Tuesdays`
- Minneapolis: ` Fridays`
- Ely: ` Thursdays`

<br>

Use the `seq.Date()` function and the option to step by 1 "week" to
generate the survey dates for each site. You can use a new
`seq.Date()` function for each site.

<br>

To get you started, the first Tuesday in May of 2021 is `'2021-05-04'`.

``` r
first_tuesday <- ymd('2021-05-04')  # StarWars day

bemidji_tuesdays <- seq.Date(...)
```

<br>

**How many survey dates are at each site?**

<br>

> *Hint: It is more than 20.*

<br>

<details>
<summary>Show answer</summary>
  
> *26 survey days*

</details>

<br>


## 2. Particular date formats

<img align="left" src="../../images/dwight.png" style="margin-right: 14px;">

<br>

Unfortunately, each survey region has a very particular Assistant to the Regional Manager that demands a very specific date format for their work schedules. 


Before you send off the schedules you'll need to adjust the dates to match the requested specifications below. 

<br><br>

The regions have the following preferred date formats:

- Bemidji: ` May-12-2021`
- Minneapolis: ` 06.24.21`  
- Ely: ` August 14, 2021`

<br>

Use `format(date, ...)` and the format expressions below to format the schedule for each region accordingly. 

For example, since `%b` stands for abbreviated month and `%Y%` stands for the full 4 digit year, `format(date, "%b, %Y")` will print the date as `Aug, 2021`. 

**Date**

| Expression    | Description                       | Example  |
| :------------ | :-------------------------------- | :------- |
| `%Y`          | Year (4 digit)                    | 2021     |
| `%y`          | Year (2 digit)                    | 21       |
| `%B`          | Month (full name)                 | December |
| `%b`          | Month (abbreviated)               | Dec      |
| `%m`          | Month (decimal number)            | 12       |
| `%d`          | Day of the month (decimal number) | 30       |


**Time**

| Expression    | Description                       | Example  |
| :------------ | :-------------------------------- | :------- |
| `%H`          | Hour                              | 8        |
| `%M`          | Minute                            | 13       |
| `%S`          | Second                            | 35       |


<br>

> :bulb: **ALTERNATIVE** - Try `stamp()`

<details>
<summary>Show the stamp() method</summary>
 
---

Now that you've got the basics, here's a nice formatting method using the function `stamp()`. 

To use `stamp`, first create a custom stamp by entering a specific example of how you want the dates formatted, and the order of the date elements.

For example, if you want the Ely dates formatted as "June 22nd, 2021", then the order of the date is `Month-Day-Year` or "mdy". 

**So we write:** 

``` r 
ely_stamp <- stamp("June 22, 2021", orders = "mdy")  
```

<br>

Now we can apply our custom stamp to any dates by using it like a function: ` ely_stamp(...) ` 

**For example:**

``` r
ely_stamp(ely_dates) 
```

---

</details>

<br><br>

**Congrats\!**

Your fine-tuned schedule worked perfectly. Now let’s jump ahead and take a look at the
survey results.

<br>


## 3. Results

<br>

**Load the loon data.**

``` r
loons <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/dates/loon_survey_data.csv")   
```
<br>

*Explore a bit. Are there any missing values?*

<br>

### A missing site

It looks like we have a slight missing data problem.

There’s a data point in the results that wasn’t labeled with the site
location. We do know the date however. On `2021-06-11` there were a
whopping 4 loons counted - but we just don’t know where.

<br>

**Can you determine the site based on the date of the loon count?**

``` r
mystery_site_date <- "2021-06-11"
```

> *Hint: What weekday is this?*
>
> Try the `wday(date)` function.

<br>

**Use `ifelse()` to update the missing site name for the survey date `2021-06-11`.**

``` r
loons <- loons %>%
         mutate(site = ifelse(count_date == ...)  
```


<br>


## 4. The best time for loons

<br>

## What is the best month to see loons?

:penguin: **First, add a `month` column to the data.**

``` r
loons <- loons %>%
         mutate(month = ...)
```

<br>

:penguin: **Next, use `group_by()` and `summarize()` to find the month with the most loon sightings across all of the sites.**

``` r
loon_months <- loons %>%
               group_by(...) %>%
               summarize(total_loons = ...)
```

<br><br>

## Best time of day?

The time _(hour:minutes:seconds)_ for the start of each loon count was stored in 
a separate table. Load the survey times and join it to the loon counts with `left_join()`.

> **Join the times to the dates.**

``` r
count_times <- read_csv("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/dates/loon_survey_times.csv")

loons <- left_join(...)
```
<br>

**View one of the specific `time` values with `loons$time[1]`.**

**What do you notice?**

<br>

**You can also check the timezones of an entire time column with `tz()`.**

**Try:**

```r
tz(loons$time) %>% unique() 
```

<br>

Wups! By default, R assigned the times to UTC time. Plus, if we scroll down in the data table we see that most of the times were recorded using local Central time, but a few are in GMT time. We can fix this all up with one use of `force_tz()`.


**Use `force_tz()` to assign all times to the designated time zone in the `time_zone` column.**

``` r
loons <- loons %>%
         rowwise() %>%
         mutate(time_cdt = force_tz(...) )
```

<br>


> All times should now be shown in local CDT time.
>

<br>

**View one of the new time values with:**

```r
loons$time_cdt[1]
```

<br>

> Did the time zone change?

<br><br>

**So, which hour of the day saw the most loons?**

**Add an hour column to the data.** 
``` r
loons <- loons %>%
         mutate(hour = ...)
```

<br>

**Use `group_by()` and `summarize()` to find the hour with the most loons.**

``` r
loons_hour <- loons %>%
              group_by(...) %>%
              summarize(total_loons = ...)
```

<br><br>

# :tada: Great work

You showed some impressive data skills today. We’ll be in touch for *Loon Survey 2022*.


<br><br><br>

<hr><hr>

### Extras 

Use the tiny function `am()` to determine whether it was better to look for loons in the first half or the second half of the day.

