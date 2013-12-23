module Angus
  module FileHandler

    # Override if you want a custom file mapping.
    def mapping
      {}
    end

    def is_erb?(file)
      file.end_with?('.erb')
    end

    def copy_erb_file(file, name, base_path = nil)
      base_path = name if base_path.nil?

      tmp_file = Tempfile.new(File.basename(file))

      source = File.expand_path(base.find_in_source_paths(file.to_s))
      content  = ERB.new(File.binread(source)).result(binding)

      File.open(tmp_file.path, 'w') { |f| f << content }
      tmp_file.close

      base.copy_file(tmp_file.path, File.join(base_path, filename_resolver(file, name)))
    end

    def filename_resolver(file, app_name)
      if mapping[file].nil?
        file.gsub('.erb', '')
      else
        mapping[file].call(self, app_name)
      end
    end

  end
end