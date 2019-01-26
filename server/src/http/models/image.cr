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
    end
  end
end
