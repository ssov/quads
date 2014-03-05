require 'io/console'
require 'mechanize'
require 'digest/sha1'

module Quads
  class Twins
    LOGIN_URL="https://twins.tsukuba.ac.jp/campusweb/"
    class << self
      def login
        print "Your id: "
        id = STDIN.gets.chomp
        print "Your password: "
        password = STDIN.noecho(&:gets).chomp
        puts "\nLogin..."

        agent = Mechanize.new
        page = agent.get(LOGIN_URL)
        @@toppage = page.form_with(name: "form") do |form|
          form.field_with(name: "userName").value = id
          form.field_with(name: "password").value = password
        end.submit

        unless @@toppage.search(".error").first.nil?
          puts "Login failed"
          exit
        end
      end

      def get_major
        begin
          puts "Get your major data..."
          left_menu = @@toppage.frame_with(name: "menu").click
          
          # open menu
          left_menu = left_menu.form_with(name: "MenuForm") do |form|
            form.subsysid = "F320"
            form.action = "/campusweb/campussquare.do#F320"
          end.submit
          
          # class list
          personal_page = left_menu.form_with(name: "linkForm") do |form|
            form._flowId = "CHW0001000-flow"
          end.submit

          major = personal_page.search("td.gakuseki")[4].text.gsub("情報学群情報科学類", "")
        rescue
          puts "スクレイピングに失敗"
          exit
        end
        major
      end

      def get_csv_path
        begin
          puts "Get your class data..."
          left_menu = @@toppage.frame_with(name: "menu").click
          
          # open menu
          left_menu = left_menu.form_with(name: "MenuForm") do |form|
            form.subsysid = "F360"
            form.action = "/campusweb/campussquare.do#F360"
          end.submit
          
          # class list
          class_page = left_menu.form_with(name: "linkForm") do |form|
            form._flowId = "SIW0001300-flow"
          end.submit

          # download page
          download_page = class_page.form_with(name: "InputForm") do |form|
            form._eventId = "output"
          end.submit

          # download csv file
          csv = download_page.form_with(name: "OutputForm") do |form| 
            form._eventId = "output"
          end.submit
          
          filename = "/tmp/#{Digest::SHA1.hexdigest(Time.now.to_f.to_s)}"
          File.open(filename, "w") do |f|
            f.puts csv.body.toutf8
          end
          filename
        rescue
          puts "スクレイピングに失敗"
          exit
        end
      end
    end
  end
end
