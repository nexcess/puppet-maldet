# Maldet

#### Table of Contents

1. [Description](#description)
2. [Usage](#usage)
3. [Reference](#reference)
4. [Copyright](#copywrite)

## Description

This module installs and configures Linux Malware Detect (Maldet)

This module has been tested with Maldet verions:
  - 1.5
  - 1.6
  - 2.0

By default Maldet is installed from source using the Maldet {} type/provider. If you prefer to use a package, simply use the "package_name" parameter to specify the name of your package, and it will use that instead (assuming any necessary repositories have been enabled).

Maldet will setup a cronjob that runs a daily scan on certain paths on the servers home directory depending on what directories it sees as present on a server.

It will also setup an inotify service to watch and scan changed files under certain directories (set to /tmp, /var/tmp, /dev/shm, and /var/fcgi_ipc by default).

Both the cron job and service are managed by the daily_scan and service_ensure parameters, respectively.

## Usage

```
include ::maldet
```

## Reference

### Classes

#### Public Classes

* maldet: Main class that includes all other classes.

#### Private Classes

* maldet::install: Installs Maldet
* maldet::config: Manages configuration file and daily malware scan for Maldet
* maldet::service: Manage Maldet inotify service

### Parameters

`Name`, _Type_, (Default)

#### `version` _String_ ('1.6.4')

Version of Maldet to install. 1.x is downloaded from `mirror_url`, 2.x from `release_url`.

Upgrading to 2.x changes more than the binary:

- 2.x's `install.sh` adds `/etc/cron.weekly/maldet-watchdog`, which runs a version upgrade whenever
  signatures are over a week old, regardless of `autoupdate_version`. This module removes it on 2.x.
- It also adds `/etc/cron.d/maldet-sigup` (a signature update every 6 hours) and
  `/etc/logrotate.d/maldet`. The module leaves both in place.
- Logs move to `/var/log/maldet/`, and `/usr/local/maldetect/logs` becomes a link to it.
- Downgrading to 1.x works by setting `version` back. 1.x's `install.sh` replaces the 2.x tree,
  `conf.maldet` comes back identical, and the module removes the 2.x `maldet-sigup` cron. 2.x's
  `/var/log/maldet/` and `/etc/logrotate.d/maldet` are left in place.
- Scan results are written to `sess/session.tsv.<scanid>`; `sess/session.hits.<scanid>` is gone.
- Since this module writes the whole `conf.maldet`, a key it leaves out gets 2.x's in-code default,
  not the value in 2.x's shipped `conf.maldet`. Set 2.x-only keys in `config_v2`.

#### `package_name` _String_ ('')

Optional package name to use. Will install from source if left empty.

#### `ensure` _String_ ('present')

Whether to install or remove maldet. Valid values are "present" or "absent".

#### `service_ensure` _String_ ('running')

Whether the maldet inotify monitor service should be running. On 2.x the service is also enabled at
boot only when this is `running`: 2.x's `install.sh` enables it, and an enabled 2.x service starts the
monitor from `default_monitor_mode` even when `MONITOR_MODE` is unset. On 1.x, enable isn't managed.

#### `daily_scan` _Boolean_ (true)

Whether to enable maldet's daily scan cron job.

#### `mirror_url` _String_ ('https://cdn.rfxn.com/downloads')

Base URL to download 1.x source tarballs from, as `<mirror_url>/maldetect-<version>.tar.gz`.

#### `release_url` _String_ ('https://github.com/rfxn/linux-malware-detect/releases/download')

Base URL to download 2.x release tarballs from, as `<release_url>/v<version>/maldet-<version>.tar.gz`.
cdn.rfxn.com does not host 2.x.

#### `checksum` _Optional[String]_ (undef)

SHA-256 of the tarball for `version`. When set, the download is checked before it is unpacked and
the install fails on a mismatch. Change it whenever `version` changes.

#### `config` _Hash_ ({ 'autoupdate_version' => false })

Hash of config options to use. Booleans are converted to 0 or 1. Options with multiple values such as email_addr and scan_tmpdir_paths should be specified as an Array. Uses defaults provided from Maldet source, except daily version updates are disabled by default.

See https://www.rfxn.com/appdocs/README.maldetect for available configuration options.

#### `config_v2` _Hash_ (2.x's shipped `scan_hashtype`, `scan_clamscan`, `scan_yara`, `scan_yara_timeout`, `scan_csig`, `scan_workers`, `quarantine_on_error`, `email_format`)

Config options merged over `config` when `version` is 2.x or later, and ignored on 1.x. Use it for
keys only 2.x understands, or for values that have to differ between 1.x and 2.x hosts while a fleet
is being upgraded. 1.x keys that 2.x no longer reads can stay in `config`; 2.x ignores them, and maps
`scan_hexfifo`/`scan_hexfifo_depth` onto `scan_hexdepth`.

#### `monitor_mode` _String_ ('disabled')

String matching one of the following:
1. The word 'disabled'. This will disable the sysconfig configuration for monitor mode.
2. The word 'users'. This will enable monitor mode in sysconfig for all local linux users.
3. An absolute path to a line-spaced file, containing a list of paths to monitor.

#### `monitor_paths` _Array[String]_ ({})

List of paths that the maldet service should monitor files under. Note that directories containing.

#### `ignore_file_ext` _Array[String]_ ({})

List of file extensions to ignore.

#### `ignore_inotify` _Array[String]_ ({})

List of paths to exclude from inotify monitor mode.

#### `ignore_paths` _Array[String]_ ({})

List of paths to exclude from scans.

#### `ignore_sigs` _Array[String]_ ({})

List of signatures to exclude.

#### `cron_config` _Hash_ ({})

Separate hash of config options to override main config options during maldet's daily cron job.

#### `cleanup_old_install` _Boolean_ (true)

Whether old backups of /usr/local/maldetect created by Maldet's install.sh should be removed.

#### `manage_epel` _Boolean_ (true)

Setup epel repository on Redhat based systems (required for some dependencies)

## Limitations

Supported Operating Systems are:
  - RHEL 6/7
  - CentOS 6/7
  - Rocky 8/9

## Copyright

~~~
   Copyright 2021 Nexcess.net

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
~~~
