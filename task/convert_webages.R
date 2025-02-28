library(webshot2)
library(tidyverse)
#  MonitorSpecs.xResolution = 1920; % x resolution
# MonitorSpecs.yResolution = 1080;  % y resolution

fnames     <- list.files('./eeg-study/')
fnames_in  <- str_c('./eeg-study/', fnames)
fnames_out <- str_c('./', fnames_out <- str_sub(fnames, 1, -6), '.png')

for (k in 1:length(fnames)){
webshot(url  = fnames_in[k],
        file = fnames_out[k],
        vwidth  = 1920,
        vheight = 1080,
        cliprect = "viewport")
}  
