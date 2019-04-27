#!/bin/bash

# --http-cache-hosts is not a valid argument for the entrypoint
# because in case it had already been set, the new value might overwrite correct previous values
# Optional arguments and their default values:
# AMQP_VIRTUALHOST: /
# AMQP_SSL: ""
# AMQP_SSL_OPTIONS: ""
# DB_MODEL: mysql4
# DB_PREFIX: ""
# DB_ENGINE: innodb
# SESSION_SAVE_REDIS_PASSWORD: ""
# SESSION_SAVE_REDIS_TIMEOUT: 10
# SESSION_SAVE_REDIS_PERSISTENT_ID: ""
# SESSION_SAVE_REDIS_DB: 1
# SESSION_SAVE_REDIS_COMPRESSION_LIB: gzip
# SESSION_SAVE_REDIS_LOG_LEVEL: 0
# SESSION_SAVE_REDIS_MAX_CONCURRENCY: 12
# CACHE_BACKEND: Cm_Cache_Backend_Redis
# PAGE_CACHE: Cm_Cache_Backend_Redis

if [ "${SKIP_MAGENTO_COMMANDS}" == "true" ]; then

php /var/www/bin/magento setup:config:set \
    --backend-frontname="$BACKEND_FRONTNAME" \
    --key="${KEY}" \
    --amqp-host="$AMQP_HOST" \
    --amqp-port="$AMQP_PORT" \
    --amqp-user="$AMQP_USER" \
    --amqp-password="$AMQP_PASSWORD" \
    --amqp-virtualhost="${AMQP_VIRTUALHOST:-/}" \
    --amqp-ssl="${AMQP_SSL:-}" \
    --amqp-ssl-options="${AMQP_SSL_OPTIONS:-}" \
    --db-host="$DB_HOST" \
    --db-name="$DB_NAME" \
    --db-user="$DB_USER" \
    --db-engine="${DB_ENGINE:-innodb}" \
    --db-password="$DB_PASSWORD" \
    --db-prefix="${DB_PREFIX:-}" \
    --db-model="$DB_MODEL:-mysql4" \
    --session-save="${SESSION_SAVE}"
    --session-save-redis-host="${SESSION_SAVE_REDIS_HOST}"
    --session-save-redis-port="${SESSION_SAVE_REDIS_PORT}"
    --session-save-redis-timeout="${SESSION_SAVE_REDIS_TIMEOUT:-10}"
    --session-save-redis-persistent-id="${SESSION_SAVE_REDIS_PERSISTENT_ID:-}"
    --session-save-redis-db="${SESSION_SAVE_REDIS_DB:-1}"
    --session-save-redis-compression-lib="${SESSION_SAVE_REDIS_COMPRESSION_LIB:-gzip}"
    --session-save-redis-log-level="${SESSION_SAVE_REDIS_LOG_LEVEL:-0}"
    --session-save-redis-max-concurrency="${SESSION_SAVE_REDIS_MAX_CONCURRENCY:-12}"
    --cache-backend="${CACHE_BACKEND:-Cm_Cache_Backend_Redis}"
    --cache-backend-redis-server="${CACHE_BACKEND_REDIS_SERVER}"
    --cache-backend-redis-db="${CACHE_BACKEND_REDIS_DB}"
    --cache-backend-redis-port="${CACHE_BACKEND_REDIS_PORT}"
    --page-cache="${PAGE_CACHE:-Cm_Cache_Backend_Redis}"
    --page-cache-redis-server="${PAGE_CACHE_REDIS_SERVER}"
    --page-cache-redis-db="${PAGE_CACHE_REDIS_DB}"
    --page-cache-redis-port="${PAGE_CACHE_REDIS_PORT}"
    --page-cache-redis-compress-data="${PAGE_CACHE_REDIS_COMPRESS_DATA}"

php /var/www/bin/magento deploy:mode:set --skip-compilation "$MAGE_MODE"

fi

# If either PHP or Nginx dies, the container exits
php-fpm -F &
fpm_pid=$!
nginx -g "daemon off;" &
nginx_pid=$!

while [ -d /proc/$fpm_pid ] && [ -d /proc/$nginx_pid ] ; do
    sleep 1
done
