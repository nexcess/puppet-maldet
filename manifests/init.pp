class maldet (
  String  $version,
  String  $package_name,
  String  $ensure,
  Boolean $daily_scan,
  String  $mirror_url,
  Hash    $config,
  Hash    $cron_config,
  Boolean $cleanup_old_install,
) {

  contain maldet::install
  contain maldet::config

  Class['maldet::install'] ->
  Class['maldet::config']
}
