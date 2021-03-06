gheatmap2 <- function(p, data, offset = 0, width = 1, 
                      low = "green", high = "red", color = NULL, 
                      colnames = TRUE, colnames_position = "bottom", 
                      colnames_level = NULL, font.size = 4, guide = "none") 
{
  # colnames_position %<>% match.arg(c("bottom", "top"))
  colnames_position <- match.arg(colnames_position, c("bottom","top"))
  variable <- value <- lab <- y <- NULL
  width <- width * (p$data$x %>% range %>% diff)/ncol(data)
  isTip <- x <- y <- variable <- value <- from <- to <- NULL
  df <- p$data
  df <- df[df$isTip, ]
  start <- max(df$x) + offset
  dd <- data
  lab <- df$label[order(df$y)]
  dd <- dd[lab, , drop = FALSE]
  dd$y <- sort(df$y)
  dd$lab <- lab
  dd <- gather(dd, variable, value, -c(lab, y))
  i <- which(dd$value == "")
  if (length(i) > 0) {
    dd$value[i] <- NA
  }
  if (is.null(colnames_level)) {
    dd$variable <- factor(dd$variable, levels = colnames(data))
  }
  else {
    dd$variable <- factor(dd$variable, levels = colnames_level)
  }
  V2 <- start + as.numeric(dd$variable) * width
  mapping <- data.frame(from = dd$variable, to = V2)
  mapping <- unique(mapping)
  dd$x <- V2
  dd$width <- width
  if (is.null(color)) {
    p2 <- p + geom_tile(data = dd, aes(x, y, fill = value, width = width), 
                        inherit.aes = FALSE)
  }
  else {
     p2 <- p + geom_tile(data = dd, aes(x, y, fill = value, width = width), 
                         color = color, inherit.aes = FALSE)
   }
  if (is(dd$value, "numeric")) {
    p2 <- p2 + scale_fill_gradient(low = low, high = high, 
                                   na.value = "white", guide = guide)
  }
  else {
    p2 <- p2 + scale_fill_discrete(na.value = "white", guide = guide)
  }
  if (colnames) {
    if (colnames_position == "bottom") {
      y <- 0
    }
    else {
      y <- max(p$data$y) + 0.02*max(p$data$y)
    }
    p2 <- p2 + geom_text(data = mapping, aes(x = to, label = from), 
                         y = y*1.01,
                         size = font.size, inherit.aes = FALSE,
                         show.legend = F)
  }
  #p2 <- p2 + theme(legend.position = "right", legend.title = element_blank())
  attr(p2, "mapping") <- mapping
  return(p2)
}
