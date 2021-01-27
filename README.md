# snap-crescent

## Docker Run Commands

### SQL

docker run -d -e ENV=sql -e SQL_URL=YOUR_DB_URL -e SQL_USER=YOUR_DB_USER -e SQL_PASSWORD=YOUR_DB_PASSWORD -v LOCAL_PHOTO_FOLDER_PATH:/media -p 8080:8080 thecodeinsight/snapcrescent:1.0

### SQLITE

docker run -d -e ENV=sqlite -v LOCAL_PHOTO_FOLDER_PATH:/media -v LOCAL_DB_FOLDER_PATH:/db -p 8080:8080 thecodeinsight/snapcrescent:1.0

#### Variables :
SQL_URL - URL of mysql (jdbc:mysql://IP_ADDRESS:3306/snap-crescent)

SQL_USER - mysql user (root)

SQL_PASSWORD - mysql password

LOCAL_PHOTO_FOLDER_PATH - Local folder path for photos (c/Users/John/Documents/Images)

LOCAL_DB_FOLDER_PATH - Local folder path for SQLITE DB (c/Users/John/Documents/db)