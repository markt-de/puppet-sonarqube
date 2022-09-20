require 'spec_helper_acceptance'

describe 'sonarqube' do
  let(:installroot) { '/usr/local/sonar' }
  let(:home) { '/var/local/sonar' }
  let(:user) { 'sonar' }
  let(:group) { 'sonar' }

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
      #class { 'maven::maven': }
    ), catch_failures: true)
  end

  shared_examples :sonar_common do
    let(:pp) do
      %(class { 'sonarqube':
          version => '#{version}'
      })
    end

    it { apply_manifest(pp, catch_failures: true) }

    it { expect(file(home)).to be_directory }
    it { expect(file(home)).to be_owned_by user }
    it { expect(file(home)).to be_grouped_into group }
    it { expect(file(home)).to be_mode 700 }
    it { expect(file("#{home}/data")).to be_directory }

    it { expect(file("#{installroot}/data")).to be_linked_to("#{home}/data") }
    it { expect(file("#{installroot}/conf/sonar.properties")).to be_file }
    it { expect(file("#{installroot}/conf/sonar.properties").content).not_to match(%r{^ldap}) }

    describe service('sonar') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'when installing LTS version' do
    let(:version) { '8.9.9.56886' }

    it_behaves_like :sonar_common
  end
end
