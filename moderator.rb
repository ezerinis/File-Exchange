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
    client = Client.users.find { |u| u.username == name && u.is_a?(Client) }
    raise "No client with this username found" if client.nil?
    client
  end

  def delete_client(client)
    Client.users.delete(client)
  end

  def delete_file(file)
    FileDescriptor.files.delete(file)
  end
end