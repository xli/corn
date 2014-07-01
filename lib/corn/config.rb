
module Corn
  module Config
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def config(hash={})
        @config ||= {}
        if hash.empty?
          @config
        else
          @config.merge!(hash)
          hash.each do |key, value|
            if self.respond_to?(key)
              next
            end
            q = !!value == value ? '?' : ''
            self.class_eval <<-RUBY, __FILE__, __LINE__
              def self.#{key}#{q}
                r = @config[:#{key}]
                r.is_a?(Proc) ? r.call : r
              end
            RUBY
          end
          @config
        end
      end
    end
  end
end
