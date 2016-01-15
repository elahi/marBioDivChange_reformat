# marBioDivChange_reformat
Reformatting Current Biology database for J Dunic

My old meta data were somewhat similar to your current spreadsheet, because I began
by using Jarrett's template, but then it diverged from there (in part, because rather
than having everything in one spreadsheet, I opted for several with distinct purposes, 
which were then merged to create the CB master spreadsheet (Table S4)

I realized that I should just do the whole thing, and then you can filter it to the studies
that you need.  

## Brief summary of what I did
- I reformatted files to begin matching your meta_data, which included
modifying three files (studyNameList.csv, studySubList.csv, siteList.csv)

- I then wrote a script (bts_reformat...) to compile the necessary columns into one master spreadsheet for 
you to look at (master.csv in output folder)

- The master.csv is not cleaned up yet, and has a ways to go - but I think it is close 
to where I think you can take it and finish it off, hopefully

## questions for JD

- I relabeled my 'soft bottom subtidal' as jd's 'subtidal mudflat'
- I did not use 'estuarine mudflat', only 'subtidal mudflat'

- Does site size refer to the 'extent', or the total amount of area sampled per site (I 
have some relevant info in the studySubList.csv, but let's talk about what you need) 

- Do you want to include both sample and site scale data for datasets that have both (e.g.,
LTER, LTER, Birkeland)?  You can filter the data as needed.  Note that some studies only 
have data at gamma scales, so don't filter simply by excluding gamma. 

- plot number depends on site, and i have it listed as a range - if you need the correct
number of plots per site, we will need to go through the data


