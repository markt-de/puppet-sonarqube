require 'spec_helper_acceptance'

describe 'sonarqube::plugin define' do
  sonar_version = '9.8.0.63668'
  sonar_user = 'sonar'
  sonar_group = 'sonar'
  plugin_dir = '/var/local/sonar/extensions/plugins'

  before(:all) do
    apply_manifest(%(
      if ($facts['os']['family'] == 'Debian') {
        $target_path = '/usr/lib/jvm'
      } else {
        $target_path = '/usr/java'
      }

      java::adopt { 'jdk11':
        ensure        => 'present',
        java          => 'jdk',
        version_major => '11.0.6',
        version_minor => '10',
      }
      -> file { '/usr/bin/java':
        ensure => link,
        target => "${target_path}/jdk-11.0.6+10/bin/java",
      }
    ), catch_failures: true)
  end

  describe 'removing a plugin' do
    plugin_name = 'sonar-groovy-plugin'
    plugin_version = '1.4'

    let(:pp) do
      <<-MANIFEST
        class { 'sonarqube':
          version => "#{sonar_version}"
        }
        ~> sonarqube::plugin { #{plugin_name}:
          ensure  => 'absent',
          version => "#{plugin_version}",
        }
      MANIFEST
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).not_to be_file }
  end

  describe 'installing a plugin from github' do
    plugin_name = 'checkstyle-sonar-plugin'
    plugin_version = '4.31'
    ghid = 'checkstyle/sonar-checkstyle'

    let(:pp) do
      <<-MANIFEST
        class { 'sonarqube':
          version => "#{sonar_version}"
        }
        ~> sonarqube::plugin { #{plugin_name}:
          version => "#{plugin_version}",
          ghid    => "#{ghid}",
        }
      MANIFEST
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_file }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_owned_by sonar_user }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_grouped_into sonar_group }
  end

  describe 'installing a plugin from a URL' do
    plugin_name = 'sonar-detekt'
    plugin_version = '2.0.0'
    plugin_url = "https://github.com/detekt/sonar-kotlin/releases/download/#{plugin_version}/#{plugin_name}-#{plugin_version}.jar"

    let(:pp) do
      <<-MANIFEST
        class { 'sonarqube':
          version => "#{sonar_version}"
        }
        ~> sonarqube::plugin { #{plugin_name}:
          version => "#{plugin_version}",
          url     => "#{plugin_url}",
        }
      MANIFEST
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_file }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_owned_by sonar_user }
    it { expect(file("#{plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_grouped_into sonar_group }
  end
end
