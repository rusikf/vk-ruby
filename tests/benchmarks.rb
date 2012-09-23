require 'rubygems'
require 'minitest/autorun'
require 'minitest/benchmark'
require "vk-ruby"
require 'yaml'
require 'rubygems'
require 'em-synchrony'
require 'em-synchrony/em-http'

if File.exists?("#{Dir.pwd}/config.yml")
  YAML.load_file("#{Dir.pwd}/config.yml").each do |name, value|
    self.class.const_set name.upcase, value
  end
end

class TestBench < MiniTest::Unit::TestCase

	def self.bench_range
		[50]
	end

	def setup
    @vk = VK::Standalone.new app_id: APP_ID, access_token: ACCESS_TOKEN, logger: false
    @fields = %w[uid first_name last_name nickname screen_name bdate sex city country photo_big has_mobile contacts education rate relation counters]
  end

  def per_request
    500
  end

  def part_size
    10
  end

  [ :net_http, :em_http, :em_synchrony, :net_http_persistent, :patron, :typhoeus ].each do |http_adapter|
    [:json_gem, :json_pure, :oj, :yajl].each do |json_engine|

      define_method "bench_#{http_adapter}_#{json_engine}" do
        @vk.adapter = http_adapter
        MultiJson.engine = json_engine

        assert_performance_linear 0.9998 do |n| # n is a range value
          (1..n).each_slice( per_request ) do |part|
            @vk.users.get(uids: part.join(','), fields: @fields)
          end
        end

      end

    end
  end

  [ :em_http, :em_synchrony, :patron, :typhoeus ].each do |http_adapter|
    [:json_gem, :json_pure, :oj, :yajl].each do |json_engine|

      define_method "bench_#{http_adapter}_#{json_engine}_parallel" do
        @vk.adapter = http_adapter
        MultiJson.engine = json_engine

        results = []

        assert_performance_linear 0.9998 do |n|
          (1..n).each_slice( per_request * part_size ) do |part|
            @vk.in_parallel do |r|

              part.each_slice( per_request ) do |sub_part|
                results << @vk.users.get(uids: sub_part.join(','), fields: @fields)
              end

            end
          end
        end

      end
    end
  end

end