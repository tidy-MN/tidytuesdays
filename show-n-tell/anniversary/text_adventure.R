## Tenliner Cave Adventure by Einar Saukas
## Ported from ZX81 BASIC to R by Peter Prevos

# Play game
#source("https://raw.githubusercontent.com/MPCA-data/tidytuesdays/master/show-n-tell/anniversary/text_adventure.R")


# Player options #
#----------------#
# (N)orth
# (S)outh
# (E)ast
# (W)est
#
# look
# open **
# take **
# fight **
# inventory



## Helper functions to keep syntax close to ZX81
val <- function(p) as.numeric(p)

get_state <- function(p, q = p) substr(game_state, p, q)

## Ported ZX81 code
game_state <- "100"  # The first number is the room number, #1 is the starting room - The Cave

responses <- data.frame(text = c(
                             "...Sorry, but he cannot.",
                             "...Derek walks slowly. His foot still aches.",
                             " *opened* ",
                             " *closed* ",
                             "( There is a *fish*. It stares up at Derek curiously. )", #The handle sparkles and then goes dark.
                             "( There is a *key* with a small snake etched on its side. )",
                             "( There is nothing of significance. )",
                             "...Derek sees a metal *chest*.",
                             "...Derek sees a very large *cat*. It is definitely bigger than him and it is not happy.",
                             "...Derek sees a leather *boot*. It seems size for a very large left foot. Strange.",
                             " *taken* ",
                             "Derek was brave, however the cat was very hungry and ate him. He shall be remembered. But ever so briefly.",
                             "Yum! The cat was appeased and fell fast asleep. Derek shall be remembered for several years at least."),
                        stringsAsFactors = F)

rooms <- data.frame(room_n   = 1:4,
                    room_desc = c("cave", "pit", "hall. Derek feels a light damp breeze. Or maybe it is something breathing", "lake"),
                    stringsAsFactors = F)

# Room update table
update_room <- data.frame(room_n     = c(1,3,3,2,2,4),
                          direction  = c("north", "south", "east", "west", "north", "south"),
                          new_room   = c(3,1,2,3,4,2))


cat("\n\n\n\n\n\n\n\n\n\n\n\n")
cat("#---------------------------------------------------------------#\n#\n")
cat("# Derek awakes and his eyes begin to adjust to the darkness. \n#\n# Ouch! His left ankle bites with pain. \n#\n# Derek looks around.")
cat("\n#\n")

repeat {

  cat("\n\n| Derek is standing in a ")

  cat(rooms[val(get_state(1)), ]$room_desc)

  cat("...  \n\n")

  # Get user input
  u <- tolower(readline(prompt = "> What does Derek do (N-S-E-W or look-open-take-feed-inventory)?  "))

  if (nchar(u) > 0) {

  #u <- strsplit(u, " ")[[1]][1]

  # Change room if direction is in table
    if (substr(u, 1, 1) %in% c("n", "s", "e", "w")) {
       m <- subset(update_room, room_n == val(get_state(1)) & substr(direction, 1, 1) == substr(u, 1, 1))$new_room

       if (length(m) > 0) {

         a <- 2

       } else {

         m <- val(get_state(1))

         a <- 1

       }

    } else {

      m <- val(get_state(1))

      # Find correct response
      a <- (3 * val(get_state(2)) + 2 * (get_state(3) == "2")) * (get_state(1) == 2 & u == "look chest") +
           (11 + (get_state(3) == "2")) * (get_state(1) == "3" & strsplit(u, " ")[[1]][1] == "feed") +
           (length(m) > 0) +
           (5 + val(get_state(1))) * (u == "look") +
           (6 - val(get_state(3))) * (u == "inventory") +
           (6 - (get_state(3) == "0")) * (get_state(1) == 4 & u == "look boot") +
           10 * (get_state(1, 3) == "400" & u == "take key") +
           2 * (get_state(1, 3) == "201" & u == "open chest") +
           10 * (get_state(1, 3) == "211" & u == "take fish") +
           1 * (get_state(1, 3) == "211" & u == "look chest")
}

  # Update room and game status
  game_state <- paste0(m, val(get_state(2)) + (a == 3), val(get_state(3)) + (a == 11))

  cat(paste("\n", responses[a, ]))

  if (a > 11) {

    cat("\n\n")

    if (get_state(3) == "2") {
       i <- readline(prompt = "> Enter your hero's name:  ")

       cat(paste0("\n", i, ", the wielder of 1,000 fishes once stood here.\n\n\n~ THE END ~\n\n"))
    }

    break

  }
  }

}

