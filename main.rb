require "#{File.dirname(__FILE__)}/client"
require "#{File.dirname(__FILE__)}/file_descriptor"
require "#{File.dirname(__FILE__)}/moderator"
require "#{File.dirname(__FILE__)}/user"
require 'yaml'

class Main

  def start
    #initialize
    User.load("#{File.dirname(__FILE__)}/users.yaml")
    FileDescriptor.load("#{File.dirname(__FILE__)}/files.yaml")
    loop do
      puts "1. Log in"
      puts "2. Create account"
      input = gets.chomp
      puts
      begin
        case input
          when "1" then
            puts "Enter username"
            username = gets.chomp
            puts "Enter password"
            password = gets.chomp
            @user = User.login(username, password)
            puts
            @user.is_a?(Client) ? client_logged_in : moderator_logged_in
            break
          when "2" then
            puts "Enter username"
            username = gets.chomp
            puts "Enter password"
            password = gets.chomp
            puts "Enter download speed"
            speed = Float(gets.chomp).round(2)
            Client.new(username, password, speed)
            puts "Client created successfully\n\n"
          when "3" then
            break
          else
            puts "Unrecognized command\n\n"
        end
      rescue Exception => msg
        puts "\n#{msg}\n\n"
      end
    end
    User.save("#{File.dirname(__FILE__)}/users.yaml")
    FileDescriptor.save("#{File.dirname(__FILE__)}/files.yaml")
  end

  def client_logged_in
    loop do
      puts "1. Get file list"
      puts "2. Search for file"
      puts "3. Get top rated files"
      puts "4. See downloads"
      puts "5. Upload file"
      puts "6. Set download speed"
      puts "7. Account management"
      puts "8. Logout"
      input = gets.chomp
      puts
      begin
        case input
          when "1" then
            files = FileDescriptor.get_file_list.to_a
            file_list(files)
          when "2" then
            puts "Enter file name or part of it"
            query = gets.chomp
            puts
            files = FileDescriptor.search(query).to_a
            files.empty? ? (puts "No files found\n\n") : file_list(files)
          when "3" then
            files = FileDescriptor.get_highest_rated_files.to_a
            file_list(files) {
              puts "Top rated files:"
              i = 0
              files.each do |f|
                i += 1
                puts "#{i}. #{f} #{FileDescriptor.get_file(f).rating}"
              end
              i
            }
          when "4" then
            download_list
          when "5" then
            puts "Enter file name"
            u_name = gets.chomp
            puts "Enter file size"
            u_size = Float(gets.chomp).round(2)
            @user.upload_file(FileDescriptor.new(u_name, u_size, true))
            puts "\nUpload started\n\n"
          when "6" then
            puts "Download speed: #{@user.get_total_speed.round(2)} mbps"
            puts "Set prefered download speed"
            input = gets.chomp
            @user.set_speed(Float(input))
            puts "\nDownload speed is now #{@user.get_total_speed.round(2)}\n\n"
          when "7" then
            account_management
            break if @user.nil?
          when "8" then
            break
          else
            puts "Unrecognized command\n\n"
        end
      rescue Exception => msg
        puts "\n#{msg}\n\n"
      end
    end
    @user.cancel_unfinished_downloads unless @user.nil?
  end

  def file_list(files)
    loop do
      if block_given?
        i = yield
      else
        puts "Select file:"
        i = 0
        files.each { |f| i += 1; puts "#{i}. #{f}" }
      end
      puts "x. Back"
      input = gets.chomp
      puts
      break if input == "x"
      if input.between?("1", "#{i}")
        file = FileDescriptor.get_file(files[Integer(input) - 1])
        loop do
          puts "Name: #{file.name}; Size: #{file.size}; Rating: #{file.rating}; Date uploaded: #{file.date}"
          puts "1. Download file"
          puts "2. Rate file"
          puts "3. Back"
          input = gets.chomp
          puts
          case input
            when "1" then
              @user.download_file(file)
              puts "Download started\n\n"
            when "2" then
              begin
                puts "Enter rating between [1..5]"
                rating = Integer(gets.chomp)
                puts
                file.rate(@user.username, rating)
                puts "FileDescriptor rated successfully\n\n"
              rescue Exception => msg
                puts "#{msg}\n\n"
              end
            when "3" then
              break
            else
              puts "Unrecognized command\n\n"
          end
        end
      else
        puts "Unrecognized command\n\n"
      end
    end
  end

  def download_list
    if @user.downloads.empty?
      puts "There are no downloads\n\n"
    else
      loop do
        puts "Downloads list:"
        i = 0
        @user.downloads.each do |d|
          i += 1
          puts "#{i}. #{d.file.name} #{d.progress.round(2)}% #{d.get_status}"
        end
        puts "r. Refresh"
        puts "x. Back"
        input = gets.chomp
        puts
        next if input == "r"
        break if input == "x"
        if input.between?("1", "#{i}")
          download = @user.get_download(@user.downloads.to_a[Integer(input) - 1].file.name)
          loop do
            puts "FileDescriptor: #{download.file.name}; Size: #{download.file.size}; Progress: #{download.progress.round(2)} Status: #{download.get_status}"
            puts "1. Pause download"
            puts "2. Resume download"
            puts "3. Cancel download"
            puts "4. Back"
            input = gets.chomp
            puts
            case input
              when "1" then
                @user.pause_download(download.file.name)
              when "2" then
                @user.resume_download(download.file.name)
              when "3" then
                @user.stop_download(download.file.name)
                break
              when "4" then
                break
              else
                puts "Unrecognized command\n\n"
            end
          end
        else
          puts "Unrecognized command\n\n"
        end
      end
    end
  end

  def account_management
    loop do
      puts "1. Change password"
      puts "2. Delete account"
      puts "3. Back"
      input = gets.chomp
      puts
      case input
        when "1" then
          begin
            puts "Enter new password"
            pass1 = gets.chomp
            puts "Repeat password"
            pass2 = gets.chomp
            puts
            @user.change_password(pass1, pass2)
            puts "Password changed successfully\n\n"
          rescue Exception => msg
            puts "#{msg}\n\n"
          end
        when "2" then
          puts "Are you sure you want to delete your account?"
          puts "n. No"
          puts "y. Yes"
          input = gets.chomp
          puts
          if input == "y"
            Client.unregister(@user)
            @user = nil
            break
          end
        when "3" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
  end

  def moderator_logged_in
    loop do
      puts "1. Get client list"
      puts "2. Search for client"
      puts "3. Delete file"
      puts "4. Logout"
      input = gets.chomp
      puts
      case input
        when "1" then
          clients = @user.get_client_list.to_a
          loop do
            puts "Select client:"
            i = 0
            clients.each { |c| i += 1; puts "#{i}. #{c.username}" }
            puts "x. Back"
            input = gets.chomp
            puts
            break if input == "x"
            if input.between?("1", "#{i}")
              client = clients[Integer(input) - 1]
              show_client(client)
              break
            else
              puts "Unrecognized command\n\n"
            end
          end
        when "2" then
          begin
            puts "Enter client username"
            username = gets.chomp
            puts
            client = @user.find_client(username)
            show_client(client)
          rescue Exception => msg
            puts "#{msg}\n\n"
          end
        when "3" then
          loop do
            files = FileDescriptor.get_file_list.to_a
            puts "Select file:"
            i = 0
            files.each { |f| i += 1; puts "#{i}. #{f}" }
            puts "x. Back"
            input = gets.chomp
            puts
            break if input == "x"
            if input.between?("1", "#{i}")
              file = FileDescriptor.get_file(files[Integer(input) - 1])
              @user.delete_file(file)
              puts "File deleted"
            else
              puts "Unrecognized command\n\n"
            end
          end
        when "4" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
  end

  def show_client(client)
    loop do
      puts "Client: #{client.username}"
      puts "1. Delete client"
      puts "2. Back"
      input = gets.chomp
      puts
      case input
        when "1" then
          @user.delete_client(client)
          puts "Client deleted\n\n"
          break
        when "2" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
  end

  def initialize
    User.users = Set.new
    FileDescriptor.files = Set.new
    Client.new("and", "123", 1)
    Moderator.new("mod", "0000")
    FileDescriptor.new("ruby", 15)
    FileDescriptor.new("rubymine", 200)
    FileDescriptor.new("netbeans", 100)
    FileDescriptor.new("java", 30)
  end

  main = Main.new
  main.start
end