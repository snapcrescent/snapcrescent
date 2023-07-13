<p align="center"> 
  <br/>  
  <a href="https://opensource.org/license/agpl-v3/"><img src="https://img.shields.io/badge/License-AGPLv3-blue?color=3F51B5&style=for-the-badge&label=License&logoColor=000000&labelColor=ece2ec" alt="License: GNU Affero General Public License version 3"></a>
  <br/>  
  <br/>   
</p>

<h3 align="center">Snapcrescent</h3>
<h4 align="center">Self-hosted photo and video backup solution</h4>

## Demo

Web demo available at [https://demo.snapcrescent.app](https://demo.snapcrescent.app/#/login)

Mobile app can be downloaded from https://github.com/snapcrescent/snapcrescent/releases

```bash title="Credential"
Credential
email: demo-account
password: demo-password
```

# Features

| Features                                     | Mobile | Web |
| -------------------------------------------- | ------ | --- |
| Upload and view videos and photos            | Yes    | Yes |
| Auto backup from app in backgroud            | Yes    | N/A |
| User-defined backup schedule                 | Yes    | N/A |
| Selective folder(s) for backup               | Yes    | N/A |
| Download photos and videos to local device   | Yes    | Yes |
| Multi-user support                           | Yes    | Yes |
| User defined albums                          | No     | Yes |
| Album sharing with other users               | No     | Yes |
| Scrubbable/draggable scrollbar               | Yes    | Yes |
| Archive and Favorites                        | Yes    | Yes |
| Offline support                              | No     | No  |

## Docker Run Commands
Command
```bash title="docker"
docker run
  -d
  --name='SnapCrescent'
  -e TZ="UTC"
  -e 'SQL_DB_TYPE'='MYSQL'
  -e 'SQL_URL'='SQL_URL'
  -e 'SQL_USER'='SQL_USER'
  -e 'SQL_PASSWORD'='SQL_PASSWORD'
  -e 'ADMIN_PASSWORD'='ADMIN_PASSWORD'
  -p '8080:8080/tcp'
  -v 'MEDIA_STORAGE_PATH':'/media':'rw'
  -v 'MEDIA_IMPORT_STORAGE_PATH':'/mnt':'rw'
  'snapcrescent/snapcrescent'
```

Variables
```bash title="variables"
SQL_URL - URL of mysql (jdbc:mysql://IP_ADDRESS:3306/snap-crescent)

SQL_USER - mysql user (root)

SQL_PASSWORD - mysql password

ADMIN_PASSWORD - admin password for login to app

MEDIA_STORAGE_PATH - Local folder path for photos (c/Users/John/Documents/Images)
```

Dependencies
```bash title="dependencies"
MYSQL Dependecies
  1. The application needs 'ONLY_FULL_GROUP_BY' disabled on the db level
  Solution :
  Update mysql serve mode by following  : https://stackoverflow.com/questions/23921117/disable-only-full-group-by
  OR
  Use Mysql Version 5.7.5 or earlier
 

```

Default Login
```bash title="login"
Username : admin
Password : whatever value is added in <ADMIN_PASSWORD> variable while launching docker.
```
