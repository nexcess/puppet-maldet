class maldet (
  String  $version     = $maldet::params::version,
  Boolean $daily_scans = $maldet::params::daily_scans,
  String  $mirror_url  = $maldet::params::mirror_url,
  Hash    $config      = $maldet::params::config,
  String  $config_type = $maldet::params::config_type,
) inherits maldet::params {

  contain maldet::install
  contain maldet::config

  Class['maldet::install'] ->
  Class['maldet::config']
}
