# Backup
docker exec root_db_1 /usr/bin/mysqldump -u wordpress --password=wordpress wordpress > backup.sql

# Restore
# cat backup.sql | docker exec -i root_db_1 /usr/bin/mysql -u wordpress --password=wordpress wordpress
