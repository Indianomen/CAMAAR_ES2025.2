begin
  require 'e2mmap'
rescue LoadError
  # If e2mmap isn't available, provide a minimal implementation
  module Exception2MessageMapper
    def self.extend_object(obj)
      super
      obj.class_eval { @__map = {} } if obj.class == Class
    end
    
    def def_exception(name, msg, &block)
      @__map[name] = [msg, block]
    end
  end
  
  class Exception
    extend Exception2MessageMapper
  end
end

# Then require the old irb version
gem 'irb', '=1.1.1'
require 'irb/ruby-lex'