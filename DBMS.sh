        if [ -e ~/Database ]
        then
            cd ~/Database
            echo "DBMS is ready"
        else 
            mkdir ~/Database
            cd ~/Database
            echo "DBMS is ready"
        fi

        select option in createDB SelectDB createTB insertData selectfromtable deletefromtable updatetable ListDataBases DropDatabase listTables dropTables exit
        do
        case $option in
            "createDB")
            
                cd /home/seif/Database
                echo "$(pwd)"
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
            cd ~/Database
            read -p "Please Enter Database Name: " SelectedDB
            if [ -e $SelectedDB ];
            then    
                cd $SelectedDB
                echo "$SelectedDB Database is selected"
            else 
                echo "Database doesn't exist"
            fi
            ;;
            "ListDataBases")
            ls ~/Database/
            ;;
            "createTB")
        echo "$(pwd)"
        if [[ $PWD == ~/Database/* ]]; then
            read -p "Please Enter Table Name: " CreatedTB
            if [[ ! $CreatedTB =~ ^[a-zA-Z] ]]; then
                echo "Invalid table name. It must start with an alphabetic character."
            elif ls | grep -i -q "^$CreatedTB$"; then
                echo "Table already exists (name matches case-insensitively)."
            else
                read -p "Please Enter Number of Columns: " numCol
                
                if [[ $numCol -gt 0 ]]; then
                    allowedDataTypes=("int" "number" "char" "varchar" "varchar2" "decimal" "float" "money" "tinyint" "bigint")
                    pk=0
                    schema_line=""
                    
                    
                  schema_content=""
        # add here that the create table name shouldnt be select , update or delete
for ((i=0; i<$numCol; i++)); do
    read -p "Please Enter column name: " ColName

    if [[ $ColName =~ ^[a-zA-Z] ]]; then
        
        echo "Datatypes allowed"
        echo "${allowedDataTypes[@]}"
        read -p "Please Enter column Datatype: " colType

        lowercase=$(echo "$colType" | tr 'A-Z' 'a-z')

        declare -i flag=0
        for dt in "${allowedDataTypes[@]}"; do
            
            if [[ $lowercase == $dt ]]; then
                flag=1
                break
            fi
        done

        if [[ $flag -eq 1 ]]; then
            column_line="$ColName:$lowercase"

            if [[ $pk -eq 0 ]]; then
                while true; do
                    read -p "Do you want to make this Column PK (y/n): " checkPK
                    if [[ $checkPK == "y" || $checkPK == "n" ]]; then
                        break
                    else
                        echo "Invalid input. Please enter 'y' or 'n'."
                    fi
                done

                if [[ $checkPK == "y" ]]; then
                    column_line+=":pk"
                    pk=1
                fi
            fi

            schema_content+="$column_line"$'\n'
        else
            echo "Invalid data type."
            i=$((i - 1))
        fi
    else
        echo "Invalid column name."
        i=$((i - 1))
    fi
done

echo -n "$schema_content" > ".meta$CreatedTB"

touch "$CreatedTB"
echo "Table is created successfully."

                else
                    echo "Number of columns must be greater than 0."
                fi
            fi
        else
            echo "please select a database"
        fi
        ;;

        "insertData")

        if [[ $PWD == ~/Database/* ]]; then
        read -p "Please enter the table name you want to insert into: " tbbname

        if [[ -f "$PWD/.meta$tbbname" ]]; then

            pkidx=($(awk '
                BEGIN { 
                
                FS=":" 
                
                }{ 
                if($3 == "pk"){
                    print NR
                }

                }' "$PWD/.meta$tbbname"))

            echo $pkidx

            fields=($(awk '
                BEGIN { 
                
                FS=":" 
                
                }{ 
                print $1
                }' "$PWD/.meta$tbbname"))

            columnType=($(awk '
                BEGIN { 

                FS=":" 
                
                }{ 
                
                print $2 
                
                }' "$PWD/.meta$tbbname"))

            allowedDataTypes=("int" "number" "char" "varchar" "varchar2")

            row=()
            echo "Enter data for the following fields:"

            for ((i = 0; i < ${#fields[@]}; i++)); do
                field="${fields[$i]}"
                type="${columnType[$i]}"

                while true; do
                ctr=0
                    read -p "$field ($type): " value

                    if [[ ctr==pkidx ]];then
                        if [[ $(cut -d: -f$((pkidx)) "$PWD/$tbbname" | grep -x "$value" | wc -l) -gt 0 ]]; then
                            echo "pk constraint violated"
                            continue
                        fi
                    fi
                    case $type in
                        int | number)
                            if [[ $value =~ ^-?[0-9]+$ ]]; then
                                row+=("$value")
                                break
                            else
                                echo "Invalid input. Please enter a valid integer."
                            fi
                            ;;
                        char | varchar | varchar2)
                            if [[ $value =~ ^.+$ ]]; then
                                row+=("$value")
                                break
                            else
                                echo "Invalid input. Please enter a valid string."
                            fi
                            ;;
                        *)
                            echo "Unknown data type: $type"
                            # exit 1
                            ;;
                    esac
                    ctr+=1
                done
            done

            # for value in "${row[@]}";do
            #     echo $value
            #     echo " jjj "
            # done

            insert_line=""
            for value in "${row[@]}"; do
                if [[ "$insert_line" == "" ]]; then
                    insert_line="$value"
                else
                    insert_line="$insert_line:$value"
                fi
            done

            echo "$insert_line" >> "$PWD/$tbbname"
            echo "Data inserted successfully into $tbbname."
        else
            echo "please select an existing table"
        fi
    else
        echo "You must select a database."
    fi
        ;;
        "selectfromtable")
        if [[ $PWD == ~/Database/* ]]; then

            read -p "enter the table name: " stbname
            # if [[ $tbbname  ]] 7ot hena en el table name exist validation
            if [[ -f "$PWD/$stbname" ]]; then
               


            read -p "enter column name you want to select from (column_name) (if no filter specified the whole table data will be displayed): " column_name
            
            if [[ $column_name == "" ]];then
                cat "$PWD/$stbname"
            else
            
            getColumnName=($(awk '
                BEGIN {
                    FS=":"
                }{
                    print $1
                }' "$PWD/.meta$stbname"))

            columnType=($(awk '
                BEGIN { 

                FS=":" 
                
                }{ 
                
                print $2 
                
                }' "$PWD/.meta$stbname"))
            flagfound=0
            colType=""
            colname=""
            idxx=0

            for ((i = 0; i < ${#getColumnName[@]}; i++)); do
                colname="${getColumnName[$i]}"
                if [[ $column_name == $colname ]]; then
                    flagfound=1
                    colType="${columnType[$i]}"
                    idxx=$((i + 1))
                    break  
                fi
            done
            if [[ $flagfound == 0 ]]; then
                echo "column name doesnt exist "
            else

            flagfound=0
            echo $colType
            echo $colname
            read -p "please enter your filteration constraint: " filter
            # filtered=$(cut -d: -f$((idxx)) "$PWD/$stbname" | grep -x "$filter" )
            # echo $filtered
            # echo $idxx

            awk '
            BEGIN {
                FS=":"
            }{
                if($idxx == filter)
                    print $0

            }' idxx="$idxx" filter="$filter" "$PWD/$stbname"

            # filtered=$(cut -d: -f"$idxx" "$PWD/$stbname" | grep -x "$filter")
            # echo $filterd

            # grep "$filtered" "$PWD/$stbname"

            fi
            fi
            else  
             echo "Table $stbname does not exist."
            fi

        else
            echo "please select a database"
        fi

        ;;
        "deletefromtable")

        if [[ $PWD == ~/Database/* ]]; then
            read -p "enter the table name: " stbname
            if [[ -f "$PWD/$stbname" ]]; then
            chmod 777 "$PWD/$stbname"
            read -p "enter column name you want to delete from (column_name) (if no filter specified the whole table data will be deleted): " column_name
            
            if [[ $column_name == "" ]];then
                touch delfile
                # echo "$PWD"
                > "$PWD/$stbname"
                rm -r delfile
            else

            getColumnName=($(awk '
                BEGIN {
                    FS=":"
                }{
                    print $1
                
                }' "$PWD/.meta$stbname"))

            columnType=($(awk '
                BEGIN { 

                FS=":" 
                
                }{ 
                
                print $2 
                
                }' "$PWD/.meta$stbname"))

            flagfound=0
            colType=""
            colname=""
            idxx=0
            
            for ((i = 0; i < ${#getColumnName[@]}; i++)); do
                colname="${getColumnName[$i]}"
                if [[ $column_name == $colname ]]; then
                    flagfound=1
                    colType="${columnType[$i]}"
                    idxx=$((i + 1))
                    break  
                fi
            done

            if [[ $flagfound == 0 ]]; then
                echo "column name doesn't exist "
            else

            flagfound=0
            echo $colType
            echo $colname
            read -p "please enter your delete constraint: " filter
            deletion=($(awk '
            BEGIN {
                FS=":"
            }{
                if($idxx == filter)
                    print $0

            }' idxx="$idxx" filter="$filter" "$PWD/$stbname"))

         for ((i=0; i<${#deletion[@]}; i++)); do
            del="${deletion[$i]}"
            # echo "dah el del"
            # echo $del 
            delrows=$(grep -x "$del" "$PWD/$stbname")
            echo "dah el del rows"
            echo $delrows
            
            for row in $delrows; do
                sed -i "/$row/d" "$PWD/$stbname"
            done
        done
            fi
            fi
            else  
             echo "Table $stbname does not exist."
            fi

        else
            echo "please select a database"
        fi

        ;;
        "updatetable")

if [[ $PWD == ~/Database/* ]]; then
    read -p "Enter the table name: " stbname
    if [[ -f "$PWD/$stbname" ]]; then
        chmod 777 "$PWD/$stbname"
        read -p "Enter the column name you want to update (column_name): " update_column_name

        getColumnName=($(awk '
            BEGIN { FS=":" }
            { print $1 }
        ' "$PWD/.meta$stbname"))

        columnType=($(awk '
            BEGIN { FS=":" }
            { print $2 }
        ' "$PWD/.meta$stbname"))

        flagfound=0
        colType=""
        colname=""
        idxx=0

        # Find the index of the column to update
        for ((i = 0; i < ${#getColumnName[@]}; i++)); do
            colname="${getColumnName[$i]}"
            if [[ $update_column_name == $colname ]]; then
                flagfound=1
                colType="${columnType[$i]}"
                idxx=$((i + 1))
                break
            fi
        done

        if [[ $flagfound == 0 ]]; then
            echo "Column name doesn't exist."
        else
            echo "Column Type: $colType"
            echo "Column Name: $colname"
            read -p "Enter the filter column name (column_name): " filter_column_name

            filter_idxx=0
            filter_flag=0

            # Find the index of the filter column
            for ((i = 0; i < ${#getColumnName[@]}; i++)); do
                colname="${getColumnName[$i]}"
                if [[ $filter_column_name == $colname ]]; then
                    filter_flag=1
                    filter_idxx=$((i + 1))
                    break
                fi
            done

            if [[ $filter_flag == 0 ]]; then
                echo "Filter column name doesn't exist."
            else
                read -p "Enter the filter constraint value: " filter
                read -p "Enter the new value for the column to update: " new_value

                if [[ $colType == "varchar" || $colType == "varchar2" ]]; then
                    if [[ $new_value == [a-z] ]]; then
                    else 
                        echo please enter

                elif [[ $colType == "int" ]]
                

                awk -v idxx="$idxx" -v filter_idxx="$filter_idxx" -v filter="$filter" -v new_value="$new_value" '
                BEGIN { FS=":"; OFS=":" }
                {
                    if ($filter_idxx == filter) {
                        $idxx = new_value
                    }
                    print $0
                }
                ' "$PWD/$stbname" > "$PWD/$stbname.tmp" && mv "$PWD/$stbname.tmp" "$PWD/$stbname"

                echo "Table updated successfully."

                fi
            fi
        else
            echo "Table $stbname does not exist."
        fi
    else
        echo "Please select a database."
    fi
    ;;


            "DropDatabase")
            cd ~/Database/
            read -p "Please enter the database name you want to drop: " dropname
            rm -rf $dropname

            ;;
            "listTables")
            
            if [[ ! "$(pwd)" == ~/Database/* ]]; then
                echo "please select a database"
                
            else
                ls "$(pwd)"
            fi
            ;;
            "dropTables")
            if [[ ! "$(pwd)" == ~/Database/* ]]; then
                echo "please select a database"
            else
            read -p "please enter table name " tbname
                if [[ -e "$tbname"  ]]; then
                    rm $tbname
                    rm .meta$tbname
                else
                    echo "table doesn't exist"
                fi
                
            fi
            ;;

        "exit")
            break
            ;;
        *)
            echo UNKNOWN COMMAND
        esac

        done
