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
        it { should contain_package('psmisc').with(:ensure => 'installed') }
        it { should contain_package('wget').with(:ensure => 'installed') }
        it { should contain_package('cpulimit').with(:ensure => 'installed') }
        it { should contain_package('inotify-tools').with(:ensure => 'installed') }
        it { should contain_package('perl').with(:ensure => 'installed') }
        it { should contain_maldet('https://cdn.rfxn.com/downloads').
             with(:ensure => 'present') }

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
             with(:ensure => 'running') }
      end
    end
  end
end
