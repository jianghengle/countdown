require "kemal"
require "json"

require "./http/models/*"
require "./http/errors/*"
require "./http/controllers/*"
require "./http/middleware/*"

module MyServer
  class Server
    def initialize
      # Middlewares
      add_handler MyServer::HttpAPI::ApiHandler.new

      get "/" do |env|
        env.redirect "/index.html"
      end

      get "/get_images" do |env|
        HttpAPI::ImageController.get_images(env)
      end

      get "/get_images_with_audios" do |env|
        HttpAPI::ImageController.get_images_with_audios(env)
      end

      post "/upload_image" do |env|
        HttpAPI::ImageController.upload_image(env)
      end

      post "/update_image" do |env|
        HttpAPI::ImageController.update_image(env)
      end

      get "/get_audios" do |env|
        HttpAPI::AudioController.get_audios(env)
      end

      post "/upload_audio" do |env|
        HttpAPI::AudioController.upload_audio(env)
      end

      post "/update_audio" do |env|
        HttpAPI::AudioController.update_audio(env)
      end

      Kemal.run 9002
    end
  end
end

MyServer::Server.new
