FROM php:8.2-fpm-alpine

# ----------------------------
# Étape 1 : Installation des dépendances système
# ----------------------------
RUN apk add --no-cache \
    nginx \
    supervisor \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    bash \
    busybox-extras \
    mysql-client

# Création du répertoire de logs pour Supervisor
RUN mkdir -p /var/log/supervisor

# ----------------------------
# Étape 2 : Installation des extensions PHP
# ----------------------------
RUN docker-php-ext-install pdo pdo_mysql zip exif pcntl gd

# ----------------------------
# Étape 3 : Installation de Composer
# ----------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ----------------------------
# Étape 4 : Configuration de Nginx
# ----------------------------
COPY docker/nginx/nginx.conf /etc/nginx/http.d/default.conf

# ----------------------------
# Étape 5 : Configuration de Supervisor
# ----------------------------
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ----------------------------
# Étape 6 : Définition du répertoire de travail
# ----------------------------
WORKDIR /var/www/html

# ----------------------------
# Étape 7 : Copie des fichiers de l'application
# ----------------------------
COPY . /var/www/html

# Installation des dépendances PHP (Composer)
RUN composer install --optimize-autoloader --no-dev

# Création des logs Laravel
RUN mkdir -p /var/www/html/storage/logs && \
    touch /var/www/html/storage/logs/laravel.log

# Permissions pour Laravel
RUN chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# ----------------------------
# Étape 8 : Script de démarrage personnalisé
# ----------------------------
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Exposition du port
EXPOSE 80

# Démarrage des services via le script
CMD ["/start.sh"]
