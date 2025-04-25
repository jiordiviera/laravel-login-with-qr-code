#!/bin/sh

echo "🚀 Démarrage du conteneur Laravel..."

# Attendre que MySQL soit prêt
echo "⏳ Attente de la base de données..."

until nc -z -v -w30 db 3306
do
  echo "⚠️  En attente de MySQL à db:3306..."
  sleep 2
done

echo "✅ Base de données accessible !"

# Afficher les variables d'environnement DB
echo "🔧 Configuration DB détectée :"
env | grep DB_

# Génération de la clé d'application si elle n'existe pas
if [ ! -f .env ]; then
  echo "📄 .env manquant, création à partir de .env.example"
  cp .env.example .env
fi

echo "🔑 Génération de la clé Laravel..."
php artisan key:generate --force

echo "📦 Optimisation de l'application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "🛠️  Lancement des migrations..."
php artisan migrate --force

# Démarrage du serveur avec supervisord
echo "🚦 Démarrage de supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
