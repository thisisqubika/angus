require 'tempfile'
require 'erb'

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
      base_path ||= name

      tmp_file = Tempfile.new(File.basename(file))

      source  = File.expand_path(base.find_in_source_paths(file.to_s))
      template = File.binread(source)

      content =
        if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.6.0')
          # Ruby 2.5: no keyword args
          ERB.new(template, nil, '-').result(binding)
        else
          # Ruby 2.6+: keyword args ok
          ERB.new(template, trim_mode: '-').result(binding)
        end

      File.open(tmp_file.path, 'w') { |f| f << content }
      tmp_file.close

      base.copy_file(tmp_file.path, File.join(base_path, filename_resolver(file, name)))
    ensure
      tmp_file&.unlink
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
