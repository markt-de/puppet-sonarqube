require 'spec_helper'

describe 'sonarqube::plugin', type: :define do
  let(:sonar_version) { '8.9.9.56886' }

  on_supported_os.each do |os, _facts|
    context "on #{os}" do
      context 'when removing a plugin' do
        plugin_name = 'sonar-kotlin-plugin'
        plugin_version = '1.7.0.883'

        let(:title) { plugin_name }
        let(:params) do
          { 'ensure'  => 'absent',
            'version' => plugin_version }
        end
        let(:pre_condition) do
          <<-EOS
            class { sonarqube:
              version => "#{sonar_version}",
            }
          EOS
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_archive("download plugin #{plugin_name}-#{plugin_version}.jar from SonarSource") }
        it { is_expected.to contain_file("/var/local/sonar/extensions/plugins/#{plugin_name}-#{plugin_version}.jar").with_ensure('absent') }
        it { is_expected.not_to contain_exec("remove old versions of #{plugin_name}") }
      end

      context 'when installing a plugin from sonarsource' do
        plugin_name = 'sonar-kotlin-plugin'
        plugin_version = '1.7.0.883'

        let(:title) { plugin_name }
        let(:params) do
          { 'version' => plugin_version }
        end
        let(:pre_condition) do
          <<-EOS
            class { sonarqube:
              version => "#{sonar_version}",
            }
          EOS
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive("download plugin #{plugin_name}-#{plugin_version}.jar from SonarSource").with_source("https://binaries.sonarsource.com/Distribution/#{plugin_name}/#{plugin_name}-#{plugin_version}.jar") } # rubocop:disable Metrics/LineLength
        it { is_expected.to contain_file("/var/local/sonar/extensions/plugins/#{plugin_name}-#{plugin_version}.jar").with_owner('sonar') }
        it { is_expected.to contain_exec("remove old versions of #{plugin_name}") }
      end

      context 'when installing a plugin from github' do
        plugin_name = 'sonar-checkstyle-plugin'
        plugin_version = '4.31'
        ghid = 'checkstyle/sonar-checkstyle'

        let(:title) { plugin_name }
        let(:params) do
          { 'version' => plugin_version,
            'ghid'    => ghid }
        end
        let(:pre_condition) do
          <<-EOS
            class { sonarqube:
              version => "#{sonar_version}",
            }
          EOS
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive("download plugin #{plugin_name}-#{plugin_version}.jar from GitHub").with_source("https://github.com/#{ghid}/releases/download/#{plugin_version}/#{plugin_name}-#{plugin_version}.jar") } # rubocop:disable Metrics/LineLength
        it { is_expected.to contain_file("/var/local/sonar/extensions/plugins/#{plugin_name}-#{plugin_version}.jar").with_owner('sonar') }
        it { is_expected.to contain_exec("remove old versions of #{plugin_name}") }
      end

      context 'when installing a plugin from a URL' do
        plugin_name = 'sonar-detekt'
        plugin_version = '2.0.0'
        plugin_url = "https://github.com/detekt/sonar-kotlin/releases/download/#{plugin_version}/#{plugin_name}-#{plugin_version}.jar"

        let(:title) { plugin_name }
        let(:params) do
          { 'version' => plugin_version,
            'url'     => plugin_url }
        end
        let(:pre_condition) do
          <<-EOS
            class { sonarqube:
              version => "#{sonar_version}",
            }
          EOS
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive("download plugin #{plugin_name}-#{plugin_version}.jar").with_source(plugin_url) }
        it { is_expected.to contain_file("/var/local/sonar/extensions/plugins/#{plugin_name}-#{plugin_version}.jar").with_owner('sonar') }
        it { is_expected.to contain_exec("remove old versions of #{plugin_name}") }
      end
    end
  end
end
