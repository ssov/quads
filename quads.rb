#!/usr/bin/env ruby

require 'csv'

EX10s = [
    "GB20101", "GB20201", "GB20301",
    "GB30101", "GB30201", "GB30301", "GB30401",
    "GB40201", "GB40301", "GB42101"]

GROUPS = [:EXRE,:EX10,:EXGB,:EXMY,:EXOT,:EBRE,:EBSE,:BAS1,:BAS2,:BAPE,:BAEN,:FREE]

$groups_data = {
  EXRE: {name: "専門科目 必修科目",        need: 31.5,now: 0.0},
  EX10: {name: "専門科目 選択科目 上10",   need: 10.0,now: 0.0},
  EXGB: {name: "専門科目 選択科目 GB1",    need: 14.0,now: 0.0},
  EXMY: {name: "専門科目 選択科目 自専攻", need: 14.0,now: 0.0},
  EXOT: {name: "専門科目 選択科目 他専攻", need:  6.5,now: 0.0},
  EBRE: {name: "専門基礎 必修科目",        need: 16.0,now: 0.0},
  EBSE: {name: "専門基礎 選択科目",        need:  8.0,now: 0.0},
  BAS1: {name: "基礎科目 必修科目 総合I",  need:  2.0,now: 0.0},
  BAS2: {name: "基礎科目 必修科目 総合II", need:  6.0,now: 0.0},
  BAPE: {name: "基礎科目 必修科目 体育",   need:  3.0,now: 0.0},
  BAEN: {name: "基礎科目 必修科目 英語",   need:  4.5,now: 0.0},
  FREE: {name: "自由科目",                 need:  6.5,now: 0.0}}


def get_subjects(csv_path, major)
  f = File.open(csv_path)
  file = f.read.gsub(/\r/, "")
  f.close

  subjects = Array.new
  source = CSV.parse(file, headers: true)
  source.each { |s|
    # 落単してたら取得単位一覧に追加しない
    if s["総合評価"] != "F" && s["総合評価"] != "D"
      sub = Hash.new
      sub[:id]   = s["科目番号"]
      sub[:name] = s["科目名 "]
      sub[:units]= s["単位数"]
      sub[:group]= get_group(s["科目番号"], s["科目区分"], major)
      subjects << sub
    end
  }

  return subjects
end


def get_group(id, cls, major)
  groups = Array.new
  #puts "#{id}, #{cls}"

  # 専門 必修     => 科目区分が"1A"
  if cls == "1A"      then groups << :EXRE end
  # 専門 選択     => 科目区分が"2A"   => 更に細分化
  if cls == "2A"      then groups += get_exse(id, major) end
  # 専門基礎 必修 => 科目区分が"1B"
  if cls == "1B"      then groups << :EBRE end
  # 専門基礎 選択 => 科目区分が"2B"
  if cls == "2B"      then groups << :EBSE end
  # 基礎共通 総I  => 科目区分が"1R"
  if cls == "1R"      then groups << :BAS1 end
  # 基礎共通 総II => 科目区分が"1S"
  if cls == "1S"      then groups << :BAS2 end
  # 基礎共通 体育 => 科目区分が"1E"
  if cls == "1E"      then groups << :BAPE end
  # 基礎共通 英語 => 科目区分が"1F"
  if cls == "1F"      then groups << :BAEN end
  # 自由          => 科目区分が"3[A-S]"
  if cls =~ /3[A-S]/  then groups << :FREE end

  return groups
end


def get_exse(id, major)
  groups = Array.new

  # いわゆる"上10"な科目
  if EX10s.include?(id) then groups << :EX10 end
  # GB1シリーズ
  if id =~ /GB1\d+/     then groups << :EXGB end
  # 主専攻 (2, 3, 4)
  if id =~ /GB#{major}\d+/ || id =~ /GA\d+/ then groups << :EXMY end
  # 他専攻 (2, 3, 4)
  if id =~ /GB[^[1|#{major}]]\d+/ then groups << :EXOT end

  return groups.flatten
end


def select_gb(subjects)
  subjects.each { |s|
    if s[:group].length == 1
      unless [:EX10,:EXMY,:EXOT].include?(s[:group][0])
        $groups_data[s[:group][0]][:now] += s[:units].to_f
      end
    end
  }

  ### :EXMY
  subjects.select { |s| [:EX10,:EXMY,:EXOT].include?(s[:group][0]) }.each { |s|
    if s[:group].include?(:EXMY) && $groups_data[:EXMY][:need]-$groups_data[:EXMY][:now] > 0.0
      s[:group] = [:EXMY]
      $groups_data[:EXMY][:now] += s[:units].to_f
    end
  }

  ### :EX10
  subjects.select { |s| s[:group].include?(:EX10) }.each { |s|
    if $groups_data[:EX10][:need]-$groups_data[:EX10][:now] > 0.0
      s[:group] = [:EX10]
      $groups_data[:EX10][:now] += s[:units].to_f
    end
  }

  ### :EXOT
  subjects.select { |s| s[:group].include?(:EXOT) }.each { |s|
    s[:group] = [:EXOT]
    $groups_data[:EXOT][:now] += s[:units].to_f
  }

  return subjects
end


def puts_group(subjects, group)
  puts $groups_data[group][:name]
  subjects.each { |s|
    if s[:group][0] == group
      puts sprintf('%1.1f', s[:units]) + "単位 #{s[:id]} #{s[:name]}"
    end
  }
  _now  = $groups_data[group][:now]
  _need = $groups_data[group][:need]
  puts "計 #{_now} / #{_need} 単位"
  if _now-_need < 0.0
    puts "あと#{_need-_now}単位くらい足りないです。"
  else
    puts "たぶんおｋ"
  end
  puts ""
end


if __FILE__ == $0
  CSV_PATH  = ARGV[0]
  MAJOR     = ARGV[1]
  @subjects = select_gb(get_subjects(CSV_PATH, MAJOR))
  #puts @subjects

  GROUPS.each { |group|
    puts_group(@subjects, group)
  }

  _EBSE_sum = 0.0
  [:EX10,:EXGB,:EXMY,:EXOT].each { |g|
    _EBSE_sum += $groups_data[g][:now]
  }
  ebse_diff = 48.5 - _EBSE_sum
  puts "専門科目選択科目 => #{_EBSE_sum} / 48.5 単位"
  if ebse_diff > 0.0
    puts "専門科目選択科目が、あと#{ebse_diff}単位くらい足りないです。"
  else
    puts "専門科目選択科目は、多分足りてます。"
  end
  puts ""

  _ALL_sum = 0.0
  GROUPS.each { |g|
    _ALL_sum += $groups_data[g][:now]
  }
  all_diff = 126.0 - _ALL_sum
  puts "全部 => #{_ALL_sum} / 126.0 単位"
  if all_diff > 0.0
    puts "全体的に、あと#{all_diff}単位くらい足りないです。"
  else
    puts "多分卒業できます。"
  end
end

