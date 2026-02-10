module Angus
  module HelperMethods
    UNCOUNTABLE = %w[equipment information rice money species series fish sheep].freeze

    IRREGULAR = {
      'person' => 'people',
      'man'    => 'men',
      'child'  => 'children',
      'sex'    => 'sexes',
      'move'   => 'moves'
    }.freeze

    PLURAL_RULES = begin
      rules = []
      IRREGULAR.each do |w, replacement|
        rules << [w, replacement]
        rules << [replacement, replacement]
      end

      rules.concat([
        [/^(ox)$/i,                 '\1en'],
        [/(quiz)$/i,                '\1zes'],
        [/([m|l])ouse$/i,           '\1ice'],
        [/(matr|vert|ind)ix|ex$/i,  '\1ices'],
        [/(x|ch|ss|sh)$/i,          '\1es'],
        [/([^aeiouy]|qu)ies$/i,     '\1y'],
        [/([^aeiouy]|qu)y$/i,       '\1ies'],
        [/(hive)$/i,                '\1s'],
        [/(?:([^f])fe|([lr])f)$/i,  '\1\2ves'],
        [/sis$/i,                   'ses'],
        [/([ti])um$/i,              '\1a'],
        [/(buffal|tomat)o$/i,       '\1oes'],
        [/(bu)s$/i,                 '\1ses'],
        [/(alias|status)$/i,        '\1es'],
        [/(octop|vir)us$/i,         '\1i'],
        [/(ax|test)is$/i,           '\1es'],
        [/s$/i,                     's'],
        [/$/,                       's']
      ])

      rules.freeze
    end

    def pluralize(word)
      result = word.to_s.dup

      if result.empty? || UNCOUNTABLE.include?(result.downcase[/\b\w+\Z/])
        result
      else
        PLURAL_RULES.each { |(rule, replacement)| break if result.sub!(rule, replacement) }
        result
      end
    end

    def classify(string)
      string
        .sub(/^[a-z\d]*/) { $&.capitalize }
        .gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
        .gsub('/', '::')
    end

    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!('-', '_')
      word.downcase!
      word
    end
  end
end
