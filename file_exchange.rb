require "#{File.dirname(__FILE__)}/client"
require "#{File.dirname(__FILE__)}/file_descriptor"
require 'set'

class FileExchange
  attr_accessor :clients, :files

  def initialize
    @clients = Set.new
    @files = Set.new
  end

  def create_client(username, password, speed)
    exists = @clients.find { |c| c.username == username }
    return nil if exists
    client = Client.new(username, password, speed)
    @clients.add(client)
    client
  end

  def login(username, password)
    @clients.find { |c| c.username == username && c.password == password }
  end

  def unregister(client)
    @clients.delete(client)
  end

  def create_file(name, size)
    exists = @files.find { |c| c.name == name }
    @files.add(FileDescriptor.new(name, size)) if !exists
    !exists
  end

  def upload_file(name, size, client)
    raise "FileDescriptor with this name already exists" if @files.find { |f| f.name == name }
    raise "FileDescriptor size is invalid" if !size.between?(1, 9999)
    client.new_download(FileDescriptor.new(name, size), self)
  end

  def get_file_list
    list = Set.new
    files.each{ |file| list.add(file.name) }
    list
  end

  def get_highest_rated_files
    list = Set.new
    3.times do
      highest = nil
      files.each do |file|
        if highest != nil
          highest = file if (highest.rating < file.rating) && !list.include?(file.name)
        else
          highest = file if !list.include?(file.name)
        end
      end
      list.add(highest.name) if highest != nil
    end
    list
  end

  def get_file(name)
    @files.find { |f| f.name == name }
  end

  def search(query)
    files = @files.find_all { |f| /#{query}/.match(f.name) }
    file_names = Set.new
    files.each { |f| file_names.add(f.name) }
    file_names
  end
end
