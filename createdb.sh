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