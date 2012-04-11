require "#{File.dirname(__FILE__)}/file_exchange"
require 'yaml'

class Main

  def start
    @fe = FileExchange.new
    @fe.create_client("and", "123", 1)
    @fe.create_file("ruby", 15)
    @fe.create_file("rubymine", 200)
    @fe.create_file("netbeans", 100)
    @fe.create_file("java", 30)

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
          @client = @fe.login(username, password)
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
            if @fe.create_client(username, password, speed).nil?
              puts "Client already exists\n\n"
            else
              puts "Client created successfully\n\n"
            end
          rescue Exception => msg
            puts "#{msg}\n\n"
          end
        when "3" then
          break
        else
          puts "Unrecognized command\n\n"
      end
    end
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
          files = @fe.get_file_list.to_a
          file_list(files)
        when "2" then
          puts "Enter file name or part of it"
          query = gets.chomp
          puts
          files = @fe.search(query).to_a
          if files.empty?
            puts "No files found\n\n"
          else
            file_list(files)
          end
        when "3" then
          files = @fe.get_highest_rated_files.to_a
          file_list(files) {
            puts "Top rated files:"
            i = 0
            files.each do |f|
              i += 1
              puts "#{i}. #{f} #{@fe.get_file(f).rating}"
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
            @fe.upload_file(u_name, u_size, @client)
            puts "\nUpload started\n\n"
          rescue Exception => msg
            puts "#\n{msg}\n\n"
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
          File.open("#{File.dirname(__FILE__)}/dump.yaml", "w") { |file| file.puts YAML::dump(@fe) }
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
        file = @fe.get_file(files[Integer(input) - 1])
        loop do
          puts "Name: #{file.name}; Size: #{file.size}; Rating: #{file.rating}; Date uploaded: #{file.date}"
          puts "1. Download file"
          puts "2. Rate file"
          puts "3. Back"
          input = gets.chomp
          puts
          case input
            when "1" then
              @client.new_download(file)
              puts "Download started\n\n"
            when "2" then
              begin
                puts "Enter rating between [1..5]"
                rating = Integer(gets.chomp)
                puts
                file.rate(@client.username, rating)
                puts "File rated successfully\n\n"
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
          puts "#{i}. #{d.file.name} #{d.progress.round(2)}%"
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
            puts "File: #{download.file.name}; Size: #{download.file.size}; Progress: #{download.progress.round(2)}%"
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
            @fe.unregister(@client)
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

  main = Main.new
  main.start
end