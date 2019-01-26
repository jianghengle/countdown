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

      get "/download_image/:name" do |env|
        HttpAPI::ImageController.download_image(env)
      end

      Kemal.run
    end
  end
end

MyServer::Server.new
