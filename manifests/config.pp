# Manage Linux Malware Detect configuration files
class maldet::config (
  Hash    $config          = $maldet::config,
  Hash    $config_v2       = $maldet::config_v2,
  Array   $ignore_file_ext = $maldet::ignore_file_ext,
  Array   $ignore_inotify  = $maldet::ignore_inotify,
  Array   $ignore_paths    = $maldet::ignore_paths,
  Array   $ignore_sigs     = $maldet::ignore_sigs,
  Hash    $cron_config     = $maldet::cron_config,
  String  $version         = $maldet::version,
  Boolean $daily_scan      = $maldet::daily_scan,
  Array   $monitor_paths   = $maldet::monitor_paths,
  Variant[Enum['disabled', 'users'], Stdlib::Absolutepath] $monitor_mode = $maldet::monitor_mode,
  String  $sysconfig_path  = $maldet::sysconfig_path,
) {

  if versioncmp($maldet::version, '1.5') < 0 {
    fail("Versions of maldet lower than 1.5 are unsupported. The version specified as \$maldet:version is ${maldet::version}")
  }

  if versioncmp($version, '2') >= 0 {
    $final_config = $config + $config_v2

    # 2.x's install.sh adds a weekly watchdog that runs `maldet -d`, a version
    # upgrade, whenever signatures are over a week old, regardless of
    # autoupdate_version. Puppet owns the version, so the watchdog has to go.
    file { '/etc/cron.weekly/maldet-watchdog':
      ensure => absent,
    }
  } else {
    $final_config = $config

    # Left behind by a 2.x install.sh when a host is downgraded; 1.x never creates it
    file { '/etc/cron.d/maldet-sigup':
      ensure => absent,
    }
  }

  file { '/usr/local/maldetect/conf.maldet':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => epp('maldet/conf.maldet.epp', { 'config' => $final_config }),
  }

  # Allow config overrides for daily cron
  $cron_conf = { 'config' => $cron_config }
  if versioncmp($maldet::version, '1.5') >= 0 {
    file { '/usr/local/maldetect/cron/conf.maldet.cron':
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => epp('maldet/conf.maldet.epp', $cron_conf),
    }
  }

  # MONITOR_MODE is commented out by default and can prevent maldet service
  # from starting when using the init based startup script.
  file { $sysconfig_path:
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => epp('maldet/sysconfig_maldet.epp', {monitor_mode => $monitor_mode}),
  }

  file { '/usr/local/maldetect/monitor_paths':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => join($monitor_paths, "\n"),
  }

  file { '/usr/local/maldetect/ignore_file_ext':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => join($ignore_file_ext, "\n"),
  }

  file { '/usr/local/maldetect/ignore_inotify':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => join($ignore_inotify, "\n"),
  }

  file { '/usr/local/maldetect/ignore_paths':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => join($ignore_paths, "\n"),
  }

  file { '/usr/local/maldetect/ignore_sigs':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => join($ignore_sigs, "\n"),
  }

  unless $daily_scan {
    file { '/etc/cron.daily/maldet':
      ensure => absent,
    }
  }
}
