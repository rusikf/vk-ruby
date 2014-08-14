require 'mechanize'

module IntegrationGroup

  def self.included(base)
    base.before(:all) {  WebMock.allow_net_connect! }
    base.after(:all)  {  WebMock.disable_net_connect! }
  end

  def application
    @application ||= VK::Application.new
  end

  def authorizate!
    application.client_auth(credentials)
  end

  def credentials
    @credentials ||= YAML.load_file(File.expand_path('../credentials.yml', __FILE__))
  end

end
