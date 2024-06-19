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

  context 'when installing latest version' do
    let(:version) { '9.9.4.87374' }

    it_behaves_like :sonar_common
  end
end
