# Setup and manage Maldet inotify monitor service
class maldet::service (
  String $service_ensure       = $maldet::service_ensure,
  String $default_monitor_mode = $maldet::default_monitor_mode,
  Array  $monitor_paths        = $maldet::monitor_paths,
) {

  if $facts['service_provider'] == 'Redhat' {
    file { '/etc/default/maldet':
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => "MONITOR_MODE=\"${default_monitor_mode}\"",
      notify  => Service['maldet'],
    }
  }

  file { '/usr/local/maldetect/monitor_paths':
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => join($monitor_paths, "\n"),
  } ~>
  service { 'maldet':
    ensure => $service_ensure,
  }
}
