module MyServer
  module HttpAPI
    class Audio
      property audio_name : String
      property audio_file : String

      raise "No static dir setup" unless ENV.has_key?("COUNTDOWN_STATIC")
      @@audio_dir = File.join(ENV["COUNTDOWN_STATIC"], "audios")

      def initialize(@audio_file)
        ext = File.extname(@audio_file)
        @audio_name = audio_file[0, (@audio_file.size - ext.size)]
      end

      def to_json
        String.build do |str|
          str << "{"
          str << "\"audioName\":" << @audio_name.to_json << ","
          str << "\"audioFile\":" << @audio_file.to_json
          str << "}"
        end
      end

      def update(new_audio_name)
        audio_ext = File.extname(@audio_file)
        audio_name = @audio_name
        new_audio_name = new_audio_name.strip(".")
        if @audio_name != new_audio_name
          unless new_audio_name.empty?
            names = Audio.get_audios.map { |i| i.audio_name }
            i = 0
            new_name = new_audio_name
            while names.includes? new_name
              i = i + 1
              new_name = new_audio_name + "(" + i.to_s + ")"
            end
            audio_name = new_name
          end
        end
        audio_file = audio_name + audio_ext

        old_full_path = File.join(@@audio_dir, @audio_file)
        new_full_path = File.join(@@audio_dir, audio_file)
        if (old_full_path != new_full_path)
          File.rename(old_full_path, new_full_path)

          images = Image.get_images
          images.each do |i|
            if i.audio_name == @audio_name
              i.update(i.image_name, audio_name)
            end
          end
        end

        Audio.new(audio_file)
      end

      def self.get_audios
        audios = [] of Audio
        Dir.each @@audio_dir do |name|
          next if name.starts_with? "."
          audios << Audio.new(name)
        end
        audios
      end

      def self.get_audio_map
        audio_map = {} of String => Audio
        Dir.each @@audio_dir do |name|
          next if name.starts_with? "."
          audio = Audio.new(name)
          audio_map[audio.audio_name] = audio
        end
        audio_map
      end

      def self.upload_audio(env)
        audio_file = ""
        HTTP::FormData.parse(env.request) do |part|
          if part.name == "file"
            filename = part.filename
            raise "No filename included in upload" unless filename.is_a?(String)
            audio_file = Audio.get_unique_audio_file(filename)
            target_path = File.join(@@audio_dir, audio_file)
            File.open(target_path, "w") do |f|
              IO.copy(part.body, f)
            end
          end
        end
        Audio.new(audio_file)
      end

      def self.get_unique_audio_file(filename)
        ext = File.extname(filename)
        name = filename[0, (filename.size - ext.size)]
        audios = Audio.get_audios.map { |i| i.audio_name }

        i = 0
        new_name = name
        while audios.includes? new_name
          i = i + 1
          new_name = name + "(" + i.to_s + ")"
        end
        new_name + ext
      end

      def self.find_audio(audio_name)
        Audio.get_audios.each do |audio|
          return audio if audio.audio_name == audio_name
        end
        nil
      end

      def self.update_audio(old_audio_name, new_audio_name)
        audio = Audio.find_audio(old_audio_name)
        raise "Cannot find audio" if audio.nil?
        audio.update(new_audio_name)
      end
    end
  end
end
