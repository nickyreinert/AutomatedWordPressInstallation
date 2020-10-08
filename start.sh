#! /bin/bash
if [ ! -f .settings ]
then
	echo "Please create .settings-file from .settings-template first."
	exit -1
fi

source .settings
source functions.sh

if [ ! -w "$WP_PATH" ]
then
        echo "Cannot write destination folder $WP_PATH"
        exit -1
fi

if [ ! -f ${WP_CLI_EXEC} ]
then
	echo "Installing WP CLI..."
	curl -O $WP_CLI_SOURCE --silent
	mv wp-cli.phar ${WP_CLI_EXEC}
	chmod +x ${WP_CLI_EXEC}
	echo "...Done"
fi

if [ $CREATE_DB == "yes" ]
then
        echo "Creating database..."

		setDatabaseCredentials

        CHECK_DB_NAME=$(
                /usr/bin/mysql \
                --defaults-extra-file=$CREDENTIALS_FILE \
                --skip-column-names \
                --silent \
                --execute "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME';"
                )

        if [[ ${CHECK_DB_NAME} == ${DB_NAME} ]]
        then
                echo "Database $DB_NAME already exists!"
                if [ $DB_DROP == "yes" ]
                then
                        echo "Removing database $DB_NAME..."
                        /usr/bin/mysql \
                                --defaults-extra-file=$CREDENTIALS_FILE \
                                --execute "DROP DATABASE $DB_NAME";
                        echo "...Done"
				else 
	
					exit -1	

                fi

        fi

        /usr/bin/mysql \
                --defaults-extra-file=$CREDENTIALS_FILE \
                --execute "CREATE DATABASE $DB_NAME";

		removeDatabaseCredentials

        echo "...Done"

fi

if [ $ADD_DB_USER == "yes" ]
then

        echo "Adding DB user..."

		setDatabaseCredentials

        /usr/bin/mysql \
                --defaults-extra-file=$CREDENTIALS_FILE \
                --execute "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_USER_PASSWORD'";

		removeDatabaseCredentials

        echo "...Done"

fi

if [ $INSTALL_CORE == "yes" ] 
then

	if [ ! -d $WP_PATH ]
	then
		echo "Creating $WP_PATH..."
		mkdir -p $WP_PATH
	elif [ $WP_DROP == "yes" ]
	then
		echo "Removing $WP_PATH/*..."
		rm -rf $WP_PATH/*
	fi
	echo "...Done"

	echo "Dowloading WordPress..."
	wp core download \
		--path=$WP_PATH \
		--quiet
	echo "...Done"

	echo "Installing WordPress..."
	wp core config \
		--path=$WP_PATH \
		--dbhost=$DB_HOST \
		--dbname=$DB_NAME \
		--dbprefix=$DB_PREFIX \
		--dbuser=$DB_USER \
		--dbpass=$DB_USER_PASSWORD \
		--quiet

	wp core install \
		--path=$WP_PATH \
		--url=$URL \
		--title="$WP_TITLE" \
		--admin_user=$WP_ADMIN_NAME \
		--admin_password=$WP_ADMIN_PASSWORD \
		--admin_email=$WP_ADMIN_EMAIL \
		--quiet

	echo "...Done, WordPress admin's password is $WP_ADMIN_PASSWORD"

fi 

if [ $INSTALL_THEME == "yes" ] 
then
	echo "Installing theme..."
	wp theme install $THEME \
		--path=$WP_PATH \
		--activate \
		--quiet 
	echo "...Done"
fi

if [ $INSTALL_PLUGINS == "yes" ] 
then
	echo "Installing plugins..."

	wp plugin install $PLUGINS \
		--path=$WP_PATH \
		--activate \
		--quiet
	echo "...Done"
fi

if [ $ADD_CONTENT == "yes" ] 
then
	echo "Creating $COUNT_CATEGORIES_LEVEL1 catgories..."

	JSON_CATEGORIES_LEVEL1=$(curl -s $RANDOM_WORD_API_URL$COUNT_CATEGORIES_LEVEL1)

	CATEGORIES_LEVEL1=$(echo "${JSON_CATEGORIES_LEVEL1//[\"|\]]}" | sed 's/\[//g')

	IFS=',' read -a ARR_CATEGORIES_LEVEL1 <<< "$CATEGORIES_LEVEL1"

	POST_TITLE_LEVEL1="" # make this parameter global
	POST_EXCERPT_LEVEL1="" # make this parameter global
	TAGS_LEVEL1="" # make this parameter global
	IMAGE_TITLE_LEVEL1="" # make this parameter global
	CATEGORY_DESC_LEVEL1="" # make this parameter global

	# create parent categories
	for CATEGORIE_LEVEL1 in "${ARR_CATEGORIES_LEVEL1[@]}"
	do

		createCategory $CATEGORIE_LEVEL1

		# create posts
		echo "Creating $COUNT_POSTS posts..."
		POST_INDEX=1
		while [ $POST_INDEX -le $COUNT_POSTS ]
		do
			echo -e ".\c"
			createPost
			((POST_INDEX++))
			
		done
		echo "...Done"

		if [ "$COUNT_CATEGORIES_LEVEL2" -gt 0 ]
		then
		
			echo -e "\r\nCreating $COUNT_CATEGORIES_LEVEL2 sub categories..."
			# create child categories

			if [[ "$RANDOMIZE_EVERY_ITEM" == "yes"  ]]
			then

				JSON_CATEGORIES_LEVEL2=$(curl -s $RANDOM_WORD_API_URL$COUNT_CATEGORIES_LEVEL2)

				CATEGORIES_LEVEL2=$(echo "${JSON_CATEGORIES_LEVEL2//[\"|\]]}" | sed 's/\[//g')

				IFS=',' read -a ARR_CATEGORIES_LEVEL2 <<< "$CATEGORIES_LEVEL2"
				
			else 
			
				ARR_CATEGORIES_LEVEL2=$ARR_CATEGORIES_LEVEL1
				
			fi

			for CATEGORIE_LEVEL2 in "${ARR_CATEGORIES_LEVEL2[@]}"
			do

				createCategory $CATEGORIE_LEVEL2

				# create posts
				echo "Create $COUNT_POSTS posts in sub category"		
				POST_INDEX=1
				while [ $POST_INDEX -le $COUNT_POSTS ]
				do
					echo -e ".\c"
					createPost
					((POST_INDEX++))
					
				done
				echo "...Done"

			done
			
		fi

	done

    rm .tempPost
    rm .tempImage.jpg

fi