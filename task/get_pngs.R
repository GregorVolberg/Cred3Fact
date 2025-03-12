library(RSelenium)
library(stringr)

#fnames     <- list.files('X:/Volberg/Cred3Fact/src/stim/eeg-study/',
#                         pattern = '2-f-lh-[0-9]{1,2}-vl-[1-8].html')
fnames     <- list.files('X:/Volberg/Cred3Fact/src/stim/eeg-study-2/',
                         pattern = '*.html')

fnames_in  <- str_c('X:/Volberg/Cred3Fact/src/stim/eeg-study-2/', fnames)
fnames_out <- str_c('X:/Volberg/Cred3Fact/src/stim/', str_sub(fnames, 1, -6), '.png')

rd1 <- rsDriver(browser = "firefox",
               chromever = NULL) 

# Get the remote driver
remDr <- rd1$client

# Resize the window to capture the entire page
remDr$setWindowSize(1920, 1080)  # You can adjust the size to fit the entire content

for (url in 1:length(fnames_in)){
#for (url in 1:10){ # for testing
  # full path?
print(fnames_in[url])
remDr$navigate(fnames_in[url])
remDr$executeScript("document.body.style.zoom='0.7';")  # adjust zoom factor
Sys.sleep(1) # Wait for the page to load fully
remDr$screenshot(file =  fnames_out[url]) # save
}

# Close the session
remDr$close()

# Stop the server
rd1$server$stop()


