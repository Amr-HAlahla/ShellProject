# Set the initial value of the verified flag to false
verified=false

# Start the main loop
while [ 1 ]; do
  printf "\nr) read a dataset from a file\np) print the names of the features\nl) encode a feature using label encoding\no) enocde a feature using one-hot encoding\nm) apply MinMax scalling\ns) save the processed dataset\ne) exit\n"
  # ask user for the main option 
  echo "Please enter your option"	
  read option

  # Check if the option is 'r' or 'e'
  if [ "$option" = "r" -o "$option" = "e" ]; then
    # If the option is 'r' or 'e', set the verified flag to true
    verified=true
  fi

  # If the verified flag is false, print a message and continue to the next iteration of the loop
  # because the user should enter either r or e for the first time he run the script.
  if [ "$verified" = false ]; then
    echo "You must first read a dataset from a file"
    continue
  fi

  # Use a case statement to handle each menu option
  case "$option" 
  in
    "r" ) # the case where the user should enter the name of the dataset source.
    	  echo "Please input the name of the dataset file"
    	  read dataset
    	  # check if the file exists.
    	  if [ ! -e "$dataset" ]
    	  then
    	      echo "$dataset Not Found!"
    	      continue
    	  fi
    	  # if the name entered exist, then start the format checking process.
    	  ./labels.sh "$dataset";;
    "p" ) ./case3.sh;;
    "l" ) ./case4.sh "$dataset";;
    "o" ) ./case5.sh "$dataset";;
    "m" ) ./case6.sh "$dataset";;
    "s" ) 
    		saved=false
    		echo "Please input the name of the file to save the processed dataset"
    		read filename
    		cat newdataset.txt > "$filename"
    		saved=true
    		echo "Data Saved To The File $filename"
    		cat "$filename"
    		;;
    "e" ) 
    		if [ "$saved" ];then # check if the processed data saved or not.
    			echo "Are you sure you want to exist"
    			read answer
    			if [ "$answer" = "yes" ];then
    				exit 10
    			else
    				continue
    			fi
    		else
    			echo "The processed dataset is not saved. Are you sure you want to exist ?"
    			read answer
    			if [ "$answer" = "yes" ];then
    				exit 10
    			else
    				continue
    			fi
    		fi	
    	 ;; 
esac
done
