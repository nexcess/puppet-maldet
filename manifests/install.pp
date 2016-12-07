class maldet::install (
  String  $version             = $maldet::version,
  String  $mirror_url          = $maldet::mirror_url,
  String  $package_name        = $maldet::package_name,
  String  $ensure              = $maldet::ensure,
  Boolean $cleanup_old_install = $maldet::cleanup_old_install,
) {

  # killall is used by install.sh
  # cpulimit is used for the scan_cpulimit config option
  # wget is used for signature & version updates
  ensure_packages(['psmisc', 'wget', 'cpulimit'])

  if $package_name == '' {
    maldet { $mirror_url :
      ensure              => $ensure,
      version             => $version,
      cleanup_old_install => $cleanup_old_install,
    }
  } else {
    package { $package_name:
      ensure => $ensure,
    }
  }
}
