module CustomMatchers

  class Contain

    def initialize(username)
      @username = username
    end

    def matches?(clients)
      @clients = clients
      @clients.find {|c| c.username == @username}
    end

    def failure_message
      "expected #{@username} to be in #{@clients.inspect}"
    end

    def negative_failure_message
      "expected #{@username} not to be in #{@clients.inspect}"
    end
  end

  def contain(username)
    Contain.new(username)
  end
end