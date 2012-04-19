require "#{File.dirname(__FILE__)}/client"
require "#{File.dirname(__FILE__)}/file_descriptor"
require 'yaml'

class Main

  def start
    #initialize
    Client.clients = File.open("#{File.dirname(__FILE__)}/client.yaml", "r") { |object| YAML::load(object) }
    FileDescriptor.files = File.open("#{File.dirname(__FILE__)}/file.yaml", "r") { |object| YAML::load(object) }
    loop do
      puts "1. Log in"
      puts "2. Create account"
      input = gets.chomp
      puts
      case input
        when "1" then
          puts "Enter username"
          username = gets.chomp
          puts "Enter password"
          password = gets.chomp
          @client = Client.login(username, password)
          puts
          if @client.nil?
            puts "Wrong username or password\n\n"
          else
            logged_in
            break
          end
        when "2" then
          begin
            puts "Enter username"
            username = gets.chomp
            puts "Enter password"
            password = gets.chomp
            puts "Enter download speed"
            speed = Float(gets.chomp).round(2)
            Client.new(username, password, speed)
            puts "Client created successfully\n\n"
          rescue Exception => msg
            puts "\n#{msg}\n\n"
          end
        when "3" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
    @client.cancel_unfinished_downloads unless @client.nil?
    File.open("#{File.dirname(__FILE__)}/client.yaml", "w") { |file| file.puts YAML::dump(Client.clients) }
    File.open("#{File.dirname(__FILE__)}/file.yaml", "w") { |file| file.puts YAML::dump(FileDescriptor.files) }
  end

  def logged_in
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
      case input
        when "1" then
          files = FileDescriptor.get_file_list.to_a
          file_list(files)
        when "2" then
          puts "Enter file name or part of it"
          query = gets.chomp
          puts
          files = FileDescriptor.search(query).to_a
          if files.empty?
            puts "No files found\n\n"
          else
            file_list(files)
          end
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
          begin
            puts "Enter file name"
            u_name = gets.chomp
            puts "Enter file size"
            u_size = Float(gets.chomp).round(2)
            @client.upload_file(FileDescriptor.new(u_name, u_size, true))
            puts "\nUpload started\n\n"
          rescue Exception => msg
            puts "\n#{msg}\n\n"
          end
        when "6" then
          begin
            speed = @client.speed
            speed *= @client.active_downloads if @client.active_downloads > 1
            puts "Download speed: #{speed.round(2)} mbps"
            puts "Set prefered download speed"
            input = gets.chomp
            @client.set_speed(Float(input))
            speed = @client.speed
            speed *= @client.active_downloads if @client.active_downloads > 1
            puts "Download speed is now #{speed.round(2)}\n\n"
          rescue Exception => msg
            puts "#{msg}\n\n"
          end
        when "7" then
          account_management
          break if @client.nil?
        when "8" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
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
              @client.download_file(file)
              puts "Download started\n\n"
            when "2" then
              begin
                puts "Enter rating between [1..5]"
                rating = Integer(gets.chomp)
                puts
                file.rate(@client.username, rating)
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
    if @client.downloads.empty?
      puts "There are no downloads\n\n"
    else
      loop do
        puts "Downloads list:"
        i = 0
        @client.downloads.each do |d|
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
          download = @client.get_download(@client.downloads.to_a[Integer(input) - 1].file.name)
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
                @client.pause_download(download.file.name)
              when "2" then
                @client.resume_download(download.file.name)
              when "3" then
                @client.stop_download(download.file.name)
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
            @client.change_password(pass1, pass2)
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
            Client.unregister(@client)
            @client = nil
            break
          end
        when "3" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
  end

  def initialize
    Client.clients = Set.new
    FileDescriptor.files = Set.new
    Client.new("and", "123", 1)
    FileDescriptor.new("ruby", 15)
    FileDescriptor.new("rubymine", 200)
    FileDescriptor.new("netbeans", 100)
    FileDescriptor.new("java", 30)
  end

  main = Main.new
  main.start
end