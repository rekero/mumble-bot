require "mumble_bot/version"
require 'mumble-ruby'
require 'open-uri'
require "json"

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
      client.on_text_message do |msg|
        File.open("#{Dir.pwd}/log.txt", "a") {|file| file.write("channel: #{msg.channel_id}, user: #{msg.actor}, message: #{msg.message} \n") }
        change_channel(client, msg.message.split(' ').last)  if msg.message.include?('Уходи в ')
        client.text_channel(client.me.channel_id.to_i, wiki_search(msg.message.split(' ')[1..-1].join(' '))) if msg.message.include?('Вики')
        client.disconnect if msg.message.include?('Вам стоит выйти')
      end
      Thread.new do
        loop do
          sleep 5
        #  p client.channels
        #  p client.users
        end 
      end 
    end

    def self.wiki_search(text)
      JSON.parse(open(URI.parse(URI.encode("http://ru.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=#{text}"))).read)['query']['pages'].first.last['extract']
    end
    
    def self.change_channel(client, name)
      channel_names = client.channels.to_a.collect{|f| f.last} 
      channel_names.each do |channel_name|
        if channel_name.name == name
          client.join_channel(channel_name)
        end
      end
    end
  end 
end
