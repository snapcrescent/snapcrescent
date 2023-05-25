<p align="center"> 
  <br/>  
  <a href="https://opensource.org/license/agpl-v3/"><img src="https://img.shields.io/badge/License-AGPLv3-blue?color=3F51B5&style=for-the-badge&label=License&logoColor=000000&labelColor=ece2ec" alt="License: GNU Affero General Public License version 3"></a>
  <br/>  
  <br/>   
</p>

# snap-crescent

## Docker Run Commands

docker run -d 'SQL_DB_TYPE'='MYSQL' -e 'SQL_URL'='YOUR_DB_URL' -e 'SQL_USER'='YOUR_DB_USER' -e 'SQL_PASSWORD'='SQL_PASSWORD' -e 'ADMIN_PASSWORD'='ADMIN_PASSWORD' -v 'MEDIA_STORAGE_PATH':'/media':'rw' -v 'DATA_PATH':'/db':'rw' -v 'MEDIA_IMPORT_STORAGE_PATH':'/mnt':'rw' 'thecodeinsight/snapcrescent':1.0

#### Variables :
SQL_URL - URL of mysql (jdbc:mysql://IP_ADDRESS:3306/snap-crescent)

SQL_USER - mysql user (root)

SQL_PASSWORD - mysql password

MEDIA_STORAGE_PATH - Local folder path for photos (c/Users/John/Documents/Images)

DATA_PATH - Local folder path for SQLITE DB (c/Users/John/Documents/db)

MEDIA_IMPORT_STORAGE_PATH - Local folder path for importing photos (c/Users/John/Documents/Images)
