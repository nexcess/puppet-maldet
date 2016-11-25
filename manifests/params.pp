class maldet::params {
  $version     = '1.5'
  $daily_scans = true
  $mirror_url  = 'http://www.rfxn.com/downloads/'
  $config      = {}
  $config_type = ''

  # Use separate template for Maldetect versions < 1.5
  if $config_type != '' {
    $config_version = $config_type
  } elsif versioncmp($version, '1.5') >= 0 {
    $config_version = 'new'
  } else {
    $config_version = 'old'
  }
}
