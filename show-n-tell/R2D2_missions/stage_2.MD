# Stage 2 \| AT-AT Radio Frequencies

</br>

<img src="https://insidethemagic-119e2.kxcdn.com/wp-content/uploads/2017/11/star_wars_at-at_desktop_2560x1024_hd-wallpaper-971426-800x400.jpg" width="55%" align="right" style="margin-left: 32px; margin-right: -105px; margin-top: 46px; margin-bottom: 77px;"/>

> Thanks to your quick thinking Luke returned safely to the base without being eaten by Wampas. Unfortunately, there was no time to rest. The Empire discovered the location of our base this morning and are already starting to march some BIG machinery our way. The AT-AT walkers stand taller than seven Chewbaccas and are nearly indestructible. Our only chance is to isolate them.
>
> The problem is their smaller walkers and vehicles are preventing us from getting in close. We are going to need to put some distance between the big AT-ATs and their more nimble friends. Our plan is for R2D2 to use the base's radio tower to jam the AT-AT communications and send them in separate directions. Hopefully that will buy us enough time to take a few of them down. But for any of this to work, we need to find the radio frequencies they are using to coordinate their movements. 
> 
> It's a long-shot, but we're running out of options. Will you help?

<br>

## Your Mission

-   Find the radio frequencies R2D2 can use to interfere with the AT-AT communications.


### Setup

-   In RStudio, create a new **Project** called `stage2` or `AT-AT`.
-   Create a new R script.

### Required packages

> ``` go
> library(readr)
> library(dplyr)
> library(tidyr)
> ```

### Instructions

1.  Use `read_csv()` to read the radio data:

    -   <https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/R2D2_missions/stage_2_data/ATAT_radio_7162.csv>


<br>

2.  Click the name of your dataframe in the top right to View the table.

    -   Woah! That's lots of columns. We're going to want to scale this down a bit.

<br>

3.  Let's start by organizing the order of our columns with the function `select()`. Put the `date` column first, and then use the helper function `everything()` to include the rest of the columns after date.

    -  HINT: You don't need quotes around your column name. It will look something like this:

> ``` go
> new_data <- select(your_data, _______, everything())
> ```

<br>

4. Good work! Now we won't need the `planet` column for this task, so let's add another `select()` statement to your script. This time put a minus sign in front of `planet` to drop the column. 

    -   HINT: You won't need to use `everything()` when dropping columns. R will assume you want to keep the remaining columns if you use a minus sign in the select function.
    
> ``` go
> new_data <- select(new_data, - __________ ) 
> ```    
    
<br>

5.  Use `arrange()` to order your data by the `date` column. This should put the oldest data on top.

    -   HINT: It will look something like this:

> ``` python
> new_data <- arrange(new_data, _______)
> ```

<br>

6. Try adding the helper function `desc( _____ )` around the column name `date`, and then re-run the code. What happens to the order of the date column?


<br>

7.  Now we only want to keep the columns labeled as **"AT-AT-"** to hone in on the frequencies for the larger machines.

    -   Use `select()` and `contains()` to select the `date` column first, and then only those columns that contains the text `"AT-AT-"` .

    -   As a refresher, we'd write the following if we only wanted columns that contains the text "ppm":

> ``` python
> new_data <- select(new_data, date, contains("ppm"))
> ```

<br>

8. You should be down to about 11 columns now. That is good because we are desperately running out of time. **Let's see which frequencies are used most often.**

    - This is a preview of two functions we will cover later in your training. Update the code below with your data name to use the `pivot_longer()` and `count()` functions to show how often each radio frequency appears in the data.
    
    - **`CODE  `**  This is the example code if your data were named `new_data`:
    
> ``` .go
> data_count <- pivot_longer(new_data, -date) %>%
>               count(value, sort = TRUE)   
> ```
>     

<br>

9. What did you find? Note the 2 frequencies that occurred the most often as comments at the end of your script file.

    -   `#1. x??? `
    -   `#2. x??? `

<br>

**Final step**   
Clap out loud 5X :clap::clap::clap::clap::clap:. You deserve it! 

<br>

## Save & Submit

Please send us your script and recommendation for the two frequencies to use to disrupt the AT-AT communications. If you don't hear back from us, you can assume we've been turned into star dust.

<br>

Thank you friend,
>
> *-the Alliance*
