FROM php:8.2-fpm-alpine

# Installation des dépendances système
RUN apk add --no-cache \
    nginx \
    supervisor \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl

# Création du répertoire de logs pour Supervisor
RUN mkdir -p /var/log/supervisor

# Installation des extensions PHP nécessaires
RUN docker-php-ext-install pdo pdo_mysql zip exif pcntl gd

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration de Nginx
COPY docker/nginx/nginx.conf /etc/nginx/http.d/default.conf

# Configuration de Supervisor
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Définition du répertoire de travail
WORKDIR /var/www/html

# Copie des fichiers de l'application
COPY . /var/www/html

# Installation des dépendances PHP
RUN composer install --optimize-autoloader

# Copier .env.example en .env (si nécessaire)
RUN cp .env.example .env || echo "No .env.example file found"

# Génération de la clé d'application
RUN php artisan key:generate --force

# Optimisation pour la production
RUN php artisan optimize

# Permissions pour le stockage
RUN chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Rendre le script de démarrage exécutable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Exposition du port
EXPOSE 80

# Démarrage des services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Démarrage des services avec notre script personnalisé
CMD ["/start.sh"]
