require 'minitest/autorun'
require 'minitest/benchmark'
require "vk-ruby"
require 'yaml'

if File.exists?("#{Dir.pwd}/config.yml")
  YAML.load_file("#{Dir.pwd}/config.yml").each do |name, value|
    self.class.const_set name.upcase, value
  end
end

class TestBench < MiniTest::Unit::TestCase

	def self.bench_range
		[100, 10000]
	end

	def setup
    @vk = VK::Standalone.new app_id: APP_ID, access_token: ACCESS_TOKEN, logger: false
    @fields = %w[uid first_name last_name nickname screen_name bdate sex city country photo_big has_mobile contacts education rate relation counters]
  end

  # Override self.bench_range or default range is [1, 10, 100, 1_000, 10_000]

  [ :net_http, :em_http, :em_synchrony, :net_http_persistent, :patron ].each do |http_adapter|
  	[:json_gem, :json_pure, :oj, :yajl].each do |json_engine|

	  	define_method "bench_#{http_adapter}_#{json_engine}" do
				@vk.adapter = http_adapter
				MultiJson.engine = json_engine

		    assert_performance_linear 0.998 do |n| # n is a range value
		    	(1..n).each_slice(500) do |part|
		    		@vk.users.get(uids: part.join(','), fields: @fields)
		    	end
		    end

		  end

		end
	end

  [ :em_http, :em_synchrony, :patron ].each do |http_adapter|
    [:json_gem, :json_pure, :oj, :yajl].each do |json_engine|

      define_method "bench_#{http_adapter}_#{json_engine}" do
        @vk.adapter = http_adapter
        MultiJson.engine = json_engine

        assert_performance_linear 0.998 do |n| # n is a range value

          (1..n).each_slice(5000) do |part|

            results = @vk.in_parallel([]) do |vk, r|
              part.each_slice(50) do |sub_part|
                r << @vk.users.get(uids: sub_part.join(','), fields: @fields)
              end
            end

            puts results.inspect
          end

        end
      end

    end
  end

end