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

cat<<EOF > /var/www/app/etc/env.php
<?php
return array (
  'backend' => 
  array (
    'frontName' => '${BACKEND_FRONTNAME:-admin}',
  ),
  'db' => 
  array (
    'connection' => 
    array (
      'default' => 
      array (
        'host' => '${DB_HOST}',
        'dbname' => '${DB_NAME}',
        'username' => '${DB_USER}',
        'password' => '${DB_PASSWORD}',
        'model' => 'mysql4',
        'engine' => 'innodb',
        'initStatements' => 'SET NAMES utf8;',
        'active' => '1',
      ),
      'indexer' => 
      array (
        'host' => '${DB_HOST}',
        'dbname' => '${DB_NAME}',
        'username' => '${DB_USER}',
        'password' => '${DB_PASSWORD}',
        'active' => '1',
        'persistent' => NULL,
      ),
    ),
    'table_prefix' => '',
  ),
  'crypt' => 
  array (
    'key' => '${KEY}',
  ),
  'resource' => 
  array (
    'default_setup' => 
    array (
      'connection' => 'default',
    )
  ),
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'production',
  'session' => 
  array (
    'save' => 'redis',
    'redis' => 
    array (
      'host' => '${SESSION_SAVE_REDIS_HOST}',
      'port' => '${SESSION_SAVE_REDIS_PORT:-6379}',
      'password' => '',
      'timeout' => '${SESSION_SAVE_REDIS_TIMEOUT:-10}',
      'persistent_identifier' => '${SESSION_SAVE_REDIS_PERSISTENT_ID:-}',
      'database' => '${SESSION_SAVE_REDIS_DB:-1}',
      'compression_threshold' => '2048',
      'compression_library' => '${SESSION_SAVE_REDIS_COMPRESSION_LIB:-gzip}',
      'log_level' => '${SESSION_SAVE_REDIS_LOG_LEVEL:-1}',
      'max_concurrency' => '${SESSION_SAVE_REDIS_MAX_CONCURRENCY:-12}',
      'break_after_frontend' => '5',
      'break_after_adminhtml' => '30',
      'first_lifetime' => '600',
      'bot_first_lifetime' => '60',
      'bot_lifetime' => '7200',
      'disable_locking' => '0',
      'min_lifetime' => '60',
      'max_lifetime' => '2592000',
    ),
  ),
  'cache_types' => 
  array (
    'config' => 1,
    'layout' => 1,
    'block_html' => 1,
    'collections' => 1,
    'reflection' => 1,
    'db_ddl' => 1,
    'eav' => 1,
    'customer_notification' => 1,
    'target_rule' => 1,
    'full_page' => 1,
    'config_integration' => 1,
    'config_integration_api' => 1,
    'config_webservice' => 1,
    'translate' => 1,
    'vertex' => 1
  ),
  'cache' => 
  array (
    'frontend' => 
    array (
      'default' => 
      array (
        'backend' => 'Cm_Cache_Backend_Redis',
        'backend_options' => 
        array (
          'server' => '${CACHE_BACKEND_REDIS_SERVER}',
          'port' => '${CACHE_BACKEND_REDIS_PORT}',
          'database' => '${CACHE_BACKEND_REDIS_DB}',
          'persistent' => '',
          'force_standalone' => '0',
          'connect_retries' => '3',
          'read_timeout' => '10',
          'automatic_cleaning_factor' => '0',
          'compress_data' => '1',
          'compress_tags' => '0',
          'compress_threshold' => '20480',
          'compression_lib' => 'gzip',
          'disable_locking' => '0',
        ),
      ),
      'page_cache' => 
      array (
        'backend' => 'Cm_Cache_Backend_Redis',
        'backend_options' => 
        array (
          'server' => '${PAGE_CACHE_REDIS_SERVER}',
          'port' => '${PAGE_CACHE_REDIS_PORT}',
          'database' => '${PAGE_CACHE_REDIS_DB}',
          'persistent' => '',
          'force_standalone' => '0',
          'connect_retries' => '3',
          'read_timeout' => '10',
          'automatic_cleaning_factor' => '0',
          'compress_data' => '1',
          'compress_tags' => '0',
          'compress_threshold' => '20480',
          'compression_lib' => 'gzip',
          'disable_locking' => '0',
        ),
      ),
    ),
  ),
  'install' => 
  array (
    'date' => 'Thu, 01 Jan 1970 00:00:00 +0000',
  ),
);

EOF

php /var/www/bin/magento cache:enable
php /var/www/bin/magento deploy:mode:set --skip-compilation "$MAGE_MODE"

# If either PHP or Nginx dies, the container exits
php-fpm -F &
fpm_pid=$!
nginx -g "daemon off;" &
nginx_pid=$!

if [ "$1" == "--run-cron" ] ; then
    su magento -c "php /var/www/bin/magento cron:run"
    exit $?
fi

while [ -d /proc/$fpm_pid ] && [ -d /proc/$nginx_pid ] ; do
    sleep 1
done
