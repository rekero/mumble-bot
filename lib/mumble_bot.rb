require "mumble_bot/version"
require 'mumble-ruby'

module MumbleBot
  class Aldan
    def self.configure (sample_rate = nil, bitrate = nil)
      Mumble.configure do |conf|
        conf.sample_rate = sample_rate || 48000
        conf.bitrate = bitrate || 32000
        conf.ssl_cert_opts[:cert_dir] = File.expand_path("./")
      end
    end
 
    def self.create(username, password = nil, server, port)
      cli = Mumble::Client.new(server, port) do |conf|
        conf.username = username
        conf.password = password if password
      end
      cli
    end

    def self.start_thread
      configure
      client = create('Aldan-3', 'mumble.yoba-gaming.ru', 64738)
      client.connect
      Thread.new do
        loop do
          sleep 5
          p client.channels
          p client.users
        end 
      end 
    end
    
    def change_channel(client, name)
      channel_names = client.channels.to_a.collect{|f| f.last} 
      channel_names.each do |channel_name|
        if channel_name.name == name
          client.join_channel(channel_name.channel_id)
        end
      end
    end
  end 
end
