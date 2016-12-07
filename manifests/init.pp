# Install and configure Linux Malware Detect
#
# @example Declaring the class
#   include ::maldet
#
# @param version Version of Maldet to install. Defaults to '1.5'
# @param package_name Optional package name to use. Will install from source if left empty. Defaults to ''
# @param ensure Whether to install or remove maldet. Valid values are "present" or "absent". Defaults to 'present'
# @param daily_scan Whether to enable maldet's daily scan cron job. Defaults to true.
# @param mirror_url Base URL to download maldet source tarball from. Defaults to 'https://www.rfxn.com/downloads'
# @param config Hash of config options to use. Booleans are converted to 0 or 1. options with multiple values such as email_addr and scan_tmpdir_paths should be specified as an Array.
# @param cron_config Separate hash of config options for maldet's daily cron job.
# @see https://www.rfxn.com/appdocs/README.maldetect
# @param cleanup_old_install Whether old backups of /usr/local/maldetect created by Maldet's install.sh should be removed. Defaults to true.
#
#
class maldet (
  String  $version,
  String  $package_name,
  String  $ensure,
  Boolean $daily_scan,
  String  $mirror_url,
  Hash    $config,
  Hash    $cron_config,
  Boolean $cleanup_old_install,
) {

  contain maldet::install
  contain maldet::config

  Class['maldet::install'] ->
  Class['maldet::config']
}
