# Install Linux Malware Detect
class maldet::install (
  String  $version             = $maldet::version,
  String  $mirror_url          = $maldet::mirror_url,
  String  $release_url         = $maldet::release_url,
  Optional[Pattern[/\A[0-9a-f]{64}\z/]] $checksum = $maldet::checksum,
  String  $package_name        = $maldet::package_name,
  String  $ensure              = $maldet::ensure,
  Boolean $cleanup_old_install = $maldet::cleanup_old_install,
  Boolean $manage_epel         = $maldet::manage_epel,
) {
  # killall is used by install.sh
  # wget is used for signature & version updates
  # inotify-tools is used by the maldet service
  ensure_packages(['psmisc', 'wget', 'inotify-tools', 'perl'])

  # cpulimit is used for the scan_cpulimit config option
  # it is not available in epel for el9
  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '9') < 0 {
    ensure_packages(['cpulimit'])
  }

  if $manage_epel and $facts['os']['family'] == 'Redhat' {
    include epel
    Class['epel']
    -> Package['psmisc']
    -> Package['wget']
    -> Package['inotify-tools']
    -> Package['perl']
  }

  if (
    $manage_epel and
    $facts['os']['family'] == 'RedHat' and
    versioncmp($facts['os']['release']['major'], '9') < 0
  ) {
    include epel
    Class['epel']
    -> Package['cpulimit']
  }

  if $package_name == '' {
    # cdn.rfxn.com stops at 1.6.x; 2.x is only published as a GitHub release.
    # 1.x leaves source unset, so the provider builds the mirror_url download as before
    $source = versioncmp($version, '2') >= 0 ? {
      true    => "${release_url}/v${version}/maldet-${version}.tar.gz",
      default => undef,
    }

    # source and checksum are passed only when set. Puppet rejects an unknown
    # parameter even when it is undef, so a compile server still holding 4.1.0's
    # maldet type (before `puppet generate types`) can compile 1.x hosts.
    $new_params = { 'source' => $source, 'checksum' => $checksum }.filter |$k, $v| { $v =~ NotUndef }

    maldet { $mirror_url :
      ensure              => $ensure,
      version             => $version,
      cleanup_old_install => $cleanup_old_install,
      *                   => $new_params,
    }
  } else {
    package { $package_name:
      ensure => $ensure,
    }
  }
}
