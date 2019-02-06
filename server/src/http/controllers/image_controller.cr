require "./controller_base"

module MyServer
  module HttpAPI
    module ImageController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_images(ctx)
        begin
          images = Image.get_images
          "[" + (images.join(", ") { |i| i.to_json }) + "]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_images_with_audios(ctx)
        begin
          images = Image.get_images
          audio_map = Audio.get_audio_map
          images_json = images.join(", ") do |i|
            audio = audio_map[i.audio_name]
            i.to_json(audio.audio_file)
          end
          "[" + images_json + "]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_image(ctx)
        begin
          image = Image.upload_image(ctx)
          image.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_image(ctx)
        begin
          new_image_name = get_param!(ctx, "newImageName")
          new_audio_name = get_param!(ctx, "newAudioName")
          old_image_name = get_param!(ctx, "oldImageName")
          image = Image.update_image(old_image_name, new_image_name, new_audio_name)
          image.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
