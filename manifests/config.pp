class maldet::config (
  Hash   $config         = $maldet::config,
  String $config_version = $maldet::config_version,
  String $version        = $maldet::version,
) {
  file { '/usr/local/maldetect/conf.maldet':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => epp("maldet/${config_version}_conf.maldet.epp", $config),
  }
}
