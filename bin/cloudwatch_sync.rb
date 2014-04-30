
require File.expand_path('../../lib/cloudwatch_sync', __FILE__)

access_key_id = ENV['AWS_ACCESS_KEY_ID']
secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
region = ENV['AWS_REGION']
command = ARGV[0]

if [access_key_id, secret_access_key, region, command].any?{|x| x.nil? || x.empty? }
  puts <<-USAGE
  usage:
    AWS_ACCESS_KEY_ID=xxxxxxxxx AWS_SECRET_ACCESS_KEY=xxxxxxxx AWS_REGION=us-east-1 ruby #{$0} [sync|list]
  USAGE
  exit 255
end

CloudwatchSync.configure do |config|
  config.source = File.expand_path('../../config/cloudwatch.yml', __FILE__)
  config.aws_access_key_id = access_key_id
  config.aws_secret_access_key = secret_access_key
  config.aws_region = region
end

case ARGV[0]
when 'sync'
  CloudwatchSync.sync(ARGV[1])
when 'list'
  CloudwatchSync.list
end
