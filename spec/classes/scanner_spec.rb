require 'spec_helper'

describe 'sonarqube::scanner' do
  let(:scanner_version) { '5.0.1.3006' }

  context 'when installing with default config' do
    let(:params) { { version: scanner_version.to_s } }

    it { is_expected.to create_class('sonarqube::scanner::install') }
    it { is_expected.to contain_archive('download-sonar-scanner').with_source("https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-#{scanner_version}.zip") }
    it { is_expected.to contain_file("/usr/local/sonar-scanner-#{scanner_version}") }
  end

  context 'when running with default config' do
    let(:params) { { version: scanner_version.to_s } }

    it { is_expected.to create_class('sonarqube::scanner::config') }
    it { is_expected.to contain_file("/usr/local/sonar-scanner-#{scanner_version}/conf/sonar-scanner.properties") }
  end
end
