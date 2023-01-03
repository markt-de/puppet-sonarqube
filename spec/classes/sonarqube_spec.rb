require 'spec_helper'

describe 'sonarqube' do
  let(:sonar_properties) { '/usr/local/sonar/conf/sonar.properties' }
  let(:sonar_version) { '8.9.9.56886' }
  let(:sonar_version_latest) { '9.8.0.63668' }

  context 'when installing LTS version', :compile do
    let(:params) { { version: sonar_version.to_s } }

    it { is_expected.to contain_class('sonarqube::install') }
    it { is_expected.to contain_class('sonarqube::config') }
    it { is_expected.to contain_class('sonarqube::service') }

    it { is_expected.to contain_archive('download sonarqube distribution').with_source("https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-#{sonar_version}.zip") }

    it {
      is_expected.to contain_file_line('set PIDDIR in startup script').with(
        match: '^PIDDIR=',
      )
    }
    it {
      is_expected.to contain_file_line('set RUN_AS_USER in startup script').with(
        match: '^RUN_AS_USER=',
      )
    }
  end

  context 'when installing latest version', :compile do
    let(:params) { { version: sonar_version_latest.to_s } }

    it { is_expected.to contain_class('sonarqube::install') }
    it { is_expected.to contain_class('sonarqube::config') }
    it { is_expected.to contain_class('sonarqube::service') }

    it { is_expected.to contain_archive('download sonarqube distribution').with_source("https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-#{sonar_version_latest}.zip") }

    it {
      is_expected.to contain_file_line('set PIDFILE in startup script').with(
        match: '^PIDFILE=',
      )
    }
  end

  context 'when crowd configuration is supplied', :compile do
    let :params do
      {
        version: sonar_version.to_s,
        crowd:
          {
            'application' => 'crowdapplication',
            'service_url' => 'crowdserviceurl',
            'password'    => 'crowdpassword',
          },
      }
    end

    it 'generates sonar.properties config for crowd' do
      is_expected.to contain_file(sonar_properties).with_content(%r{sonar\.authenticator\.class: org\.sonar\.plugins\.crowd\.CrowdAuthenticator})
      is_expected.to contain_file(sonar_properties).with_content(%r{crowd\.url: crowdserviceurl})
      is_expected.to contain_file(sonar_properties).with_content(%r{crowd\.application: crowdapplication})
      is_expected.to contain_file(sonar_properties).with_content(%r{crowd\.password: crowdpassword})
    end
  end

  context 'when no crowd configuration is supplied', :compile do
    let(:params) { { version: sonar_version.to_s } }

    it { is_expected.to contain_file(sonar_properties).without_content('crowd') }
  end

  context 'when unzip package is not defined', :compile do
    let(:params) { { version: sonar_version.to_s } }

    it { is_expected.to contain_package('unzip').with_ensure('installed') }
  end

  context 'when unzip package is already defined', :compile do
    let :pre_condition do
      "package { 'unzip': ensure => installed }"
    end
    let(:params) { { version: sonar_version.to_s } }

    it { is_expected.to contain_package('unzip').with_ensure('installed') }
  end

  context 'when ldap local users configuration is supplied', :compile do
    let :params do
      {
        version: sonar_version.to_s,
        ldap:
          {
            'url'          => 'ldap://myserver.mycompany.com',
            'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
            'local_users'  => 'foo',
          },
      }
    end

    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.localUsers=foo}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.realm=LDAP}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.url=ldap:\/\/myserver.mycompany.com}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.user.baseDn=ou=Users,dc=mycompany,dc=com}) }
  end

  context 'when ldap local users configuration is supplied as array', :compile do
    let :params do
      {
        version: sonar_version.to_s,
        ldap:
          {
            'url'          => 'ldap://myserver.mycompany.com',
            'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
            'local_users'  => ['foo', 'bar'],
          },
      }
    end

    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.localUsers=foo,bar}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.realm=LDAP}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.url=ldap:\/\/myserver.mycompany.com}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.user.baseDn=ou=Users,dc=mycompany,dc=com}) }
  end

  context 'when no ldap local users configuration is supplied', :compile do
    let :params do
      {
        version: sonar_version.to_s,
        ldap:
          {
            'url'          => 'ldap://myserver.mycompany.com',
            'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
          },
      }
    end

    it { is_expected.to contain_file(sonar_properties).without_content(%r{sonar.security.localUsers}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.realm=LDAP}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.url=ldap:\/\/myserver.mycompany.com}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.user.baseDn=ou=Users,dc=mycompany,dc=com}) }
  end

  context 'when no ldap configuration is supplied', :compile do
    let(:params) { { version: sonar_version.to_s } }

    it { is_expected.to contain_file(sonar_properties).without_content(%r{sonar.security}) }
    it { is_expected.to contain_file(sonar_properties).without_content(%r{ldap.}) }
  end
end
