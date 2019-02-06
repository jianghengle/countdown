module MyServer
  module HttpAPI
    class Image
      property image_name : String
      property image_file : String
      property audio_name : String

      raise "No static dir setup" unless ENV.has_key?("COUNTDOWN_STATIC")
      @@image_dir = File.join(ENV["COUNTDOWN_STATIC"], "images")

      def initialize(@image_file)
        image_ext = File.extname(@image_file)
        name = @image_file[0, (@image_file.size - image_ext.size)]
        @audio_name = File.extname(name)[1..-1]
        @image_name = name[0, (name.size - @audio_name.size - 1)]
      end

      def to_json(audio_file = "")
        String.build do |str|
          str << "{"
          str << "\"imageName\":" << @image_name.to_json << ","
          str << "\"imageFile\":" << @image_file.to_json << ","
          str << "\"audioName\":" << @audio_name.to_json << ","
          str << "\"audioFile\":" << audio_file.to_json
          str << "}"
        end
      end

      def update(new_image_name, new_audio_name)
        image_ext = File.extname(@image_file)
        image_name = @image_name
        new_image_name = new_image_name.strip(".")
        if @image_name != new_image_name
          unless new_image_name.empty?
            names = Image.get_images.map { |i| i.image_name }
            i = 0
            new_name = new_image_name
            while names.includes? new_name
              i = i + 1
              new_name = new_image_name + "(" + i.to_s + ")"
            end
            image_name = new_name
          end
        end
        audio_name = new_audio_name
        image_file = image_name + "." + audio_name + image_ext

        old_full_path = File.join(@@image_dir, @image_file)
        new_full_path = File.join(@@image_dir, image_file)
        if (old_full_path != new_full_path)
          File.rename(old_full_path, new_full_path)
        end
        Image.new(image_file)
      end

      def self.get_images
        images = [] of Image
        Dir.each @@image_dir do |image_file|
          next if image_file.starts_with? "."
          images << Image.new(image_file)
        end
        images
      end

      def self.upload_image(env)
        image_file = ""
        HTTP::FormData.parse(env.request) do |part|
          if part.name == "file"
            filename = part.filename
            raise "No filename included in upload" unless filename.is_a?(String)
            image_file = Image.get_unique_image_file(filename)
            target_path = File.join(@@image_dir, image_file)
            File.open(target_path, "w") do |f|
              IO.copy(part.body, f)
            end
          end
        end
        Image.new(image_file)
      end

      def self.get_unique_image_file(filename)
        ext = File.extname(filename)
        name = filename[0, (filename.size - ext.size)]
        images = Image.get_images.map { |i| i.image_name }

        i = 0
        new_name = name
        while images.includes? new_name
          i = i + 1
          new_name = name + "(" + i.to_s + ")"
        end
        new_name + ".Tada" + ext
      end

      def self.find_image(image_name)
        Image.get_images.each do |image|
          return image if image.image_name == image_name
        end
        nil
      end

      def self.update_image(old_image_name, new_image_name, new_audio_name)
        image = Image.find_image(old_image_name)
        raise "Cannot find image" if image.nil?
        image.update(new_image_name, new_audio_name)
      end
    end
  end
end
