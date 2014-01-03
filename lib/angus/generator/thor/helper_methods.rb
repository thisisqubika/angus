module Angus
  module HelperMethods

    def pluralize(word)
      uncountable = %w(equipment information rice money species series fish sheep)
      rules = []

      irregular   = {
          'person' => 'people',
          'man'    => 'men',
          'child'  => 'children',
          'sex'    => 'sexes',
          'move'   => 'moves'
      }

      irregular.each do |word, replacement|
        rules << [word, replacement]
        rules << [replacement, replacement]
      end

      rules << [/^(ox)$/i               , '\1en'   ]
      rules << [/(quiz)$/i              , '\1zes'  ]
      rules << [/([m|l])ouse$/i         , '\1ice'  ]
      rules << [/(matr|vert|ind)ix|ex$/i, '\1ices' ]
      rules << [/(x|ch|ss|sh)$/i        , '\1es'   ]
      rules << [/([^aeiouy]|qu)ies$/i   , '\1y'    ]
      rules << [/([^aeiouy]|qu)y$/i     , '\1ies'  ]
      rules << [/(hive)$/i              , '\1s'    ]
      rules << [/(?:([^f])fe|([lr])f)$/i, '\1\2ves']
      rules << [/sis$/i                 , 'ses'    ]
      rules << [/([ti])um$/i            , '\1a'    ]
      rules << [/(buffal|tomat)o$/i     , '\1oes'  ]
      rules << [/(bu)s$/i               , '\1ses'  ]
      rules << [/(alias|status)$/i      , '\1es'   ]
      rules << [/(octop|vir)us$/i       , '\1i'    ]
      rules << [/(ax|test)is$/i         , '\1es'   ]
      rules << [/s$/i                   , 's'      ]
      rules << [/$/                     , 's'      ]

      result = word.to_s.dup

      if word.empty? || uncountable.include?(result.downcase[/\b\w+\Z/])
        result
      else
        rules.each { |(rule, replacement)| break if result.sub!(rule, replacement) }
        result
      end
    end

    def classify(string)
      string.sub(/^[a-z\d]*/) { $&.capitalize }.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!('-', '_')
      word.downcase!
      word
    end

  end
end