require 'redis'
raise "redis needs to be provisioned" if ENV["REDIS_URL"].nil?
$redis = Redis.new(url: ENV["REDIS_URL"])
