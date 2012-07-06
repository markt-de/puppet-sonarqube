require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

SONAR_PROPERTIES = "/usr/local/sonar/conf/sonar.properties"

describe 'sonar' do
  context "when crowd configuration is supplied" do
    let(:params) { { :crowd => {
      'application' => 'crowdapplication',
      'service_url' => 'crowdserviceurl',
      'password'    => 'crowdpassword',
    } } }

    it { should contain_sonar__plugin('sonar-crowd-plugin').with_ensure('present') }

    it { should contain_file(SONAR_PROPERTIES) }
    it 'should generate sonar.properties config for crowd' do
      content = catalogue.resource('file', SONAR_PROPERTIES).send(:parameters)[:content]
      content.should =~ %r[sonar\.authenticator\.class: org\.sonar\.plugins\.crowd\.CrowdAuthenticator]
      content.should =~ %r[crowd\.url: crowdserviceurl]
      content.should =~ %r[crowd\.application: crowdapplication]
      content.should =~ %r[crowd\.password: crowdpassword]
    end
  end

  context "when no crowd configuration is supplied" do
    it { should contain_sonar__plugin('sonar-crowd-plugin').with_ensure('absent') }

    it { should contain_file(SONAR_PROPERTIES) }
    it 'should generate sonar.properties config without crowd' do
      content = catalogue.resource('file', SONAR_PROPERTIES).send(:parameters)[:content]
      content.should_not =~ %r[crowd]
    end
  end
end
