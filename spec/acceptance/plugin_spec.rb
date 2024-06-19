require 'spec_helper_acceptance'

describe 'sonarqube::plugin define' do
  sonar_version = '9.9.4.87374'
  sonar_user = 'sonar'
  sonar_group = 'sonar'
  default_plugin_dir = '/var/local/sonar/lib/extensions'
  custom_plugin_dir = '/var/local/sonar/extensions/plugins'

  before(:all) do
    apply_manifest(%(
      if ($facts['os']['family'] == 'Debian') {
        $target_path = '/usr/lib/jvm'
      } else {
        $target_path = '/usr/java'
      }

      java::adoptium { 'jdk17':
        version_major => '17',
        version_minor => '0',
        version_patch => '9',
        version_build => '9',
      }
      file { '/usr/bin/java':
        ensure  => link,
        target  => "${target_path}/jdk-17.0.9+9/bin/java",
        require => Java::Adoptium['jdk17'],
      }
    ), catch_failures: true)
  end

  describe 'removing a default plugin' do
    plugin_name = 'sonar-csharp-plugin'
    plugin_version = '8.51.0.59060'

    let(:pp) do
      <<-MANIFEST
        class { 'sonarqube':
          version => "#{sonar_version}"
        }
        sonarqube::plugin { #{plugin_name}:
          ensure    => 'absent',
          version   => "#{plugin_version}",
          subscribe => Class['sonarqube'],
        }
      MANIFEST
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{default_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).not_to be_file }
  end

  describe 'installing a plugin from github' do
    plugin_name = 'checkstyle-sonar-plugin'
    plugin_version = '10.12.5'
    ghid = 'checkstyle/sonar-checkstyle'

    let(:pp) do
      <<-MANIFEST
        class { 'sonarqube':
          version => "#{sonar_version}"
        }
        sonarqube::plugin { #{plugin_name}:
          version   => "#{plugin_version}",
          ghid      => "#{ghid}",
          subscribe => Class['sonarqube'],
        }
      MANIFEST
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{custom_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_file }
    it { expect(file("#{custom_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_owned_by sonar_user }
    it { expect(file("#{custom_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_grouped_into sonar_group }
  end

  describe 'installing a plugin from a URL' do
    plugin_name = 'sonar-detekt'
    plugin_version = '2.5.0'
    plugin_url = "https://github.com/detekt/sonar-kotlin/releases/download/#{plugin_version}/#{plugin_name}-#{plugin_version}.jar"

    let(:pp) do
      <<-MANIFEST
        class { 'sonarqube':
          version => "#{sonar_version}"
        }
        sonarqube::plugin { #{plugin_name}:
          version   => "#{plugin_version}",
          url       => "#{plugin_url}",
          subscribe => Class['sonarqube'],
        }
      MANIFEST
    end

    it { apply_manifest(pp, catch_failures: true) }
    it { expect(file("#{custom_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_file }
    it { expect(file("#{custom_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_owned_by sonar_user }
    it { expect(file("#{custom_plugin_dir}/#{plugin_name}-#{plugin_version}.jar")).to be_grouped_into sonar_group }
  end
end
