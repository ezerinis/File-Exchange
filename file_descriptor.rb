require 'date'
require 'set'

class FileDescriptor
  attr_accessor :name, :size, :date, :rating

  MAX = 5
  MIN = 1

  def initialize(name, size)
    @name = name
    @size = size
    @date = Date.today
    @rating = 0
    @clients = Set.new
    @sum = 0
  end

  def rate(name, rating)
    raise "Client already rated this file" if @clients.include?(name)
    raise "Rating should be between [#{MIN}..#{MAX}]" if !rating.between?(MIN, MAX)
    @clients.add(name)
    @sum += rating.to_f
    @rating = @sum / @clients.size
  end
end