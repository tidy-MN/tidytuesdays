# An encouragement kitty that is sometimes punny
## Add your name for a personalized message

# source("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/anniversary/encourage_cat.R")
# encourage_cat()


encourage_cat <- function(name = "", cat = T) {
  
  #install.packages("cowsay")
  #library(cowsay)
  
  quotes <- c("The party starts meow!",
              "I do declare. You are officially pawesome at this.",
              "Keep clawing your way forward.",
              "All that work is paying off.",
              "You are quite good my friend.",
              "You are on a roll.",
              "Excellently done!",
              "Keep the streak going.",
              "You are unstoppable.",
              "MeoWoWwwwwwwww!",
              "I am proud of you.",
              "You have furry serious R skills.",
              "That was nicely done.",
              "Way to land on your feet!",
              "Wow! Great job! Now feed me.",
              "You have the eye of the tiger.",
              "Keep being amazing!",
              "You're on fire!",
              "That was purrfect!",
              "Allow me to paws for a moment to appreciate your greatness.",        
              "Great job! Furr real!",
              "You aren't kitten around!",
              "Nothing gives you paws.",
              "Time for less worry and more purry.",
              "I'm feline good about your code.",
              "You are a catalyst for success!",
              "Breaking Meows! You rock!",
              "Not too shabby for a tabby!",
              "Way to dig your claws in!",
              "Not bad. That wasn't a total catastrophe.",
              "You are the whole kitten-kaboodle."
              )
  
  # Get random encouragement
  quote <- sample(quotes, 1)

  # Print to screen
  if (cat) {
    
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
  cat = '\n ------------------------------
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
      return(cat(paste0("\n Meow-meow ", name, ". ", quote, rando_cat)))
    }
    
    return(cat(paste0("\n Meow-meow. ", quote, rando_cat)))
  }
  
  return(cat(paste0("\n ", quote)))
  
}
