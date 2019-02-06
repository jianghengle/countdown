require "./controller_base"

module MyServer
  module HttpAPI
    module AudioController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_audios(ctx)
        begin
          audios = Audio.get_audios
          "[" + (audios.join(", ") { |i| i.to_json }) + "]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def upload_audio(ctx)
        begin
          audio = Audio.upload_audio(ctx)
          audio.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_audio(ctx)
        begin
          old_audio_name = get_param!(ctx, "oldAudioName")
          new_audio_name = get_param!(ctx, "newAudioName")
          audio = Audio.update_audio(old_audio_name, new_audio_name)
          audio.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
