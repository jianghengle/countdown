require "./controller_base"

module MyServer
  module HttpAPI
    module ImageController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_images(ctx)
        begin
          images = Image.get_images
          images.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def download_image(ctx)
        begin
          name = get_param!(ctx, "name")
          path = Image.download_path(name)
          send_file ctx, path
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_image(ctx)
        begin
          name = Image.upload_image(ctx)
          {filename: name}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
