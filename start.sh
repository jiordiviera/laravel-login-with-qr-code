#!/bin/sh

# Attendre que la base de données soit prête
sleep 10

# Exécuter les migrations
php artisan migrate --force
cat .env | grep DB_

# Démarrer le serveur
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
