# Maldet

#### Table of Contents

1. [Description](#description)
2. [Usage](#usage)
3. [Reference](#reference)
4. [Copyright](#copywrite)

## Description

This module installs and configures Linux Malware Detect (Maldet)

This module has been tested with Maldet verions:
  - 1.4.x
  - 1.5

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

#### `version` _String_ ('1.5')

Version of Maldet to install.

#### `package_name` _String_ ('')

Optional package name to use. Will install from source if left empty.

#### `ensure` _String_ ('present')

Whether to install or remove maldet. Valid values are "present" or "absent".

#### `service_ensure` _String_ ('running')

Whether the maldet inotify monitor service should be running.

#### `daily_scan` _Boolean_ (true)

Whether to enable maldet's daily scan cron job.

#### `mirror_url` _String_ ('https://www.rfxn.com/downloads')

Base URL to download maldet source tarball from. Defaults to 'https://www.rfxn.com/downloads'

#### `config` _Hash_ ({ 'autoupdate_version' => false })

Hash of config options to use. Booleans are converted to 0 or 1. Options with multiple values such as email_addr and scan_tmpdir_paths should be specified as an Array. Uses defaults provided from Maldet source, except daily version updates are disabled by default.

See https://www.rfxn.com/appdocs/README.maldetect for available configuration options.

#### `monitor_paths` _Array[String]_ ({})

List of paths that the maldet service should monitor files under. Note that directories containing.

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
  - Ubuntu 16.04

## Copyright

~~~
   Copyright 2016 Nexcess.net

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
