.First <- function() {

  message("Good morning Kristie!")
  
  get_cat <- function(width = 400, height = 400){
    r <- httr::GET(paste("http://theoldreader.com/kittens", width, height, sep = "/"))
    httr::stop_for_status(r)
    httr::content(r)
  }
  
  # Plot the cat for the day
  graphics::plot(data.frame(x = 1:2, y = 1:2), axes = F, main = "I am cat!", xlab = "", ylab = "", col = "white")
  
  graphics::rasterImage(get_cat(), 1, 1, 2, 2)
}
