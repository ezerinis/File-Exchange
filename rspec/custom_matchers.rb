module CustomMatchers

  class IncludeClient

    def initialize(client)
      @client = client
    end

    def matches?(clients)
      @clients = clients
      @clients.find { |c| c.username == @client.username && c.password == @client.password && c.speed == @client.speed }
    end

    def failure_message
      "expected client #{@client.inspect} to be in #{@clients.inspect}"
    end

    def negative_failure_message
      "expected client #{@client.inspect} not to be in #{@clients.inspect}"
    end
  end

  def include_client(client)
    IncludeClient.new(client)
  end

  class IncludeFile

      def initialize(name)
        @name = name
      end

      def matches?(files)
        @files = files
        @files.find { |f| f.name == @name }
      end

      def failure_message
        "expected file '#{@name}' to be in #{@files.inspect}"
      end

      def negative_failure_message
        "expected file '#{@name}' not to be in #{@files.inspect}"
      end
    end

    def include_file(name)
      IncludeFile.new(name)
    end

end