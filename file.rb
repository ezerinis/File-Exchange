require 'date'

class File
  attr_accessor :name, :size, :date

  def initialize(name, size)
    @name = name
    @size = size
    @date = Date.today
  end
end