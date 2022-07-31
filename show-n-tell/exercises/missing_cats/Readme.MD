# Pet Detectives Needed    :detective: :cat2: :cat2: :cat2:

<br>

FYI! 

Our cat shelter **The Meow House** is overflowing with found cats and we're recruiting expert detectives to help these cats find their home. 

<br>

>
> Will you help us? 
> 
> Nevermind, we're putting you on the case anyways. Here's a cat! 
>
 
<br>


### Instructions

1. Get to know your cat's personality traits and determine its age as best you can. 
    - Useful packages: `library(tidyverse)`, `library(lubridate)`
    - Useful functions: `read_csv()`, `today()`, `ymd()`, `duration(10, "years")`
2. Find the earliest possible birthday 🍰 for your cat. Then find the latest possible birthday for your cat. 
4. Consult the BIG missing cat list to help find the cat's worried owner.
*(They will be oh so forever grateful)*
    - Useful functions: `mutate()`, one of the date functions `mdy()` or `dmy()` or `ymd()`, `filter()`


> [**The Meow House cats**]()

> [**The BIG missing cat list**]()


<br><br>


<img src="https://64.media.tumblr.com/23a153de959391e35617efd469312765/e48c703ee3ccbd16-96/s1280x1920/d3fb50b27b32c7f7f5807aad77a74e2a53bbf8f1.png" width="65%">

<br>

