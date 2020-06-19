# Installer Wordpress grâce à Docker-Compose

Docker Compose est un outil qui permet de décrire (dans un fichier YAML) et gérer (en ligne de commande) plusieurs conteneurs comme un ensemble de services inter-connectés.

Dans notre cas, nous aurons besoin d'installer 2 services pour faire fonctionner Wordpress (Apache et Mysql), donc 2 conteneurs.

Nous avons aussi décider d'ajouter un service adminer, ici phpmyadmin, pour pouvoir administrer notre base de donnée Mysql
ainsi que Portainer, une interface de gestion open source et légère pour gérer nos contenaires Docker. 

Nous allons commencer par créer un fichier yaml : docker-compose.yml

#Fichier de conf docker-compose

version: '3.3'  # Il s'agit de la version utilisé pour docker-compose

#MYSQL

    services:
        db:
            image: mysql:5.7
            ports:
                - "3306:3306"
            volumes:
                - db_data:/var/lib/mysql
            restart: always
            environment:
                MYSQL_ROOT_PASSWORD: wordpress
                MYSQL_DATABASE: wordpress
                MYSQL_USER: wordpress
                MYSQL_PASSWORD: wordpress
            
 #WORDPRESS
            
    wordpress:
        depends_on:
            - db
        image: wordpress:latest
        ports:
            - "8000:80"
        restart: always
        environment:
            WORDPRESS_DB_HOST: db:3306
            WORDPRESS_DB_USER: wordpress
            WORDPRESS_DB_PASSWORD: wordpress
            WORDPRESS_DB_NAME: wordpress
            
 #PHPMYADMIN
        
    phpmyadmin:
        depends_on:
            - db
        image: phpmyadmin/phpmyadmin
        ports:
            - "8080:80"
        restart: always
        environment:
            MYSQL_ROOT_PASSWORD: wordpress
            MYSQL_DATABASE: wordpress
            MYSQL_USER: wordpress
            MYSQL_PASSWORD: wordpress
            
#PORTAINER

    portainer:
        image: portainer/portainer
        command: -H unix:///var/run/docker.sock
        restart: always
        ports:
            - "9000:9000"
            - "8081:8000"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - portainer_data:/dat

volumes:
    db_data: {}
    portainer_data:
    

# Sauvegarde Base de donnée mysql :

Nous allons, ici, sauvegarder la base de donnée MYSQL a l'aide d'un script et d'une cron pour l'automatisation.

Il faut, premièrement, créer un script de ce type : nomdufichier.sh

Il s'agit d'un fichier qui devra s'éxécuter, donc il doit être éxécutable : chmod u+x nomdufichier.sh

Dans ce fichier, ajouter cette commande en modifiant les champs en MAJ : 

# Backup
docker exec NOMDUCONTAINER /usr/bin/mysqldump -u USER --password=MOTDEPASSE DATABASE > backup.sql

# Restore
cat backup.sql | docker exec -i NOMDUCONTAINER /usr/bin/mysql -u USER --password=MOTDEPASSE DATABASE

Enfin, il faut configurer la cron pour éxécuter ce script automatiquement

Installer le service cron sur votre machine : apt-get install cron

puis modifier le fichier /etc/crontab

Ajouter une ligne à la fin du fichier qui va éxécuter ici le script toutes les minutes : 

*/1 * * * * root /root/mysqldump.sh

Pour vérifier que cela fonctionne, vérifiez qu'un fichier backup.sql s'est crée et que le contenu de la base sql y soit :)
