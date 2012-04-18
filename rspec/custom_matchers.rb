module CustomMatchers

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

  class IncludeDownload

    def initialize(name)
      @name = name
    end

    def matches?(downloads)
      @downloads = downloads
      @downloads.find { |d| d.file.name == @name }
    end

    def failure_message
      "expected download '#{@name}' to be in #{@downloads.inspect}"
    end

    def negative_failure_message
      "expected download '#{@name}' not to be in #{@downloads.inspect}"
    end
  end

  def include_download(name)
    IncludeDownload.new(name)
  end

end