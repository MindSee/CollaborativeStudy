

getExpDef <- function() {
  
  trialdef <- function(block, part, sybmol, condition, trial, target) {
    data.frame(Block = block, Part = part,
               Condition = condition, Symbol = symbol,
               Trial = trial, Target = target, stringsAsFactors = FALSE)
  }
  
  rbind(
    ## Session 1:
    trialdef(1, 1, "sq", "hf", 1, 17),
    trialdef(1, 1, "sq", "hf", 2, 8),
    trialdef(1, 1, "sq", "hf", 3, 7),
    trialdef(1, 1, "sq", "hf", 4, 14),
    
    trialdef(1, 2, "do", "lf", 1, 10),
    trialdef(1, 2, "do", "lf", 2, 17),
    trialdef(1, 2, "do", "lf", 3, 18),
    trialdef(1, 2, "do", "lf", 4, 9),
    
    trialdef(1, 3, "st", "hf", 1, 10),
    trialdef(1, 3, "st", "hf", 2, 8),
    trialdef(1, 3, "st", "hf", 3, 13),
    trialdef(1, 3, "st", "hf", 4, 14),
    
    trialdef(1, 4, "tr", "lf", 1, 7),
    trialdef(1, 4, "tr", "lf", 2, 6),
    trialdef(1, 4, "tr", "lf", 3, 11),
    trialdef(1, 4, "tr", "lf", 4, 16),
    
    ## Session 2:
    trialdef(2, 1, "es", "hf", 1, 11),
    trialdef(2, 1, "es", "hf", 2, 15),
    trialdef(2, 1, "es", "hf", 3, 8),
    trialdef(2, 1, "es", "hf", 4, 18),
    
    trialdef(2, 2, "cr", "lf", 1, 15),
    trialdef(2, 2, "cr", "lf", 2, 6),
    trialdef(2, 2, "cr", "lf", 3, 9),
    trialdef(2, 2, "cr", "lf", 4, 16),
    
    trialdef(2, 3, "do", "hf", 1, 18),
    trialdef(2, 3, "do", "hf", 2, 10),
    trialdef(2, 3, "do", "hf", 3, 9),
    trialdef(2, 3, "do", "hf", 4, 17),
    
    trialdef(2, 4, "es", "lf", 1, 15),
    trialdef(2, 4, "es", "lf", 2, 8),
    trialdef(2, 4, "es", "lf", 3, 11),
    trialdef(2, 4, "es", "lf", 4, 18),
    
    
    ## Session 3:
    trialdef(3, 1, "tr", "hf", 1, 6),
    trialdef(3, 1, "tr", "hf", 2, 11),
    trialdef(3, 1, "tr", "hf", 3, 7),
    trialdef(3, 1, "tr", "hf", 4, 16),
    
    trialdef(3, 2, "st", "lf", 1, 8),
    trialdef(3, 2, "st", "lf", 2, 13),
    trialdef(3, 2, "st", "lf", 3, 10),
    trialdef(3, 2, "st", "lf", 4, 14),
    
    trialdef(3, 3, "cr", "hf", 1, 16),
    trialdef(3, 3, "cr", "hf", 2, 6),
    trialdef(3, 3, "cr", "hf", 3, 15),
    trialdef(3, 3, "cr", "hf", 4, 9),
    
    trialdef(3, 4, "sq", "lf", 1, 17),
    trialdef(3, 4, "sq", "lf", 2, 8),
    trialdef(3, 4, "sq", "lf", 3, 14),
    trialdef(3, 4, "sq", "lf", 4, 7))
}



readExpSetup <- function(file) {
  stopifnot(require("XML"))
  
  doc <- xmlTreeParse(file, useInternalNodes = TRUE)
  
  attrs <- xmlAttrs(xmlRoot(doc))
  
  coords <- xmlToDataFrame(doc, stringsAsFactors = FALSE,
                           colClasses = c(xPos = "numeric", yPos = "numeric",
                                          rotation = "numeric", size = "numeric",
                                          shape = "character", pattern = "character"))
  
  #coords$IsTarget <- str_detect(coords$pattern, attrs["target"])
  coords$IsTarget <- coords$pattern == sprintf("%s_00", attrs["target"])
  
  free(doc)
  
  coords <- cbind(Condition = sub(".+/(.+)_(.+)_(\\d+).xml", "\\2", file),
                  Symbol = sub(".+/(.+)_(.+)_(\\d+).xml", "\\1", file),
                  Targets = as.numeric(sub(".+/(.+)_(.+)_(\\d+).xml", "\\3", file)),
                  coords)
  
  coords
}


loadExpSetup <- function(SETUPDIR) {
  
  conditions <- list.files(SETUPDIR, full = TRUE)
  files <- lapply(conditions, list.files, pattern = ".*xml", full = TRUE, recursive = TRUE)
  files <- unlist(files, recursive = FALSE)
  setups <- lapply(files, readExpSetup)
  
  sd <- data.frame(Cond = as.character(sapply(setups, function(x) x$Condition[1])),
                   Symb = as.character(sapply(setups, function(x) x$Symbol[1])),
                   Tars = sapply(setups, function(x) x$Targets[1]),
                   stringsAsFactors = FALSE)
  
  
  def <- get_ExpDef()
  
  head(def)
  head(sd)
  
  
}