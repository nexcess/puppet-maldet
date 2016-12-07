# Setup and manage Maldet inotify monitor service
class maldet::service (
  String $service_ensure = $maldet::service_ensure,
  Array  $monitor_paths  = $maldet::monitor_paths,
) {

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
