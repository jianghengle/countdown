module MyServer
  module HttpAPI
    class Image
      raise "No images dir setup" unless ENV.has_key?("COUNTDOWN_IMAGES")
      @@root = ENV["COUNTDOWN_IMAGES"]

      def self.get_images
        images = [] of String
        Dir.each @@root do |name|
          next if name.starts_with? "."
          images << name
        end
        images
      end

      def self.download_path(image)
        File.join(@@root, image)
      end

      def self.upload_image(env)
        unique_name = ""
        HTTP::FormData.parse(env.request) do |part|
          if part.name == "file"
            filename = part.filename
            raise "No filename included in upload" unless filename.is_a?(String)

            unique_name = Image.get_unique_filename(filename)
            target_path = File.join(@@root, unique_name)
            File.open(target_path, "w") do |f|
              IO.copy(part.body, f)
            end
          end
        end
        unique_name
      end

      def self.get_unique_filename(filename)
        path = @@root
        ext = File.extname(filename)
        name = filename[0, (filename.size - ext.size)]
        new_name = filename
        i = 0
        while File.exists?(File.join(path, new_name))
          i = i + 1
          new_name = name + "_" + i.to_s + ext
        end
        new_name
      end
    end
  end
end
