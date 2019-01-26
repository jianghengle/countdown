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

      # get "/download_image/:name" do |env|
      #   HttpAPI::ImageController.download_image(env)
      # end

      post "/upload_image" do |env|
        HttpAPI::ImageController.upload_image(env)
      end

      Kemal.run 9002
    end
  end
end

MyServer::Server.new
