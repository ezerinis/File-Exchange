require "#{File.dirname(__FILE__)}/client"

class Moderator < User

  def initialize(username, password)
    super(username, password)
    @@users.add(self)
  end

  def get_client_list
    Client.users.find_all { |u| u.is_a?(Client) }
  end

  def find_client(name)
    Client.users.find { |u| u.username == name && u.is_a?(Client) }
  end

  def delete_client(client)
    Client.users.delete(client)
  end

  def delete_file(file)
    FileDescriptor.files.delete(file)
  end
end