<details>
 <summary>  Cat owners answer key  <b><em>(Don't peak!)</em></b> ✔️</summary>
 
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> rowname </th>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> country </th>
   <th style="text-align:left;"> owner_phone </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Julep </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-5851242 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> Chad </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-1714366 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> Kumheer </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-4194980 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Tao </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-8479377 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Libearty </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-7034433 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Winona </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-6403848 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:left;"> Janis </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-6698259 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:left;"> Church </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-6777887 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 9 </td>
   <td style="text-align:left;"> Violet </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> 651-2923168 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10 </td>
   <td style="text-align:left;"> Camelot </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-3536340 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:left;"> Dough Boy </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-5868634 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 12 </td>
   <td style="text-align:left;"> Daisy </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-3871661 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> Emily Spinach </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-5526348 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14 </td>
   <td style="text-align:left;"> Simon </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-5140058 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 15 </td>
   <td style="text-align:left;"> Alton </td>
   <td style="text-align:left;"> New Zealand </td>
   <td style="text-align:left;"> 651-3521431 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 16 </td>
   <td style="text-align:left;"> Magnum </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-4143332 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 17 </td>
   <td style="text-align:left;"> Cappuccino </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-3764995 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 18 </td>
   <td style="text-align:left;"> Muzby </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-8763733 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19 </td>
   <td style="text-align:left;"> Dido </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-2775157 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 20 </td>
   <td style="text-align:left;"> Clipper </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:left;"> 651-2701942 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 21 </td>
   <td style="text-align:left;"> Flash </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:left;"> 651-8577826 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 22 </td>
   <td style="text-align:left;"> Coconut </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-3629717 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 23 </td>
   <td style="text-align:left;"> Kashmir </td>
   <td style="text-align:left;"> New Zealand </td>
   <td style="text-align:left;"> 651-8810964 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 24 </td>
   <td style="text-align:left;"> Odette </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:left;"> 651-8053298 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 25 </td>
   <td style="text-align:left;"> Snuffy </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-4253359 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 26 </td>
   <td style="text-align:left;"> Suki </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-3843430 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 27 </td>
   <td style="text-align:left;"> Thunderpants </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-8751667 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 28 </td>
   <td style="text-align:left;"> Ayn </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-2589814 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 29 </td>
   <td style="text-align:left;"> Ali McClaw </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-2101871 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 30 </td>
   <td style="text-align:left;"> Maestro </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-5994025 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 31 </td>
   <td style="text-align:left;"> Ishtar </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-4849246 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 32 </td>
   <td style="text-align:left;"> Honey </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-8231055 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 33 </td>
   <td style="text-align:left;"> David Meowie </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-2124966 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 34 </td>
   <td style="text-align:left;"> Godzilla </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-8995530 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 35 </td>
   <td style="text-align:left;"> Diamond </td>
   <td style="text-align:left;"> UK </td>
   <td style="text-align:left;"> 651-1813616 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 36 </td>
   <td style="text-align:left;"> Cromwell </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-5618079 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 37 </td>
   <td style="text-align:left;"> Marlon </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-8353864 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 38 </td>
   <td style="text-align:left;"> Indra </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-8220632 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 39 </td>
   <td style="text-align:left;"> Jason </td>
   <td style="text-align:left;"> New Zealand </td>
   <td style="text-align:left;"> 651-6548713 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 40 </td>
   <td style="text-align:left;"> Koolaid </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-2947684 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 41 </td>
   <td style="text-align:left;"> Courtney </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-8172059 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 42 </td>
   <td style="text-align:left;"> Disraeli </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> 651-6587804 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 43 </td>
   <td style="text-align:left;"> Carrie </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-7309417 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 44 </td>
   <td style="text-align:left;"> Monkey </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-1849615 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 45 </td>
   <td style="text-align:left;"> Anna </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> 651-6752144 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 46 </td>
   <td style="text-align:left;"> Charisma </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-2025817 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 47 </td>
   <td style="text-align:left;"> Veruca </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-2986261 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 48 </td>
   <td style="text-align:left;"> Miss Chevious </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-5789584 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 49 </td>
   <td style="text-align:left;"> Poppy </td>
   <td style="text-align:left;"> UK </td>
   <td style="text-align:left;"> 651-2918260 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 50 </td>
   <td style="text-align:left;"> Libearty </td>
   <td style="text-align:left;"> New Zealand </td>
   <td style="text-align:left;"> 651-4814949 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 51 </td>
   <td style="text-align:left;"> Matty </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:left;"> 651-7783456 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 52 </td>
   <td style="text-align:left;"> Claudia </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-2017842 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 53 </td>
   <td style="text-align:left;"> Aristotle </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:left;"> 651-3033064 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 54 </td>
   <td style="text-align:left;"> Barnett </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-7522275 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 55 </td>
   <td style="text-align:left;"> Slinky Malinky </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-3256170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 56 </td>
   <td style="text-align:left;"> Jack </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:left;"> 651-7367570 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 57 </td>
   <td style="text-align:left;"> Cecil </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-8058841 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 58 </td>
   <td style="text-align:left;"> Finn </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-7361885 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 59 </td>
   <td style="text-align:left;"> Anika </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-8364751 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 60 </td>
   <td style="text-align:left;"> Prelude </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-2354757 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 61 </td>
   <td style="text-align:left;"> Ally Mcbeagle </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-2320241 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 62 </td>
   <td style="text-align:left;"> Icabod </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-6302514 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 63 </td>
   <td style="text-align:left;"> Perfect </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-4473381 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 64 </td>
   <td style="text-align:left;"> Howard </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-4419460 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 65 </td>
   <td style="text-align:left;"> Romeo </td>
   <td style="text-align:left;"> New Zealand </td>
   <td style="text-align:left;"> 651-7554511 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 66 </td>
   <td style="text-align:left;"> Sweetie </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:left;"> 651-2058526 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 67 </td>
   <td style="text-align:left;"> Flip </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> 651-4504637 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 68 </td>
   <td style="text-align:left;"> Scoop </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-3177038 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 69 </td>
   <td style="text-align:left;"> Capp </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-2543186 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 70 </td>
   <td style="text-align:left;"> Hades </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-2210963 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 71 </td>
   <td style="text-align:left;"> Gandalf </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:left;"> 651-7644793 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 72 </td>
   <td style="text-align:left;"> Dionne </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:left;"> 651-8329127 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 73 </td>
   <td style="text-align:left;"> Wuffy </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-4505139 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 74 </td>
   <td style="text-align:left;"> Kingston </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-4811815 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 75 </td>
   <td style="text-align:left;"> Twinkie </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:left;"> 651-6062000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 76 </td>
   <td style="text-align:left;"> Gary </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-6217687 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 77 </td>
   <td style="text-align:left;"> Jelly </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-6830340 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 78 </td>
   <td style="text-align:left;"> Dickens </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-7726357 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 79 </td>
   <td style="text-align:left;"> Destiny </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:left;"> 651-2932637 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 80 </td>
   <td style="text-align:left;"> Adela </td>
   <td style="text-align:left;"> UK </td>
   <td style="text-align:left;"> 651-5591012 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 81 </td>
   <td style="text-align:left;"> Tater Bug </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-6057235 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 82 </td>
   <td style="text-align:left;"> Alma </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:left;"> 651-4816104 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 83 </td>
   <td style="text-align:left;"> Ballyhoo </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:left;"> 651-8187015 </td>
  </tr>
</tbody>
</table>

 
</details>

<br>
