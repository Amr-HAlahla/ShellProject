 > features.txt # a file in whcih the categorical features will be stored
sed -i '/^$/d' features.txt
dataset="$1"
sed -i '/^$/d' newdataset.txt
counter=1
fet_index=100
numoflines=$(cat newdataset.txt | wc -l)
# Ask the user to input the name of a categorical feature for label encoding
echo "Please input the name of the categorical feature for one hot encoding"
read feature_name
# Extract the first line of the dataset file and store it in a file called line.txt
line=$(sed -n "1p" newdataset.txt) # Extract the first line of the dataset.
echo "$line" > line.txt
numf=$(cat line.txt | tr ';' '\n' | wc -l) # count number of features in the dataset.
# Loop through each field in line.txt
while [ "$numf" -gt 1 ]
do
   # Extract the current field from the first line of the dataset file
   fet=$(echo "$line" | cut -d';' -f"$counter")
   if [ "$fet" = "$feature_name" ];then
   	fet_index=$((counter))
   fi	
   # Extract the current field from the second line of the dataset file
   value=$(sed -n "2p" newdataset.txt | cut -d';' -f"$counter")

   # Check if the value of the current field is numeric or non-numeric
   if [[ ! "$value" =~ ^[0-9]+$ ]]; then
       echo "$fet" >> features.txt # if the feature is categorical, append its name into the file.
   fi

   numf=$((numf-1))
   counter=$((counter+1))
done

if grep -qw "$feature_name" features.txt; then # verify if the entered feature is one of the categorical.
  echo "Feature $feature_name exist in the file"
else
  echo "The name of categorical feature is wrong"
  exit 3
fi

count_fet=$(cat features.txt | wc -l) # count number of categorical features.
 > fet_value.txt
while [ "$numoflines" -gt 1 ];do
	fet_value=$(sed -n "$numoflines p" newdataset.txt | cut -d';' -f"$fet_index")
	numoflines=$((numoflines-1))
	echo "$fet_value" >> fet_value.txt # store the values of the current feature into a file.
done
#--------------------------
echo "$feature_name" > scale_line.txt # append the feature to the file at where the encoded features are stored.
 
sort  fet_value.txt | uniq > temp.txt && mv temp.txt fet_value.txt # sort and remove duplicated values.
cat fet_value.txt > copy.txt
# arrange the feature values as the wanted formatting to replace the feature name in tne dataset
cat fet_value.txt | tr '\n' ';' > tmp.txt && mv tmp.txt fet_value.txt 
echo "" > encodedfile.txt # Each encoded line will be appended to this file.
sed -i '/^$/d' encodedfile.txt
values=$(cat fet_value.txt) # the encoding of the feature name 
printf "\n"
sed -i '/^$/d' copy.txt
sed -i "s/\b"$feature_name";/"$values"/" newdataset.txt # replace the the feature name with its all possible unique values arranged.
#------------------------------------------------------
numoflines=$(cat newdataset.txt | wc -l)
while [ "$numoflines" -gt 1 ];do # loop through the dataset.
	sed -n "$numoflines p" newdataset.txt > newline.txt # Exract each line from the dataset in order to be encoded.
	cat newline.txt | tr ';' '\n' > tmp.txt && mv tmp.txt newline.txt # split the current line into multiple lines.
	sed -i '/^$/d' newline.txt
	linecount=$(cat copy.txt | wc -l) # count number of possible values for the current feature.
	parameter=$(sed -n "$fet_index p" newline.txt) # the target value that must be encoding.(the value to be replaced by 1)
	 > tempencoded.txt
	 counter=1
	while [ "$counter" -le "$linecount" ];do # loop through all possible values to determine which one is the target.
		var=$(sed -n "$counter p" copy.txt) # extract a randomly value from the possible values.
		if [ "$parameter" = "$var" ];then # if we reached the target value, replace it by value 1 in the code.
			echo "1" >> tempencoded.txt # append 1 to the result of one-hot code.
			echo "1" >> scale_line.txt # store the code beside the name of the feature so it will be used later(case'm').
		else
			echo "0" >> tempencoded.txt # if this is not the target, append 0 to the one-hot code.
			echo "0" >> scale_line.txt
			
		fi
		counter=$((counter+1))
	done
	cat tempencoded.txt | tr '\n' ';' > tmp.txt && mv tmp.txt tempencoded.txt # rearrange the code to be in the form (0;0;1;0 ...)
	code=$(cat tempencoded.txt) # store the final result of the code for the current value
	#printf "code = %s\n" "$code"
	sed -i "$numoflines s/\b"$parameter";/"$code"/" newdataset.txt # replace the value by its own code in the dataset.
	numoflines=$((numoflines-1))
done
cat scale_line.txt | tr '\n' ';' > tm.txt && mv tm.txt scale_line.txt
sed -i '/^$/d' scale_line.txt
cat scale_line.txt >> scale.txt
printf "\n" >> scale.txt
echo "$feature_name distinct values are :"
cat copy.txt
cat newdataset.txt # show the dataset after encoding.
echo "$feature_name" >> sc.txt # append the feature name to the file where the encoded features are stored.
