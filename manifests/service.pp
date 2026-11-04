# Setup and manage Maldet inotify monitor service
class maldet::service (
  String $service_ensure = $maldet::service_ensure,
  String $version        = $maldet::version,
) {
  # 2.x's install.sh enables the service, and an enabled 2.x service starts the
  # monitor at boot from default_monitor_mode, so on 2.x enable follows ensure.
  # 1.x is left as it always was.
  $service_enable = versioncmp($version, '2') >= 0 ? {
    true    => $service_ensure == 'running',
    default => undef,
  }

  service { 'maldet':
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
