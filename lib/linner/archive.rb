require "rubygems/package"

module Linner
  class Archive

    class << self
      def tar(glob, dest)
        archived = StringIO.new
        Gem::Package::TarWriter.new(archived) do |tar|
          Dir[glob].each do |file|
            paths = Linner.env.paths
            mode = File.stat(file).mode
            relative_file = file.gsub /^#{paths.join("|")}\/?/, ""
            if File.directory?(file)
              tar.mkdir relative_file, mode
            else
              tar.add_file relative_file, mode do |tf|
                File.open(file, "rb") { |f| tf.write f.read }
              end
            end
          end
        end

        archived.rewind

        Zlib::GzipWriter.open(dest) do |gz|
          gz.write archived.string
        end
      end

      def untar(path, dest)
        extracted = Gem::Package::TarReader.new Zlib::GzipReader.open(path)

        extracted.rewind

        extracted.each do |entry|
          file = File.join dest, entry.full_name
          if entry.directory?
            FileUtils.mkdir_p file
          else
            directory = File.dirname(file)
            FileUtils.mkdir_p directory unless File.directory?(directory)
            File.open file, "wb" do |f|
              f.print entry.read
            end
          end
        end

        extracted.close
      end
    end
  end
end
