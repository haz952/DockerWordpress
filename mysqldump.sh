# Backup
docker exec mysql:5.7 /usr/bin/mysqldump -u root --password=wordpress DATABASE > backup.sql
