echo "" > newdata.txt
echo "" > gender.txt
echo "" > features.txt
echo "" > encoded.txt
index=0
counter=2
numoflines=$(cat dataset.txt | wc -l)
#numoflines=$((numoflines-1))
echo "Please input the name of the categorical feature for label encoding"
read feature
line=$(head -n 1 dataset.txt)
echo "$line" > line.txt
cat line.txt | tr ';' '\n' >  temp.txt
cat temp.txt > line.txt
echo "" > temp.txt
numf=$(cat line.txt | wc -l)
while [ "$numf" -gt 0 ] 
do
   fet=$(sed -n "$numf p" line.txt)	
   if [ \( "$fet"  = "gender" \) -o \( "$fet" = "active" \) -o \( "$fet" = "smoke" \) -o \( "$fet" = "governorate" \) ]
   then
   	echo "$fet" >> features.txt
   fi
   numf=$((numf-1))
done 
cat features.txt  	
exist=false

nolines=$(cat features.txt | wc -l)
while [ "$nolines" -ne 0 ]
do
    f=$(sed -n "$nolines p" features.txt)	
    if [ "$f" = "$feature" ]
    then
    	exist=true
    	echo "feature exist $feature"
    	break
    fi
    nolines=$((nolines-1))
done

if [ "$exist" = false ]
then
  echo "The name of categorical feature is wrong"
elif [ "$exist" = true ]
then 
	while [ "$counter" -le "$numoflines" ]
	            do
		        sed -n "$counter p" dataset.txt >> newdata.txt
		        counter=$((counter+1))
	            done
	cat newdata.txt            
	case "$feature" 
	in
	     "gender" ) 
	     	    nolines=$(cat newdata.txt | wc -l)
	     	    while [ "$nolines" -ne 0 ]
	     	    do
	     	    	gender=$(sed -n "$nolines p" newdata.txt | cut -d';' -f3)
	            	echo "$gender" >> gender.txt
	            	nolines=$((nolines-1))
	     	    done	
	            #cat id.txt
	            
	            sort  gender.txt | uniq > temp.txt
	            cat temp.txt > gender.txt  
	            printf "Unique file :\n"
	            cat gender.txt
	            female=1
	            male=0
	            printf "male encoded into %d\n" "$male"
	            printf "female encoded into %d\n" "$female"
	            
	            echo "" > gendertemp.txt
	            sed -i 's/female/1/g' gender.txt >> gendertemp.txt
	            sed -i 's/male/0/g' test.txt >> gendertemp.txt
	            #awk '{sub(/"female"/,1)}1' gender.txt >> gendertemp.txt 
		    #awk '{sub(/"male"/,1)}1' gender.txt >> gendertemp.txt 
		    cat gendertemp.txt > gender.txt
	            #mv gendertemp.txt gender.txt
	            cat gender.txt
	            ;;   
	esac		  
fi      	


