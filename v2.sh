if [ -e ~/Database ]
    then
    cd ~/Database
    echo "DBMS is ready"
    else
        mkdir ~/Database
        cd ~/Database
        echo "DBMS is ready"
        fi
while true ;
exitflag=0
do
select option in createDB SelectDB ListDataBases DropDatabase exit
do
case $option in
        "createDB")
# echo "$(pwd)"
        cd /home/seif/Database

        read -p "Please Enter Database Name: " DBName
        if [[ $DBName == "" ]]
                then
                echo "Enter Any Name"

                elif [[ ! $DBName =~ ^[a-zA-Z] ]]
                then
                echo "It must start with an alphabetic character."
                elif [[ $DBName =~ [/\\.] ]]; then
                echo "Database name cannot contain '/', '\\', or '.'"
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
                    dbDir="$(pwd)/${SelectedDB}" 
                    if [[ $SelectedDB == "" ]];
                    then
                    echo "Please enter a database name"
                    elif [[ $SelectedDB == "/" || $SelectedDB == "." || $SelectedDB == ".." ]]; then
                        echo "please enter a valid database name"

                    elif [[ -d "$(pwd)/${SelectedDB}" ]] ;
                    then
                    cd $SelectedDB
                    while true;
                        do
                        exitFlag=0
                         select optionn in createTB insertData selectfromtable deletefromtable updatetable listTables dropTables back
                         do
                         case $optionn in
                         "createTB")
                        echo "$(pwd)"
                        if [[ $PWD == ~/Database/* ]]; then
            read -p "Please Enter Table Name: " CreatedTB
           if [[ $CreatedTB == "" ]]; then
                echo "Please Enter Any Name"
            elif [[ ! $CreatedTB =~ ^[a-zA-Z] || $CreatedTB =~ [/\\.] ]]; then
                echo "Table name must start with an alphabetic character and cannot contain '/', '\\', or '.'"
            elif [[ $CreatedTB =~ ^[Ss][Ee][Ll][Ee][Cc][Tt]$ || $CreatedTB =~ ^[Uu][Pp][Dd][Aa][Tt][Ee]$ || $CreatedTB =~ ^[Dd][Ee][Ll][Ee][Tt][Ee]$ ]]; then
                echo "Reserved keywords like SELECT, UPDATE, or DELETE are not allowed"
            elif [[ -e "$(pwd)/$CreatedTB" ]]; then
                echo "Table already exists"
            else
                while true; do
                 read -p "Please Enter Number of Columns: " numCol
                 if [[ $numCol =~ ^[1-9][0-9]*$ ]]; then
                    break
                 else
                 echo "Invalid input write a number"
                 fi
                done
                if [[ $numCol == "" ]]; then
                    echo "please enter any number"
                elif [[ $numCol -gt 0 ]]; then
                    allowedDataTypes=("int" "number" "char" "varchar" "varchar2")
                    pk=0
                    schema_line=""
                    schema_content=""
                    colCheck=()
                 for ((i = 0; i < numCol; i++)); do
                    colNameflag=0
                    read -p "Please Enter column name: " ColName
                    if [[ -z $ColName ]]; then
                        echo "please enter a column name"
                        i=$((i - 1))
                    else

                    if [[ $ColName =~ ^[a-zA-Z] ]]; then
                        for c in "${colCheck[@]}"; do
                            if [[ $ColName == "$c" ]]; then
                                echo "Cannot have 2 columns with the same name."
                                colNameflag=1
                                break
                            fi
                        done

                    if [[ $colNameflag -eq 0 ]]; then
                        colCheck+=("$ColName")
                        echo "Datatypes allowed"
                        echo "${allowedDataTypes[@]}"
                        echo "varchar2 -> for special characters like @, _,- and number"
                        echo "varchar -> for characters only"
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
                        echo "Cant Create, Column Name Repeated"
                        i=$((i - 1))
                    fi
                else
                    echo "Column name must start with a letter"
                    i=$((i - 1))
                fi
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

        if [[ -z "$tbbname" ]]; then
            echo "Please enter a table name."
        elif [[ -f "$PWD/.meta$tbbname" ]]; then
            pkidx=($(awk '
                BEGIN { FS=":" }
                {
                    if ($3 == "pk") {
                        print NR
                    }
                }' "$PWD/.meta$tbbname"))

            fields=($(awk '
                BEGIN { FS=":" }
                { print $1 }
            ' "$PWD/.meta$tbbname"))

            columnType=($(awk '
                BEGIN { FS=":" }
                { print $2 }
            ' "$PWD/.meta$tbbname"))

            allowedDataTypes=("int" "number" "char" "varchar" "varchar2")
            row=()
            echo "Enter data for the following fields:"

            for ((i = 0; i < ${#fields[@]}; i++)); do
                field="${fields[$i]}"
                type="${columnType[$i]}"
                is_pk=0

                if [[ $((i + 1)) -eq ${pkidx[0]} ]]; then
                    is_pk=1
                fi

                while true; do
                    if [[ $is_pk -eq 1 ]]; then
                        read -p "$field ($type) [Primary Key, required]: " value
                        if [[ -z "$value" ]]; then
                            echo "The primary key field cannot be empty"
                            continue
                        fi

                        if [[ $(cut -d: -f$((pkidx[0])) "$PWD/$tbbname" | grep -x "$value" | wc -l) -gt 0 ]]; then
                            echo "Primary key constraint violated"
                            continue
                        fi
                    else
                        read -p "$field ($type) [Optional]: " value
                    fi

                    case $type in
                    int | number)
                        if [[ -z "$value" ]] || [[ $value =~ ^-?[0-9]+$ ]]; then
                            row+=("$value")
                            break
                        else
                            echo "Invalid input. Please enter a valid integer or leave it empty."
                        fi
                        ;;
                    char)
                        if [[ -z "$value" ]] || [[ ${#value} -eq 1 && $value =~ ^[a-zA-Z]$ ]]; then
                            row+=("$value")
                            break
                        else
                            echo "Invalid input. Please enter a single character or leave it empty."
                        fi
                        ;;
                    varchar)
                        if [[ -z "$value" ]] || [[ $value =~ ^[a-zA-Z][a-zA-Z\ ]*$ ]]; then
                            row+=("$value")
                            break
                        else
                            echo "Invalid input. Please enter letters and spaces only, starting with a letter, or leave it empty."
                        fi
                        ;;
                    varchar2)
                        if [[ -z "$value" ]] || [[ $value =~ ^[a-zA-Z][a-zA-Z0-9@._-]*$ ]]; then
                            row+=("$value")
                            break
                        else
                            echo "Invalid input. Please enter letters, numbers, or special characters, starting with a letter, or leave it empty."
                        fi
                        ;;
                    *)
                        echo "Unknown data type: $type"
                        ;;
                    esac
                done
            done

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
            echo "Please select an existing table."
        fi
    else
        echo "You must select a database."
    fi
    ;;

        "selectfromtable")
        if [[ $PWD == ~/Database/* ]]; then

            read -p "enter the table name: " stbname

            if [[ $stbname == "" ]]; then
                echo "Please enter a table name"
            elif [[ -f "$PWD/$stbname" ]]; then

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
            if [[ -z $filter ]]; then
            echo "please enter a filter"
            else
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
    read -p "Enter the table name: " stbname
    if [[ -f "$PWD/$stbname" ]]; then
        chmod 777 "$PWD/$stbname"
        read -p "Enter column name you want to delete from (column_name)
                (ALL --> will delete the whole table): " column_name

        if [[ $column_name == "ALL" ]]; then
            > "$PWD/$stbname"
            echo "Table cleared."
        elif [[ $column_name == "" ]]; then
            echo "Please enter a valid column name."
        else
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
            idxx=0

            for ((i = 0; i < ${#getColumnName[@]}; i++)); do
                if [[ $column_name == ${getColumnName[$i]} ]]; then
                    flagfound=1
                    colType="${columnType[$i]}"
                    idxx=$((i + 1))
                    break
                fi
            done

            if [[ $flagfound == 0 ]]; then
                echo "Column name doesn't exist."
            else
                # echo "Column Type $colType"
                read -p "Please enter your delete filter: " filter
                if [[ -z $filter ]]; then
                    echo "please enter a filter"
                else

                awk -v idxx="$idxx" -v filter="$filter" '
                    BEGIN { FS = ":"; OFS = ":" }
                    {
                        if ($idxx == filter) {
                            next
                        }
                        print $0
                    }
                ' "$PWD/$stbname" > "$PWD/$stbname.tmp" && mv "$PWD/$stbname.tmp" "$PWD/$stbname"

                echo "Rows matching the filter is deleted"
                fi
            fi
        fi
    else
        echo "Table $stbname does not exist."
    fi
else
    echo "Please select a database."
fi

;;
      "updatetable")
    if [[ $PWD == ~/Database/* ]]; then
        while :; do
            read -p "Enter the table name: " stbname
            if [[ -z "$stbname" ]]; then
                echo "Please enter a table name."
            else
                break
            fi
        done

        if [[ -f "$PWD/$stbname" ]]; then
            chmod 777 "$PWD/$stbname"

            while :; do
                read -p "Enter the column name you want to update (column_name): " update_column_name
                if [[ -z "$update_column_name" ]]; then
                    echo "Please enter the column name you want to update."
                else
                    break
                fi
            done

            pkidx=($(awk '
                BEGIN { FS=":" }
                {
                    if ($3 == "pk") {
                        print NR
                    }
                }' "$PWD/.meta$stbname"))

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
                while :; do
                    read -p "Enter the filter column name (column_name): " filter_column_name
                    if [[ -z "$filter_column_name" ]]; then
                        echo "Please enter the filter column name."
                    else
                        break
                    fi
                done

                filter_idxx=0
                filter_flag=0

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
                    while :; do
                        read -p "Enter the filter constraint value: " filter
                        if [[ -z "$filter" ]]; then
                            echo "Please enter a filter constraint value."
                        else
                            break
                        fi
                    done

                    while :; do
                        read -p "Enter the new value for the column to update: " new_value
                        if [[ -z "$new_value" ]]; then
                            echo "Please enter a new value."
                        else
                            break
                        fi
                    done

                    is_valid=0
                    case $colType in
                    "int")
                        if [[ $new_value =~ ^-?[0-9]+$ ]]; then
                            is_valid=1
                        fi
                        ;;
                    "number")
                        if [[ $new_value =~ ^-?[0-9]+$ ]]; then
                            is_valid=1
                        fi
                        ;;
                    "char")
                        if [[ ${#new_value} -eq 1 && $new_value =~ ^[a-zA-Z]$ ]]; then
                            is_valid=1
                        fi
                        ;;
                    "varchar")
                        if [[ $new_value =~ ^[a-zA-Z][a-zA-Z\ ]*$ ]]; then
                            is_valid=1
                        fi
                        ;;
                    "varchar2")
                        if [[ $new_value =~ ^[a-zA-Z][a-zA-Z0-9@._\ -]*$ ]]; then
                            is_valid=1
                        fi
                        ;;
                    *)
                        echo "Unsupported column type: $colType"
                        ;;
                    esac

                    if [[ $is_valid -eq 1 ]]; then
                        if [[ $idxx -eq ${pkidx[0]} ]]; then
                            existing_pk=$(awk -v pk_idx="$idxx" -v pk_value="$new_value" '
                            BEGIN { FS=":" }
                            {
                                if ($pk_idx == pk_value) {
                                    print $0
                                }
                            }' "$PWD/$stbname")

                            if [[ -n $existing_pk ]]; then
                                echo "Error: The primary key value '$new_value' already exists in the table."

                            fi
                        fi

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
                    else
                        echo "Invalid value for column type: $colType"
                    fi
                fi
            fi
        else
            echo "Table $stbname does not exist."
        fi
    else
        echo "Please select a database."
    fi
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
                if [[ $tbname == "" ]]; then
                    echo "please enter table name "
                elif [[ -e "$tbname"  ]]; then
                    rm $tbname
                    rm .meta$tbname
                else
                    echo "table doesn't exist"
                fi

            fi
            ;;
            "back")
                cd ~/Database
                exitFlag=1
                break
                ;;

            *)
                echo UNKNOWN COMMAND
            esac

            done
             if [ "$exitFlag" = 1 ]; then
                break
            fi

                done
            else
                echo "Database doesn't exist"
            fi
            ;;

            "ListDataBases")
            ls ~/Database/
            ;;
            "DropDatabase")
            cd ~/Database/
            read -p "Please enter the database name you want to drop: " dropname
           if [[ $dropname == "" ]]; then
                echo "please enter a database name"
            fi

            if [[ -d "$dropname" ]]; then
                read -p "Are you sure you want to drop the database '$dropname'? (y/n): " confirmation
                if [[ "$confirmation" =~ ^[Yy]$ ]]; then
                    rm -rf "$dropname"
                    echo "Database dropped"
                else
                    echo "Database isn't dropped"
                fi
            else
                echo "please enter existing database name"
            fi
            ;;
        
        "exit")
            exitflag=1
            break
            ;;
        *)
            echo UNKNOWN COMMAND
        esac
        break
done
    if [[ $exitflag == 1 ]]; then
        break
    fi
        done