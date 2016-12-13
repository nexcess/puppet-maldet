# Install Linux Malware Detect
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
  # inotify-tools is used by the maldet service
  ensure_packages(['psmisc', 'wget', 'cpulimit', 'inotify-tools', 'perl'])

  file { ['/usr/sbin/maldet', '/usr/sbin/lmd']:
    ensure => link,
    target => '/usr/local/maldetect/maldet',
  }

  if $::facts['os']['family'] == 'Redhat' {
    include ::epel
    Class['epel'] ->
    Package['psmisc'] ->
    Package['wget'] ->
    Package['cpulimit'] ->
    Package['inotify-tools'] ->
    Package['perl']
  }

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
