require 'aws-sdk-ec2'
require 'dotenv'

Dotenv.load

set :rails_env, :production
set :user, 'ec2-user'
set :ssh_options, { forward_agent: true, port: '22', config: false }

Aws.config.update({
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'],
    ENV['AWS_SECRET_ACCESS_KEY']
  ),
  region: 'ap-northeast-1'
})

ec2 = Aws::EC2::Resource.new

main = ec2.instances.select { |i| i.state.name == 'running' &&
  i.tags.select { |t| t.key == 'Name' }.map(&:value).first == 'rails-test' }.map(&:public_ip_address)

puts 'FETCHED EC2.'
puts main

main.each do |host|
  server host, user: 'ec2-user', roles: [:app, :web, :main, :db, :cron, :push]
end
