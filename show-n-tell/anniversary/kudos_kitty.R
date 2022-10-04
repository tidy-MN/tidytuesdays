# A kudos kitty for Kristie
## Add your message to the possible kitty sayings at https://github.com/MPCA-data/tidytuesdays/blob/main/show-n-tell/anniversary/kristie_kudos.MD

# Use:
# source("https://gist.githubusercontent.com/dKvale/41fa93f2f39124ee76054248bffb309a/raw/ed6d83109185f5ca51dfae5a358cf40bfd31aa6a/kudos_kitty.R")
# kudos_kitty()


kudos_kitty <- function(show_cat = T, name = "Kristie") {
  
  quotes <- readLines("https://gist.githubusercontent.com/dKvale/86bbe8df9f78251176df7c5f29629d73/raw/7280169ac2e41a927359791ef03f94e5035c8f61/kristie_kudos.MD")
  
  # Drop header and short lines
  quotes <- quotes[2:length(quotes)]
  
  quotes <- quotes[nchar(quotes) > 3]
  
  # Get random encouragement
  quote <- sample(quotes, 1)
  
  # Split in two
  quote1 <- strsplit(quote, "--")[[1]][1]
  quote2 <- strsplit(quote, "--")[[1]][2]
  
  # Print to screen
  if (show_cat) {
    
    cats <- c(back_cat = ' \n ------------------------------
        \u005c
         \u005c
          \u005c
            \u007c\u005c___/\u007c
            )     (
           =\\\     /=
             )===(
            /     \u005c
            |     |
           /       \u005c
           \u005c       /
      jgs   \u005c__  _/
              ( (
               ) )
              (_(',
      longcat = paste0('\n ------------------------------ \n    \\\   \n     \\\
    .\uFF8A,,\uFF8A
    ( \uFF9F\u03C9\uFF9F)
    |\u3064  \u3064\n',
    paste0(rep("    |    |\n", 14), collapse = ""),
    '    U "  U
               [BoingBoing]
    '),
    stretchycat =
      '\n ------------------------------
      \u005c
       \u005c
        \u005c
                        ,/\u007c         _.--\u201B\u201B^``-...___.._.,;
                      /, \u005c\u201B.     _-\u201B          ,--,,,--\u201B\u201B\u201B
                     {  \u005c    `_-\u201B\u201B       \u201B    /}\u201B
Jill                    `;;\u201B             ;   ; ;
                  ._.--\u201B\u201B     ._,,, _..\u201B  .;.\u201B
                  (,_....----\u201B\u201B\u201B     (,..--\u201B\u201B
  ',
anxiouscat =
  '\n ------------------------------
      \u005c
       \u005c
        \u005c
        /\u005c_/\u005c         _
       /``   \u005c       / )
       \u007cn n   \u007c__   ( (
      =(Y =.\u201B`   `\u005c  \u005c \u005c
      {`"`        \u005c  ) )
      {       /    \u007c/ /
       \u005c\u005c   ,(     / /
        ) ) /-\u201B\u005c  ,_.\u201B
  jgs  (,(,/ ((,,/
  ',
longtailcat =
  '\n ------------------------------
      \u005c
       \u005c
        \u005c
     /\u005c-/\u005c
    /a a  \u005c                                 _
   =\u005c Y  =/-~~~~~~-,_______________________/ )
     \u201B^--\u201B          ________________________/
       \u005c           /
       \u007c\u007c  \u007c---\u201B\u005c  \u005c
  jgs  (_(__\u007c   ((__\u007c
  ', 
the_cat = '\n ------------------------------
      \u005c
       \u005c
        \u005c
            \u007c\u005c___/\u007c
          ==) ^Y^ (==
            \u005c  ^  /
             )=*=(
            /     \u005c
            \u007c     \u007c
           /\u007c \u007c \u007c \u007c\u005c
           \u005c\u007c \u007c \u007c_\u007c/\u005c
      jgs  //_// ___/
               \u005c_)
  ')
    
    rando_cat <- sample(cats, 1)[[1]]
    
    if (nchar(name) > 0) {
      message(cat(paste0("\n Mrrrrowwww ", name, ". \n ", quote1, "\n --", quote2, rando_cat)))
    }
    
 
  
  get_cat <- function(width = 400, height = 400){
    r <- httr::GET(paste("http://theoldreader.com/kittens", width, height, sep = "/"))
    stop_for_status(r)
    content(r)
  }
  
  # Show the cat for the day
  plot(c(1:2), type='n', axes = F, main = "Today's kitty", xlab = "", ylab = "")
  rasterImage(get_cat(), 1, 1, 2, 2)
  }
}
