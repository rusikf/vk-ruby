require File.expand_path('../helpers', __FILE__)

class ServersideTest < MiniTest::Unit::TestCase
	def setup
		@base_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/base.yml" ))
		@app = ::VK::Serverside.new :app_id => :test_id, 
																:app_secret => :test_secret, 
																:access_token => :test_token
	end

	def test_init_attributes
		assert_equal @app.app_id, :test_id
		assert_equal @app.app_secret, :test_secret
		assert_equal @app.access_token, :test_token
		assert_nil @app.expires_in
		assert_nil @app.logger
	end

	def test_methods_exists
		perebor @app, @base_api do |obj, method_name, is_group|
			assert_respond_to obj, method_name.to_sym unless is_group
		end
	end

	def test_groups_exists
		perebor @app, @base_api do |obj, method_name, is_group|
			assert_instance_of ::Transformer::Group, obj if is_group
		end
	end

	def test_groups_methods_prefix
		perebor @app, @base_api do |obj, method_name, is_group|
			assert_equal obj.instance_variable_get("@methods_prefix"), method_name if is_group
		end
	end

	def test_post_request_params
		stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request| {:body => {'response' => request.body.to_params}.to_json } })

		perebor @app, @base_api do |obj, method_name, is_group|
			unless is_group			
				params = random_params.merge!(:access_token => :test_token)
				assert_equal obj.method(method_name.to_sym).call(params), params.stringify
			end
		end

		WebMock.reset!
	end

	def test_get_request_params
		stub_request(:get, /https:\/\/api.vk.com\/method/).to_return(lambda { |request| {:body => {'response' => URI.parse(request.uri).query.to_params}.to_json}  })

		perebor @app, @base_api do |obj, method_name, is_group|
			unless is_group
				params = random_params.merge!(:access_token => :test_token, :verbs => 'get')
				assert_equal obj.method(method_name.to_sym).call(params), params.stringify
			end
		end

		WebMock.reset!
	end

	def test_authorization 
		stub_request(:get, /https:\/\/api.vk.com\/oauth\/access_token/).to_return(lambda { |request| {:body => URI.parse(request.uri).query.to_params.to_json}})

		params = {:code => :test_code, :client_id => :test_id ,:client_secret => :test_secret}
		assert_equal @app.authorize(params[:code]) , params.stringify

		WebMock.reset!
	end

	def test_raises_initialize
		params = {}
		assert_raises(RuntimeError) do
			::VK::Serverside.new params
		end
		
		params[:app_id] = :test_id, 
		assert_raises(RuntimeError) do
			::VK::Serverside.new params
		end
	end

	def test_raises_request
		@app.access_token = nil
			
		perebor @app, @base_api do |obj, method_name, is_group|
			unless is_group
				assert_raises(RuntimeError) do
					obj.method(method_name.to_sym).call
				end
			end
		end
	end

end