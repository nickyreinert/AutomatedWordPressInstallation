#!/bin/bash 
function removeDatabaseCredentials {

	rm ./.mysql-credentials.cnf

}

function setDatabaseCredentials {

		# creating temporary credentials file
        CREDENTIALS_FILE=./.mysql-credentials.cnf
        echo "[client]" > $CREDENTIALS_FILE
        echo "user=$DB_ROOT" >> $CREDENTIALS_FILE
        echo "password=$DB_ROOT_PASSWORD" >> $CREDENTIALS_FILE
        echo "host=$DB_HOST" >> $CREDENTIALS_FILE

}

function createCategory {

	if [[ "$RANDOMIZE_EVERY_ITEM" == "yes" || -z "$CATEGORY_DESC_LEVEL1" ]]
	then 

		CATEGORY_DESC_LEVEL1=$(curl -s "$RANDOM_SENTENCE_API_URL"1)

	fi
	
	CATEGORY_ID=$(wp term create category "$1" \
		--path=$WP_PATH \
		--description="$CATEGORY_DESC_LEVEL1" | grep -o -E '[0-9]+')

}

function getPostTitle {

	if [[ "$RANDOMIZE_EVERY_ITEM" == "yes" || -z "$POST_TITLE_LEVEL1" ]]
	then 
	
		POST_TITLE_LEVEL1=$(curl -s "$RANDOM_SENTENCE_API_URL"1)
		
	fi

}

function getPostContent {


	if [[ "$RANDOMIZE_EVERY_ITEM" == "yes" || ! -f .tempPost ]]
	then

		curl -s $RANDOM_TEXT_API_URL$COUNT_PARAGRAPHS > .tempPost
	
	fi

}

function getPostExcerpt {

	if [[ "$RANDOMIZE_EVERY_ITEM" == "yes" || -z "$POST_EXCERPT_LEVEL1" ]]
	then 
	
		POST_EXCERPT_LEVEL1=$(curl -s "$RANDOM_SENTENCE_API_URL"1)
		
	fi

}

function getPostTags {


	if [[ "$RANDOMIZE_EVERY_ITEM" == "yes" || -z "$TAGS_LEVEL1" ]]
	then 

		JSON_TAGS_LEVEL1=$(curl -s $RANDOM_WORD_API_URL$COUNT_TAGS)

		TAGS_LEVEL1=$(echo "${JSON_TAGS_LEVEL1//[\"|\]]}" | sed 's/\[//g')

	fi
	
}

function getPostImage {


	if [[ "$RANDOMIZE_EVERY_ITEM" == "yes" || ! -f .tempImage.jpg ]]
	then
		
		curl --silent --output .tempImage.jpg --location $RANDOM_IMAGE_API_URI
		IMAGE_TITLE_LEVEL1=$(curl -s "$RANDOM_SENTENCE_API_URL"1)

	fi


}

function createPost {


	getPostTitle
	
	getPostContent
	
	getPostExcerpt	
	
	getPostTags
	
	POST_ID=$(wp post create .tempPost \
			--path=$WP_PATH \
			--post_title="$POST_TITLE_LEVEL1" \
			--post_status="publish" \
			--post_category="$CATEGORY_ID" \
			--tags_input="$TAGS_LEVEL1" \
			--post_excerpt="$POST_EXCERPT_LEVEL1" \
			--meta_input="$META_INPUT" | grep -o -E '[0-9]+')

	getPostImage
	
	# add one featured image to post
	wp media import .tempImage.jpg \
		--path=$WP_PATH \
		--post_id=$POST_ID \
		--title="$IMAGE_TITLE_LEVEL1" \
		--featured_image \
		--quiet

	# create revisions
	echo -e "\r\nCreating $COUNT_POST_REVISIONS post revisions..."
	POST_REVISION_INDEX=1
	while [ $POST_REVISION_INDEX -le $COUNT_POST_REVISIONS ]
	do
		echo -e ".\c"
	
		getPostContent

		wp post update $POST_ID \
			.tempPost \
			--path=$WP_PATH \
			--post_name=something \
			--quiet
	
		((POST_REVISION_INDEX++))

	done

	# add additional image to post
	getPostImage

	wp media import .tempImage.jpg \
		--path=$WP_PATH \
		--post_id=$POST_ID \
		--title="$IMAGE_TITLE_LEVEL1"

	echo "...Done"

}