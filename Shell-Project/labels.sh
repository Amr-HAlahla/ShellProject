if [ $# -lt 1 ]; then # check if the user entered a parameter that represent the dataset file name.
  echo "Error: No dataset file provided"
  exit 1
fi
data=$1 # extract the register value (which is the name of the file)
line1=$(sed -n "1p" "$data" | tr ';' '\n') # split the first line by the delimeter ';' so we can then count the number of features. 
feature_count=$(echo "$line1" | wc -l) # count the number of features. 
# split the second line in order to be able to check if the number of feature's values matches the number of features
line2=$(sed -n "2p" "$data" | tr ';' '\n') 
values_count=$(echo "$line2" | wc -l) # count feature's values
#echo "$values_count"
if [ "$feature_count" != "$values_count" ]; then # check if they are equal, if not then print an error data formating message
  echo "The format of the data in the dataset file is wrong"
  exit 11
else
  echo "Format is Clean"  
fi
# save a copy of the main dataset file into another file to be processed.
cat "$data" > newdataset.txt
 > sc.txt # file to store the name of the features that have been encoded.
 > scale.txt # to store the features that have been encoded attatched with their codes.

