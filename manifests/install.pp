class maldet::install (
  String $version    = $maldet::version,
  String $mirror_url = $maldet::mirror_url,
) {

  $filename     = "maldetect-${version}.tar.gz"
  $download_dir = '/usr/local/maldetect_install'
  $extract_dir  = "${download_dir}/maldetect-${version}"
  $package_url  = "${mirror_url}/${filename}"

  # The killall command is used by install.sh
  # 'cpulimit' is used for the scan_cpulimit config option
  ensure_packages(['psmisc'])

  file { $download_dir:
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => root,
  } ->
  archive { "${download_dir}/${filename}":
    source       => $package_url,
    #checksum => $checksum,
    #checksum_type => $checksum_type,
    cleanup      => true,
    user         => root,
    group        => root,
    extract      => true,
    extract_path => $download_dir,
    creates      => "${extract_dir}/install.sh",
  } ->
  exec { 'install maldet':
    command     => "${extract_dir}/install.sh",
    cwd         => $extract_dir,
    unless      => "/usr/bin/test ! -e /usr/local/sbin/maldet || /usr/local/sbin/maldet | head -n1 | grep -q ${version}",
  }

}
