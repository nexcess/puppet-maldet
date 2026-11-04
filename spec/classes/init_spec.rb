require 'spec_helper'

describe 'maldet' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context "maldet class without any parameters" do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('maldet') }
        it { is_expected.to contain_class('maldet::install').
             that_notifies('Class[maldet::config]') }
        it { is_expected.to contain_class('maldet::config').
             that_notifies('Class[maldet::service]') }
        it { is_expected.to contain_class('maldet::service') }
      end

      describe 'maldet::install' do
        let(:params) {{ :version => '1.6',
                        :mirror_url => 'https://cdn.rfxn.com/downloads',
                        :package_name => '',
                        :ensure => 'present',
                        :cleanup_old_install => true }}
        it { should contain_maldet('https://cdn.rfxn.com/downloads').
             with(:ensure => 'present', :source => nil, :checksum => nil) }
        it { should contain_package('psmisc').with(:ensure => 'installed') }
        it { should contain_package('wget').with(:ensure => 'installed') }
        it { should contain_package('inotify-tools').with(:ensure => 'installed') }
        it { should contain_package('perl').with(:ensure => 'installed') }

        case facts[:os]["release"]["major"]
          when '6'
          when '7'
          when '8'
            it { should contain_package('cpulimit').with(:ensure => 'installed') }
        end

        describe 'installs 2.x from GitHub releases' do
          let(:params) {{ :version => '2.0.1',
                          :checksum => '26674c72208a4c32ae4ed8770a2b5c036b35c0894a4812450df11c5a53d7d8e5' }}
          it { should contain_maldet('https://cdn.rfxn.com/downloads').
               with(:version => '2.0.1',
                    :source => 'https://github.com/rfxn/linux-malware-detect/releases/download/v2.0.1/maldet-2.0.1.tar.gz',
                    :checksum => '26674c72208a4c32ae4ed8770a2b5c036b35c0894a4812450df11c5a53d7d8e5') }
        end

        describe 'allow installation from package' do
          let(:params) {{ :package_name => 'maldetect' }}
          it { should contain_package('maldetect').with(:ensure => 'present') }
        end
      end

      describe 'maldet::config' do
        let(:params) {{ :config => {},
                        :cron_config => {},
                        :version => '1.6',
                        :daily_scan => true }}
        it { should contain_file('/usr/local/maldetect/conf.maldet').
             with(:ensure => 'present') }
        it { should contain_file('/usr/local/maldetect/cron/conf.maldet.cron').
             with(:ensure => 'present') }

        it { should_not contain_file('/etc/cron.weekly/maldet-watchdog') }
        it { should contain_file('/etc/cron.d/maldet-sigup').with(:ensure => 'absent') }
        it { should contain_file('/usr/local/maldetect/conf.maldet').
             without_content(/scan_hashtype/) }

        describe 'on 2.x with the module defaults' do
          let(:params) {{ :version => '2.0.1', :config => {} }}
          it { should contain_file('/usr/local/maldetect/conf.maldet').
               with_content(/^scan_csig="1"$/).
               with_content(/^scan_yara_timeout="300"$/).
               with_content(/^quarantine_on_error="1"$/) }
        end

        describe 'on 2.x' do
          let(:params) {{ :version => '2.0.1',
                          :config => { 'scan_clamscan' => true, 'scan_hexfifo' => true },
                          :config_v2 => { 'scan_clamscan' => false, 'scan_hashtype' => 'both' } }}
          it { should contain_file('/etc/cron.weekly/maldet-watchdog').
               with(:ensure => 'absent') }
          it { should_not contain_file('/etc/cron.d/maldet-sigup') }
          it { should contain_file('/usr/local/maldetect/conf.maldet').
               with_content(/^scan_clamscan="0"$/).
               with_content(/^scan_hashtype="both"$/).
               with_content(/^scan_hexfifo="1"$/) }
        end

        describe 'remove daily cron if daily_scan option is toggled' do
          let(:params) {{ :daily_scan=> false }}
          it { should contain_file('/etc/cron.daily/maldet').
               with(:ensure => 'absent') }
        end
      end

      describe 'maldet::service' do
        let(:params) {{ :service_ensure => 'running',
                        :monitor_paths => ['/tmp', '/var/tmp'] }}
        it { should contain_file('/usr/local/maldetect/monitor_paths').
             with(:ensure => 'present') }
        it { should contain_file('/usr/local/maldetect/ignore_file_ext').
             with(:ensure => 'present') }
        it { should contain_file('/usr/local/maldetect/ignore_inotify').
             with(:ensure => 'present') }
        it { should contain_file('/usr/local/maldetect/ignore_paths').
             with(:ensure => 'present') }
        it { should contain_file('/usr/local/maldetect/ignore_sigs').
             with(:ensure => 'present') }
        it { should contain_service('maldet').
             with(:ensure => 'running', :enable => nil) }

        describe 'leaves a stopped 1.x service enabled as before' do
          let(:params) {{ :service_ensure => 'stopped' }}
          it { should contain_service('maldet').
               with(:ensure => 'stopped', :enable => nil) }
        end

        describe 'disables a stopped 2.x service so it does not start at boot' do
          let(:params) {{ :service_ensure => 'stopped', :version => '2.0.1' }}
          it { should contain_service('maldet').
               with(:ensure => 'stopped', :enable => false) }
        end
      end
    end
  end
end
