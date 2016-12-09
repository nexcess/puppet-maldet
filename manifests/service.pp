# Setup and manage Maldet inotify monitor service
class maldet::service (
  String $service_ensure = $maldet::service_ensure,
) {
  service { 'maldet':
    ensure => $service_ensure,
  }
}
