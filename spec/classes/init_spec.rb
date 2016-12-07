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
             that_comes_before('Class[maldet::config]') }
        it { is_expected.to contain_class('maldet::config') }
      end

      describe 'maldet::install' do
        let(:params) {{ :version => '1.5',
                        :mirror_url => 'https://www.rfxn.com/downloads',
                        :package_name => '',
                        :ensure => 'present',
                        :cleanup_old_install => true }}
        it { should contain_package('psmisc').with(:ensure => 'present') }
        it { should contain_package('wget').with(:ensure => 'present') }
        it { should contain_package('cpulimit').with(:ensure => 'present') }
        it { should contain_maldet('https://www.rfxn.com/downloads').
             with(:ensure => 'present') }

        describe 'allow installation from package' do
          let(:params) {{ :package_name => 'maldetect' }}
          it { should contain_package('maldetect').with(:ensure => 'present') }
        end
      end

      describe 'maldet::config' do
        let(:params) {{ :config => {},
                        :cron_config => {},
                        :version => '1.5',
                        :daily_scan => true }}
        it { should contain_file('/usr/local/maldetect/conf.maldet').
             with(:ensure => 'present') }
        it { should contain_file('/usr/local/maldetect/cron/conf.maldet.cron').
             with(:ensure => 'present') }

        describe 'do not create conf.maldet.cron on older versions' do
          let(:params) {{ :version => '1.4.2' }}
          it { should_not contain_file('/usr/local/maldetect/cron/conf.maldet.cron').
               with(:ensure => 'present') }
        end

        describe 'remove daily cron if daily_scan option is toggled' do
          let(:params) {{ :daily_scan=> false }}
          it { should contain_file('/etc/cron.daily/maldet').
               with(:ensure => 'absent') }
        end
      end
    end
  end
end
