library(RSelenium)
library(stringr)


low_high <- read.csv("low_and_high_newsguard_articles.CSV",sep=";")



# Set the path to your Firefox extension
extension_path <- "https://addons.mozilla.org/firefox/downloads/file/4202634/i_dont_care_about_cookies-3.5.0.xpi"

# Start the RSelenium server with Firefox and the extension loaded
rD <- rsDriver(
  browser = "firefox",         # Use Firefox
  port = 4444L,                # Use a custom port if needed
  verbose = FALSE,             # Disable verbose logging
  extraCapabilities = list(
    "moz:firefoxOptions" = list(
      "args" = c("--load-extension=", extension_path)  # Load the extension
    )
  )
)

# Get the remote driver
remDr <- rD$client

# Resize the window to capture the entire page
remDr$setWindowSize(1920, 3500)  # You can adjust the size to fit the entire content

# Navigate to the URL
#urls = c()
#urls[1] <- "https://www.theguardian.com/environment/2024/nov/02/farm-subsidies-wrecked-europe-environments-common-agricultural-policy"
#urls[2] <- "https://www.washingtontimes.com/news/2021/jul/19/arizona-election-audit-will-show-trump-won-majorit/"


# Create the main folder for storing article data
dir.create("articles", showWarnings = FALSE)
articles = c()
errors = c()
# Loop through each URL
for (url in low_high$url[201:400]) {
  print (url)
  # Generate a safe folder name based on the URL (sanitize characters like slashes, etc.)
  folder_name <- str_replace_all(url, "[^[:alnum:]_]", "_")
  folder_path <- file.path("articles", folder_name)
  
  # Create a folder for the current URL
  dir.create(folder_path, showWarnings = FALSE)

  tryCatch({
  remDr$navigate(url)

  print("resizing")
  # Resize the window to capture the entire page
  remDr$executeScript("document.body.style.zoom='0.3';")  # Adjust the zoom factor here (e.g., 0.5 for 50%)

  # Wait for the page to load fully
  Sys.sleep(10)  # Adjust sleep time as needed to ensure the page is loaded



  # Use JavaScript to scroll to the bottom of the page to load all content

  print("taking screenshot")
  # Take the screenshot
  remDr$screenshot(file = file.path(folder_path, "full_screenshot.png"))

  print("storing data")
  # Extract the full HTML of the page
  html_content <- remDr$getPageSource()[[1]]

  # Extract CSS information (You may want to focus on specific elements like styles or linked stylesheets)
  css_content <- remDr$executeScript("return Array.from(document.styleSheets).map(sheet => sheet.href).join('; ')")
  css_content <- paste(unlist(css_content), collapse = "\n")
  
  # Extract the title of the page
  title <- remDr$getTitle()[[1]]

  # Extract the article text (You may need to adjust this based on the website's HTML structure)
  article_text <- remDr$executeScript("return document.querySelector('article').innerText;")
  article_text <- paste(unlist(article_text), collapse = "\n")

  # Store the extracted data in the folder
  writeLines(html_content, file.path(folder_path, "article.html"))    # Save the HTML content
  writeLines(css_content, file.path(folder_path, "styles.css"))       # Save the CSS information
  writeLines(title, file.path(folder_path, "article_title.txt"))      # Save the title
  writeLines(article_text, file.path(folder_path, "article_text.txt")) # Save the article text
  articles = rbind(articles,c(folder_path,title,article_text))
  
  }, error = function(e) {
    # Error handling: Print the error message
    cat("Error occurred while processing URL: ", url, "\nError message: ", e$message, "\n")
    errors = c(errors,url)
  })
}


articles.df = as.data.frame(articles)
# Perform the merge by the 'folder' column
merged_articles <- merge(articles.df, low_high[, c("folder", "label", "domain", "newsguard", "url")], by = "folder", all.x = TRUE)

table(merged_articles$newsguard<70)

low_high$folder <- paste0("articles/",str_replace_all(low_high$url, "[^[:alnum:]_]", "_"))


# Clean headlines

# Remove '- Geller Report' from the 'headline' column
merged_articles$cleaned_headline <- sub("- Geller Report$", "", merged_articles$headline)
data$cleaned_headline <- sub("\\s?\\| [^|]+ \\| Express\\.co\\.uk$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("– The Published Reporter$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("- CBS News$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("- TFPP Wire$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| TIME$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| Fox Business$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| Fox News$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| Nature$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("- Newsweek$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("- Palmer Report$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("- FactCheck.org$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("- FactCheck.org$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| TS Digest \\| The Scientist$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("^PolitiFact \\| ", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\s?\\| [^|]+ \\| Express\\.co\\.uk$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\|  Express.co.uk$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| The Scientist Magazine®$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\| The Gateway Pundit \\| by [^|]+$", "", merged_articles$cleaned_headline)
merged_articles$cleaned_headline <- sub("\\* WorldNetDaily \\* by [^,]+(?:, [^*]+)?$", "", merged_articles$cleaned_headline)

merged_articles$quality <- ifelse(merged_articles$newsguard > 70, "high", "low")

write.csv(merged_articles, "articles_for_tanja.csv")
colnames(articles)=c("folder","headline","body")
  # Close the session
  remDr$close()

# Stop the server
rD$server$stop()


