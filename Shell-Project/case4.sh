 > features.txt # file that will be used to store the name of categorical features. 
sed -i '/^$/d' features.txt
dataset="$1" # get the name of the original dataset file
# initializing varibales
counter=1
fet_index=100
# Count the number of lines in the dataset file
numoflines=$(cat newdataset.txt | wc -l)

# Ask the user to input the name of a categorical feature for label encoding
echo "Please input the name of the categorical feature for label encoding"
read feature_name

# Extract the first line of the dataset file and store it in a file called line.txt
line=$(sed -n "1p" newdataset.txt)
echo "$line" > line.txt

# Count the number of fields(features) in line.txt
numf=$(cat line.txt | tr ';' '\n' | wc -l)
# Loop through each field in line.txt
while [ "$numf" -gt 1 ]
do
   # Extract the current field from the first line of the dataset file
   fet=$(echo "$line" | cut -d';' -f"$counter")
   if [ "$fet" = "$feature_name" ];then # check if the entered feature's name matches the feature at the current index.
   	fet_index=$((counter)) # if yes, store the index (at which delimeter) of the target feature.
   fi
   # Extract the current field from the second line of the dataset file
   value=$(sed -n "2p" newdataset.txt | cut -d';' -f"$counter") # the value of the current feature

   # Check if the value of the current field is numeric or non-numeric
   if [[ ! "$value" =~ ^[0-9]+$ ]]; then # if its categorical, append the feature name into a file.
       echo "$fet" >> features.txt
   fi

   numf=$((numf-1))
   counter=$((counter+1))
done

if grep -qw "$feature_name" features.txt; then # verify that the entered feature is categorical or not (in order to be encoded).
  echo "Feature $feature_name exist in the file"
else
  echo "The name of categorical feature is wrong"
  exit 3
fi

count_fet=$(cat features.txt | wc -l)
 > fet_value.txt # a file in which the possible values for a specific feature are stored
while [ "$numoflines" -gt 1 ];do # loop through all lines in the dataset to extract the values
	fet_value=$(sed -n "$numoflines p" newdataset.txt | cut -d';' -f"$fet_index") # the value of the feature at the current data line.
	numoflines=$((numoflines-1))
	echo "$fet_value" >> fet_value.txt # append the value into the file.
done
	
sort  fet_value.txt | uniq > temp.txt # remove the dulicated values
 >codes.txt # a file in which the codes for the unique possible values are stored 
cat temp.txt > fet_value.txt  
sed -i '/^$/d' fet_value.txt # remove blank lines from the file
sed -i '/^$/d' codes.txt # remove blank lines from the file
#printf "Unique file :\n"
#cat fet_value.txt
counter=$(cat fet_value.txt | wc -l) # the number of unique values for the current specified feature.
code=0
while [ "$counter" -gt 0 ];do # loop through all values to attch it with their codes.
	value=$(sed -n "$counter p" fet_value.txt)
	echo "$code" >> codes.txt # store the unique codes in a file.
	code=$((code+1))
	counter=$((counter-1))	
done
paste -d'=' fet_value.txt codes.txt > encoded.txt # concat each value with its own code in one file (value = code).
#cat encoded.txt
sed -i '/^$/d' newdataset.txt
numoflines=$(cat newdataset.txt | wc -l)
echo "" > encodedfile.txt # a file in which the encoded data will be stored temporarily
sed -i '/^$/d' encodedfile.txt
head -n 1 newdataset.txt > encodedfile.txt # the first line will not be encoded in label-encoding.
echo "" > newline.txt
sed -i '/^$/d' newline.txt
counter=2
 > scale_line.txt # This file will be used with the option "m," and it stores every feature that has been encoded with its codes.
echo "$feature_name" >> scale_line.txt # set feature name has been encoded.

echo "The values of the features' codes are encoded as follows :"
cat encoded.txt
echo "---------------------------------------------------"
while [ "$counter" -le "$numoflines" ];do # loop through each line in the dataset.
	newline=$(sed -n "$counter p" newdataset.txt > newline.txt) # extract current line from the dataset
	cat newline.txt | tr ';' '\n' > tmp.txt && mv tmp.txt newline.txt # splitting
	sed -i '/^$/d' newline.txt # remove blank lines
	linecount=$(cat encoded.txt| wc -l) # get the number of possible encoded values.
	while [ "$linecount" -gt 0 ];do # loop through all possible encoded values attached with their own codes.
		var=$(sed -n "$linecount p" encoded.txt | cut -d'=' -f1) # get the name of the  value
		code=$(sed -n "$linecount p" encoded.txt | cut -d'=' -f2) # get the code of the current value.
		base_value=$(sed -n "$fet_index p" newline.txt) # extract the pointed field(by the 'fet_index' variable) from the line of dataset.
		sed -i "$fet_index s/\b"$var"/"$code"/" newline.txt # replace the value by its specified code.
		linecount=$((linecount-1))
		if [ "$base_value" = "$var" ];then # check if this is the wanted value.
			echo "$code" >> scale_line.txt # append the code so it will be used later.
		fi	
	done
	cat newline.txt | tr '\n' ';' > tmp.txt && mv tmp.txt newline.txt # rearrange the encoded data line as the original format.
	cat newline.txt >> encodedfile.txt # store each encoded line to the encoded data file.
	printf "\n" >> encodedfile.txt
	counter=$((counter+1))
done
cat encodedfile.txt > newdataset.txt # store the encoded data to the new dataset file.
printf "The dataset after label encoding for the feature $feature_name : \n"
cat newdataset.txt # print the final result after encode the current feature.
cat scale_line.txt | tr '\n' ';' > tm.txt && mv tm.txt scale_line.txt # rearrange the file in a useful form.
sed -i '/^$/d' scale_line.txt
cat scale_line.txt >> scale.txt # append the encoded feature with its codes to a file.
printf "\n" >> scale.txt
echo "$feature_name" >> sc.txt # to assign that this feature has been encoded correctly. 
