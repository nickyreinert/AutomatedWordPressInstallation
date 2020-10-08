# Automated WordPress Installation
This bash script creates a full WordPress installation (including database and users) with random fake content, plugins and a theme.

# Warning
This script uses **rm -rf** to remove the folder defined with **WP_PATH** if **DROP_WP **is set to **yes**. This script also **removes** the database defined with **DB_NAME** if **DROP_DB** is set to **yes**. Handle with care and **MAKE BACKUPS**.

# Installation
Pull the sources and copy .settings-template to .settings. Edit to fit your requirements.

# Process
This is a rough description of what the script does:

1. download WP CLI from https://wp-cli.org
2. create a new database
3. add a dedicated db user
4. download latest WordPress core files
5. creates a default configuration and install WordPress
6. install a theme
7. install multiple plugins and activate them
8. add multiple parent categories
9. add multiple posts to each parent category, including tags, excerpt, a featured image and revisions
10. add multiple child categories to each parent category 
11. repeat 9 for each child category

# Settings
The scripts reads all settings from the file .settings. The following settings are supported:

    PROJECT=myProject
Name your project. This cab be used as a suffix for database name or installation path. You should not use whitespace or special chars, as the project name will be used in the filesystem and / or database.

## Database settings
**!!!**
**Handle with care - make backups - this parameter will remove the complete database with NO chance to recover it!**
**!!!**

    DB_DROP=yes|no
Do you want to remove the database provideded below before creating a new on? It's recommend to use one database for every single WordPress installation. If you are running tests, you can keep as many WordPress installations on one database. In this case you **must** define a unique DB_PREFIX for every installation.

    DB_HOST=127.0.0.1
The adress of your database, ip adress
    DB_ROOT=user
    DB_ROOT_PASSWORD=password
The root user that allows the script to add a database or add a user. You don't need those parameters if database and user does exist.

    CREATE_DB=yes|no
Do you want to create a new database? If set to no, make sure that a database exists and credentials from below are valid. If yes, simply provide required details with the next two parameters. 
    DB_NAME="${PROJECT}_database"
    DB_PREFIX="wp_"
The settings will be used to create a database and, apparently, later as the WordPress setup process. 

    ADD_DB_USER=yes|no
Do you want to create a database user? If no, you need to provide a user that has access to the database named above. If you want to add a new user, a root user needs to be set. You may use your own password or use the "built-in" random function:

    DB_USER="${PROJECT}_dbuser"
    DB_USER_PASSWORD=secret # or use this: $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

## General WordPress Settings
    INSTALL_CORE=yes|no
Do you want to install WordPress from the scratch? If set to no, the script expects a working installation in the destination folder

    WP_PATH="/var/nginx/htdocs/${PROJECT}/"
The path to your installation. You can use the PROJECT place holder here. Make sure, that the parent path is writable. 

**!!!**
**Handle with care - make backups - this parameter will remove the complete WordPress folder with NO chance to recover it!**
**!!!**

    WP_DROP=yes|no
Do you want to remove the destination folder before installing WordPress?

    WP_TITLE='WordPress AutoTagger'
The title of your WordPress installation
    URL="https://wordpress.example.org/${PROJECT}"
The URL under that points to your installation.

    WP_ADMIN_NAME=admin
    WP_ADMIN_EMAIL=mail@example.com
    WP_ADMIN_PASSWORD=secret # or use this: $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
Provide admin credentials for your WordPress installation. Again, you may provide a password or use a random function.

    INSTALL_THEME=yes|no
    THEME=hello-elementor
Do you want to install a theme? If yes, provide the slug of the theme. 

    INSTALL_PLUGINS=yes|no
    PLUGINS="elementor wordpress-seo tinymce-advanced ninja-forms shortcodes-ultimate instagram-feed ml-slider the-events-calendar amp contact-widgets coblocks woocommerce"
Do you want to install plugins? If yes, provide the slug of one or more plugins, separated by space

## Content
    ADD_CONTENT=yes|no
Do you want to add posts?  

    META_INPUT='{"_elementor_edit_mode":"<![CDATA[builder]]>","_elementor_template_type":"<![CDATA[kit]]>","_elementor_version":"<![CDATA[2.9.13]]>"}'
Some e.g. Themes expect special information within the post meta data. You can define them here. They will be added to every created post.

    RANDOMIZE_EVERY_ITEM=yes|no
If set to yes, every category, tag, post, post excerpt and post title and even image will be randomized, this cost a lot of time, because it leads to a couple of HTTP requests.
If set to no, we only query each API once to get one random item and re-use it every time. 

    COUNT_POSTS=1
How many post do you want to create? If set to 0, no post will be created. 

    COUNT_PARAGRAPHS=1
How many paragraphs each post should have? 

    COUNT_POST_REVISIONS=1
How many post revisions do you need? If set to 0, no post revision will be created. 

    COUNT_TAGS=0
How many tags do you want to add to every post? If set to 0, no tag will be added. 

    COUNT_CATEGORIES_LEVEL1=1
    COUNT_CATEGORIES_LEVEL2=0
This script will create two levels of categories. You you can define how many categories you need. Be aware that for every category in level 1 the defined amount of categories in level 2 will be created. If you define level1 = 10 and level2 = 10, you will get 100 categories. 

## Misc settings
*(you do not need to change the following settings)*

    WP_CLI_EXEC=~/wp-cli.phar
This script requires WP CLI. Provide a location here. If WP CLI does not exist on this location, the script will download it. 

    WP_CLI_SOURCE=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
The source of WP CLI. 

Those are the URL to some APIs delivering random text, words or images. You should not change them, as the script is build to work with them only. 

    RANDOM_WORD_API_URL='https://random-word-api.herokuapp.com/word?swear=0&number='
This API delivers single words for the tags.     

    RANDOM_SENTENCE_API_URL='http://metaphorpsum.com/sentences/'
This API delivers sentences for post titles.

    RANDOM_TEXT_API_URL='http://metaphorpsum.com/paragraphs/'
This API delivers random texts for the post content.

    RANDOM_IMAGE_API_URI='https://picsum.photos/200/300.jpg'
Last not least, an API to get random images.

# Used 3rd party ressources
This script uses following API to create random tags, categories, sentences, paragraphs and images:

* https://random-word-api.herokuapp.com/word?swear=0&number=1
* http://metaphorpsum.com/sentences/
* http://metaphorpsum.com/paragraphs/
* https://picsum.photos/



# Notice
A a German translation and instruction can be found here:
https://www.nickyreinert.de/automatisierte-wordpress-installation/
