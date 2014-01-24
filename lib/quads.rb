#!/usr/bin/env ruby

require 'csv'
require 'json'
require 'stringio'

module Quads
  class Quads
    class Genre
      attr_accessor :group, :name, :min, :max, :now

      def initialize(**args)
        args.each do |k, v|
          self.instance_variable_set("@#{k}".to_sym, v)
        end
      end

      def lack
        @min - @now
      end

      def lack?
        lack > 0
      end
    end

    def initialize(csv: nil, major: nil)
      raise ArgumentError, 'Major is required.' if major.nil?
      if csv
        src = StringIO.new(IO.read(csv))
      else
        src = $stdin
      end

      rule_coins = open('./lib/rules/coins.json')
      json_coins = JSON.load(rule_coins.read)
      rule_coins.close

      @@CREDITS= json_coins["credits"].map { |j|
        {j.keys.first.to_sym => j[j.keys.first]}
      }
      @@EX10s  = json_coins["ex10s"].map   { |j| j }
      @@GROUPS = json_coins["credits"].map { |j| j.keys.first.to_sym }

      @genre = {}
      @@CREDITS.each do |key|
        key.each do |k,v|
          @genre[k] = Genre.new(name: v["name"], min: v["min"], max: v["max"],now: 0.0)
        end
      end
      @subjects = select_gb(get_subjects(src, major))
    end

    def print
      @@GROUPS.each do |group|
        puts_group(@subjects, group)
      end

      _EBSE_sum =
        %i(EX10 EXGB EXMY EXOT).map{|g| @genre[g].now}.inject(:+)
      ebse_diff = 48.5 - _EBSE_sum
      puts "専門科目選択科目 => #{_EBSE_sum} / 48.5 単位"
      if ebse_diff > 0.0
        puts "専門科目選択科目が、あと#{ebse_diff}単位くらい足りないです。"
      else
        puts "専門科目選択科目は、多分足りてます。"
      end
      puts

      _ALL_sum = GROUPS.map{|g| @genre[g].now}.inject(:+)
      all_diff = 126.0 - _ALL_sum
      puts "全部 => #{_ALL_sum} / 126.0 単位"
      if all_diff > 0.0
        puts "全体的に、あと#{all_diff}単位くらい足りないです。"
      else
        puts "多分卒業できます。"
      end
    end

    private
    def normalize_csv_string(io)
      io.read.gsub(/\r/, '')
    end

    def get_subjects(io, major)
      @data = normalize_csv_string(io)

      subjects = Array.new
      source = CSV.parse(@data, headers: true)
      source.each do |s|
        # 落単してたら取得単位一覧に追加しない
        unless ["F", "D"].member?(s["総合評価"])
          sub = {
               id: s["科目番号"],
             name: s["科目名 "],
            units: s["単位数"].to_f,
            group: get_group(s["科目番号"], s["科目区分"], major)
          }
          subjects << sub
        end
      end

      return subjects
    end

    def get_group(id, cls, major)
      g = 
        case cls
        # 専門 必修     => 科目区分が"1A"
        when "1A"      then :EXRE
        # 専門 選択     => 科目区分が"2A"   => 更に細分化
        when "2A"      then get_exse(id, major)
        # 専門基礎 必修 => 科目区分が"1B"
        when "1B"      then :EBRE
        # 専門基礎 選択 => 科目区分が"2B"
        when "2B"      then :EBSE
        # 基礎共通 総I  => 科目区分が"1R"
        when "1R"      then :BAS1
        # 基礎共通 総II => 科目区分が"1S"
        when "1S"      then :BAS2
        # 基礎共通 体育 => 科目区分が"1E"
        when "1E"      then :BAPE
        # 基礎共通 英語 => 科目区分が"1F"
        when "1F"      then :BAEN
        # 自由          => 科目区分が"3[A-S]"
        when /3[A-S]/  then :FREE
        end
      (g.is_a? Symbol) ? [g] : g
    end

    def get_exse(id, major)
      groups = []

      # いわゆる"上10"な科目
      if @@EX10s.include?(id) then groups << :EX10 end
      # GB1シリーズ
      if id =~ /GB1\d+/     then groups << :EXGB end
      # 主専攻 (2, 3, 4)
      if id =~ /GB#{major}\d+/ || id =~ /GA\d+/ then groups << :EXMY end
      # 他専攻 (2, 3, 4)
      if id =~ /GB[^1#{major}]\d+/ then groups << :EXOT end

      return groups
    end

    def select_gb(subjects)
      subjects.each do |s|
        if s[:group].length == 1
          g = s[:group].first
          unless [:EX10, :EXMY, :EXOT].include?(g)
            @genre[g].now += s[:units]
          end
        end
      end

      ### :EXMY
      subjects.select { |s| [:EX10,:EXMY,:EXOT].include?(s[:group].first) }.each do |s|
        if s[:group].include?(:EXMY) && @genre[:EXMY].lack?
          s[:group] = [:EXMY]
          @genre[:EXMY].now += s[:units]
        end
      end

      ### :EX10
      subjects.select { |s| s[:group].include?(:EX10) }.each do |s|
        if @genre[:EX10].lack?
          s[:group] = [:EX10]
          @genre[:EX10].now += s[:units]
        end
      end

      ### :EXOT
      subjects.select { |s| s[:group].include?(:EXOT) }.each do |s|
        s[:group] = [:EXOT]
        @genre[:EXOT].now += s[:units]
      end

      return subjects
    end


    def puts_group(subjects, group)
      genre = @genre[group]
      puts "[#{genre.name}]"
      subjects.each do |s|
        if s[:group].first == group
          units = sprintf('%1.1f', s[:units])
          puts "* #{units}単位 #{s[:id]} #{s[:name]}"
        end
      end

      puts "計 #{genre.now} / #{genre.min} 単位"
      if genre.lack?
        puts "あと#{genre.lack}単位くらい足りないです。"
      else
        puts "たぶんおｋ"
      end
      puts ""
    end
  end
end

