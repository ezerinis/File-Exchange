require 'date'
require 'set'

class FileDescriptor
  attr_accessor :name, :size, :date, :rating

  @@files = Set.new

  MIN_RATING = 1
  MAX_RATING = 5
  MIN_LENGTH = 1
  MAX_LENGTH = 15
  MAX_SIZE = 9999

  def initialize(name, size, is_upload = false)
    raise "File name length is invalid" unless name.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "File size is invalid" unless size.between?(0, MAX_SIZE)
    raise "File with this name already exists" if @@files.find { |c| c.name == name }
    @name = name
    @size = size.to_f
    @date = Date.today
    @rating = 0
    @clients = Set.new
    @sum = 0
    @@files.add(self) unless is_upload
  end

  def self.get_file_list
    list = Set.new
    @@files.each { |file| list.add(file.name) }
    list
  end

  def self.get_highest_rated_files
    list = Set.new
    3.times do
      highest = nil
      @@files.each do |file|
        if highest != nil
          highest = file if (highest.rating < file.rating) && !list.include?(file.name)
        else
          highest = file unless list.include?(file.name)
        end
      end
      list.add(highest.name) if highest != nil
    end
    list
  end

  def self.get_file(name)
    @@files.find { |f| f.name == name }
  end

  def self.search(query)
    files = @@files.find_all { |f| /#{query}/.match(f.name) }
    file_names = Set.new
    files.each { |f| file_names.add(f.name) }
    file_names
  end

  def rate(client_name, rating)
    raise "Client already rated this file" if @clients.include?(client_name)
    raise "Rating should be an integer value" unless rating.is_a?(Integer)
    raise "Rating should be between [#{MIN_RATING}..#{MAX_RATING}]" unless rating.between?(MIN_RATING, MAX_RATING)
    @clients.add(client_name)
    @sum += rating.to_f
    @rating = @sum / @clients.size
  end

  def self.files
    @@files
  end
end