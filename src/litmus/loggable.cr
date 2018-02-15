module Litmus
  module Loggable
    @log = uninitialized Logger
    def debug(x); @log.debug(x) end
    def info(x);  @log.info(x)  end
    def warn(x);  @log.warn(x)  end
    def error(x); @log.error(x) end
    def fatal(x); @log.fatal(x) end
  end
end
