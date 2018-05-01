# Manage Linux Malware Detect configuration files
class maldet::config (
  Hash    $config          = $maldet::config,
  Array   $monitor_paths   = $maldet::monitor_paths,
  Array   $ignore_file_ext = $maldet::ignore_file_ext,
  Array   $ignore_inotify  = $maldet::ignore_inotify,
  Array   $ignore_paths    = $maldet::ignore_paths,
  Array   $ignore_sigs     = $maldet::ignore_sigs,
  Hash    $cron_config     = $maldet::cron_config,
  String  $version         = $maldet::version,
) {

  # Versions of maldet < 1.5 use a different set of
  # config options
  if versioncmp($maldet::version, '1.5') >= 0 {
    $default_config = lookup('maldet::new_config', Hash)
    $merged_config = $default_config + $config
  } else {
    $default_config = lookup('maldet::old_config', Hash)
    $merged_config = $default_config + $config
  }

  $merged_conf = { 'config' => $merged_config }
  file { '/usr/local/maldetect/conf.maldet':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => epp('maldet/conf.maldet.epp', $merged_conf),
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
  $monitor_mode = { 'monitor_mode' => $merged_config['default_monitor_mode'] }
  if $::facts['service_provider'] == 'redhat' {
    file { '/etc/sysconfig/maldet':
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => inline_epp('MONITOR_MODE="<%= $monitor_mode %>"', $monitor_mode),
    }
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
}
