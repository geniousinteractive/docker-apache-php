# Docker-compose
## Use this docker-compose.yml to create a complete development environment using several Actency Docker images:

    version: '2'
	services:
	  web:
	    image: geniousinteractive/docker-apache-php:5.6
	    ports:
	      - "80:80"
	    environment:
	      - SERVERNAME=domaine.dd
	      - SERVERALIAS=*.domaine.dd
	    volumes:
	      - ./source:/var/www/html/
	    links:
	      - database:mysql
	      - mailhog
	      - memcache
	      - solr
	    tty: true
	  database:
	    image: geniousinteractive/docker-mysql:mariadb
	    environment:
	      MYSQL_ALLOW_EMPTY_PASSWORD: 'yes'
	  phpmyadmin:
	    image: geniousinteractive/docker-phpmyadmin
	    ports:
	      - "8010:80"
	    environment:
	      - MYSQL_ROOT_PASSWORD=
	      - UPLOAD_SIZE=2G
	    links:
	      - database:mysql
	  mailhog:
	    image: mailhog/mailhog
	    ports:
	      - "1025:1025"
	      - "8025:8025"
	  memcache:
	    image: memcached
	    ports:
	      - "11211:11211"
	    command: memcached -m 64
	  solr:
	    image: actency/docker-solr:4.10
	    ports:
	      - "8983:8983"
	#
	#	DEBUG
	#
	#  web-prof:
	#    image: actency/docker-apache-php-xhprof:5.6
	#    ports:
	#      - "8050:80"
	#    environment:
	#      - SERVERNAME=isover.dd
	#      - SERVERALIAS=*.isover.dd
	#    volumes:
	#      - ./isover-master/docroot:/var/www/html/
	#      - ./root:/root/
	#    links:
	#      - database:mysql
	#      - mailhog
	#      - memcache
	#      - solr
	#    tty: true
	#   # mongo container - official images
	#  mongo:
	#     image: mongo
	#     ports:
	#       - "27017:27017"
	#   # xhgui container - actency image
	#  xhgui:
	#     image: actency/docker-xhgui
	#     ports:
	#       - "8040:80"
	#     links:
	#       - mongo
	#  varnish:
	#    image: wodby/drupal-varnish
	#    depends_on:
	#      - web
	#    environment:
	#      VARNISH_SECRET: secret
	#      VARNISH_BACKEND_HOST: web
	#      VARNISH_BACKEND_PORT: 80
	#      VARNISH_MEMORY_SIZE: 256M
	#      VARNISH_STORAGE_SIZE: 1024M
	#    ports:
	#      - "8081:6081" # HTTP Proxy
	#      - "8005:6082" # Control terminal

