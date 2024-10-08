# Bash Script to Split File
Bash script to split file into several files either by number of lines/number of files, zip the split file &amp; send it out to other path &lt;optional>

There are several parameters needed for this script:
- $1 = required file location
- $2 = file name.txt
- $3 = split method (by number of file/line) <e.g: file>
- $4 = number of split file/line
- $5 = header <header / headerless>
- $6 = target dir <optional>
###	To use this script: 
```./split_file.sh <file path> <filename> <split method> <chunks> <header> <target dir <opt>>```
