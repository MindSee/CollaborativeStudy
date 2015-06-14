# Utils for R script.
#    
#   Author: Filippo M.  11/06/2015

clearAll <- function() {
  # Clear Console/History/Environment
  # 
  # Syntax:
  #   clearAll()
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  12/06/2015
  
  
  # Clear Environment
  clearEnvironment()
  
  # Clear History
  clearHistory()
  
  # Clear Console
  clearConsole()
}

clearHistory <- function() {
  # Clear History
  # 
  # Syntax:
  #   clearHistory()
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  12/06/2015
  
  # Clear History
  write("", file=".blank")
  loadhistory(".blank")
  unlink(".blank")
}

clearConsole <- function() {
  # Clear Console
  # 
  # Syntax:
  #   clearConsole()
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  12/06/2015
  
  
  # Clear Console
  cat("\014")
}

clearEnvironment <- function() {
  # Clear Environment
  # 
  # Syntax:
  #   clearEnvironment()
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  12/06/2015
  
  # Clear Environment
  rm(list = ls())
}
