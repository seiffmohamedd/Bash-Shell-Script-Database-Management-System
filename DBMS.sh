
# createDB, SelectDB, renameDB, DropDB
# createTB, SelectTB, renameTB, insertTB, DropTB


if [ -e ~/Database ]
then
	cd ~/Database
	echo "DBMS is ready"
else 
	mkdir ~/Database
	cd ~/Database
	echo "DBMS is ready"
fi

select option in createDB SelectDB createTB exit
do
case $option in
	"createDB")
		read -p "Please Enter Database Name: " DBName
		if [[ ! $DBName =~ ^[a-zA-Z] ]]
		then
			echo "Invalid database name. It must start with an alphabetic character."
		elif [ -e "$DBName" ]
		then
			echo "Database already exists."
		else 
			mkdir "$DBName"
			echo "Database is created successfully."
		fi
	;;
	"SelectDB")
	read -p "Please Enter Database Name: " SelectedDB
	if [ -e $SelectedDB ]
	then
		cd $SelectedDB
		echo "$SelectedDB Database is selected"
	else 
		echo "Database is not exist"
	fi
	;;
	"createTB")
	read -p "Please Enter Table Name: " CreatedTB
	if [ -e $CreatedTB ]
	then
		echo "table is already exist"
	else 
		touch $CreatedTB
		read -p "Please Enter Number of Colums: " numCol
	if [ $numCol -gt 0 ]
	then

		pk=0
for ((i=0;i<$numCol;i++))
do
line=""
read -p "Please Enter column name: " ColName
line+=:$ColName
read -p "please Enter column Datatype: " colType
line+=:$colType
if [ $pk -eq 0 ]
then
read -p "Do you want to make this Column PK (y/n) " checkPK
if [[ "yes" =~ $checkPK ]]
then
line+=:PK
pk=1
 fi
fi
echo ${line:1} >> ".meta$CreatedTB"
done
fi

echo "table is created successfully"
fi
	;;
"exit")
	break
	;;
*)
	echo UNKNOWN USER
esac

done
