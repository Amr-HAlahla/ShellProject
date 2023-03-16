# this script is used to print the names of features.
line=$(head -n 1 newdataset.txt | tr ';' '\n') # split the first line of the file which contains the features names=> each feature's name at a line.
printf "You have these features\n"
echo "$line"
