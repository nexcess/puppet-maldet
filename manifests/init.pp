# Install and configure Linux Malware Detect
#
# @example Declaring the class
#   include ::maldet
#
# @param version Version of Maldet to install. Defaults to '1.5'
# @param package_name Optional package name to use. Will install from source if left empty. Defaults to ''
# @param ensure Whether to install or remove maldet. Valid values are "present" or "absent". Defaults to 'present'
# @param service_ensure Whether the maldet inotify monitor service should be running
# @param daily_scan Whether to enable maldet's daily scan cron job. Defaults to true.
# @param mirror_url Base URL to download maldet source tarball from. Defaults to 'https://cdn.rfxn.com/downloads'
# @param config Hash of config options to use. Booleans are converted to 0 or 1. options with multiple values such as 
#        email_addr and scan_tmpdir_paths should be specified as an Array.
# @see https://www.rfxn.com/appdocs/README.maldetect
# @param cron_config Separate hash of config options for maldet's daily cron job.
# @param monitor_paths list of paths that the maldet service should monitor files under. Note that directories containing large numbers of files will lead to long startup times for the maldet service.
# @param ignore_file_ext list of file extensions to ignore
# @param ignore_inotify list of paths to exclude from inotify monitor mode
# @param ignore_paths list of paths to exclude from scans
# @param ignore_sigs list of signatures to exclude
# @param cleanup_old_install Whether old backups of /usr/local/maldetect created by Maldet's install.sh should be removed. Defaults to true.
# @param manage_epel Setup epel repository on Redhat based systems (required for some dependencies)
#
#
class maldet (
  String  $version,
  String  $package_name,
  String  $ensure,
  String  $service_ensure,
  Boolean $daily_scan,
  String  $mirror_url,
  Hash    $config,
  Array   $monitor_paths,
  Array   $ignore_file_ext,
  Array   $ignore_inotify,
  Array   $ignore_paths,
  Array   $ignore_sigs,
  Hash    $cron_config,
  Boolean $cleanup_old_install,
  Boolean $manage_epel,
) {

  contain maldet::install

  if $ensure == 'present' {
    contain maldet::config
    contain maldet::service

    Class['maldet::install']
    ~> Class['maldet::config']
    ~> Class['maldet::service']
  }
}
