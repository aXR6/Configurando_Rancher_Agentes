<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.locking' => '\\OC\\Memcache\\Redis', // Adicionado para Redis
  'redis' => array( // Configurações do Redis
    'host' => 'redis',
    'port' => 6379,
    'password' => '36HBpD',
  ),
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'upgrade.disable-web' => true,
  'instanceid' => 'ocy0cs0e8kt5',
  'passwordsalt' => 'f/jf00gfPGyyskbF8T0CksAUdl1jt+',
  'secret' => '+m0v9rcpRFNlg9ET77BTONe2SwlSqCa/r+LmuxQbk298P6Qd',
  'trusted_domains' => 
  array (
    0 => '192.168.3.202',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  'version' => '30.0.2.2',
  'overwrite.cli.url' => 'http://192.168.3.202',
  'dbname' => 'nextcloud',
  'dbhost' => 'nextcloud_db',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => '36HBpD61l)Lj',
  'installed' => true,
  'maintenance' => false,
  'backgroundjobs_mode' => 'cron',
  'maintenance_window_start' => '15:00',
  'default_phone_region' => 'BR',
  'files_external_allow_new_local' => true,
);
