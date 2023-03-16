 > features.txt
 > numeric_features.txt
sed -i '/^$/d' features.txt
dataset="$1"
sed -i '/^$/d' "$dataset"
counter=1
fet_index=100
numoflines=$(cat "$dataset" | wc -l)
echo "Please input the name of the feature to be scaled"
read feature_name

# The code below is used to check whether the feature entered is categorical in its original case before determining
# whether it has been encoded or not.
line=$(sed -n "1p" "$dataset") # extract first line from the dataset
echo "$line" > line.txt
numf=$(cat line.txt | tr ';' '\n' | wc -l) # count number of features in order to able looping through it.
# Loop through each field in line.txt
while [ "$numf" -gt 1 ]
do
   fet=$(echo "$line" | cut -d';' -f"$counter") # exract feature name.
   if [ "$fet" = "$feature_name" ];then # verify if its the wanted feature.
   	fet_index=$((counter))
   fi	
   value=$(sed -n "2p" "$dataset" | cut -d';' -f"$counter")

   # Check if the value of the current field is numeric or non-numeric
   if [[ ! "$value" =~ ^[0-9]+$ ]]; then
       echo "$fet" >> features.txt
   else
   	echo "$fet" >> numeric_features.txt
   fi
   numf=$((numf-1))
   counter=$((counter+1))
done
#-------------------------------------------------
# loop to determine if the feature entered isn't categorical, also to save its index.
if ! grep -qw "$feature_name" features.txt;then
	line1=$(head -n 1 newdataset.txt) # Obtain the first line of the dataset in order to determine which numerical feature is the target.
	echo "$line1" | tr ';' '\n' > line1.txt
	line1=$(cat line1.txt | wc -l)
	counter=1
	while [ "$counter" -le "$line1" ];do
		name=$(sed -n "$counter p" line1.txt)
		if [ "$name" = "$feature_name" ];then
			numeric_index=$((counter)) # save the index of the numeric feature index.
		fi
		counter=$((counter+1))
	done	
fi
	
#-------------------------------------------------
# If the feature is categorical, we must determine whether it has been encoded or not.
if grep -qw "$feature_name" features.txt; then
  echo "Feature $feature_name exist in the file"
  if grep -qw "$feature_name" sc.txt; then # grep through the file containing the names of encoded features.
	echo "The Feature $feature_name Has Been Encoded" 
	# Extract only the codes (without the feature name) that are attached after the feature name.
	line=$(grep "$feature_name" scale.txt | cut -d';' -f2-) 
	echo "$line" | tr ';' '\n' > scaledcode.txt # Save the codes in a file, one for each line.
	sed -i '/^$/d' scaledcode.txt # remove blanked lines.
	numofcodes=$(cat scaledcode.txt | wc -l)
	#cat scaledcode.txt
	#echo "$numofcodes"
	counter=1
	# Sort the codes to make it easier to find the minimum and maximum values.
	# Extract the min and max numbers
	min=$(sort -n scaledcode.txt | head -n 1)
	max=$(sort -n scaledcode.txt | tail -n 1)
	 > vector.txt
	printf "[" >> vector.txt 
	printf "max value = %d \nmin value = %d\n" $max $min # print the min and max values.
	while [ "$counter" -le "$numofcodes" ];do  # loop through all codes to be encoded
		xi=$(sed -n "$counter p" scaledcode.txt) # extract each code separately
		upper=$((xi-min)) #calculate the numerator.
		lower=$((max-min)) # calculat denominator.
		xiscale=$(echo "scale=1;$upper/$lower" | bc) # calculate the float result of dividing upper by lower.
		printf "%.2f" $xiscale >> vector.txt # insert the scaled code into the vector
		if [ "$counter" -ne "$numofcodes" ]; then
			printf ", " >> vector.txt
		fi	
		printf "x$counter scaled into %.2f \n" $xiscale
		counter=$((counter+1))
	done
	printf "]." >> vector.txt
	#print the scaled vector
	printf "x-sacled = "
	cat vector.txt
  else
	echo "this feature $feature_name is categorical feature and must be encoded first"
	exit 3
  fi
# case of numeric features.
elif grep -qw "$feature_name" numeric_features.txt; then
   	> numeric_codes.txt # file at where the number feature's values are stored.
  	echo "The Feature is Numeric"
  	#echo "$numeric_index"
  	counter=2
  	numoflines=$(cat newdataset.txt | wc -l) # loop through the dataset to extract the values.
  	while [ "$counter" -le "$numoflines" ];do
  		value=$(sed -n "$counter p" newdataset.txt | cut -d';' -f$numeric_index)
  		echo "$value" >> numeric_codes.txt # store the current value
  		counter=$((counter+1))
  	done
  	counter=1
	# Extract the min and max numbers
	min=$(sort -n numeric_codes.txt | head -n 1)
	max=$(sort -n numeric_codes.txt | tail -n 1)
	printf "max value = %d \nmin value = %d\n" $max $min
	 > vector.txt
	printf "[" >> vector.txt 
	numoflines=$(cat numeric_codes.txt | wc -l)
	while [ "$counter" -le "$numoflines" ];do # loop through all codes.
		xi=$(sed -n "$counter p" numeric_codes.txt) # extract the current code
		upper=$((xi-min)) # calculate the numerator
		lower=$((max-min)) # calculate the denominator
		xiscale=$(echo "scale=1;$upper/$lower" | bc) # calculate the scale of the code.
		printf "%.2f" $xiscale >> vector.txt # insert the scaled value to the vector.
		if [ "$counter" -ne "$numoflines" ]; then
			printf ", " >> vector.txt
		fi
		printf "x$counter scaled into %.2f\n" $xiscale
		counter=$((counter+1))
	done
	printf "]." >> vector.txt
	printf "x-sacled = "
	cat vector.txt # print the scaled vector.
else
	echo "the feature does not exist in the dataset."	
fi
