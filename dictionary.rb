# coding: utf-8

#= 辞書クラス
=begin
単語を貯めることを司るクラス
ファイルから読み込んだり出したり入れたりファイルに書き出したりする
=end

#== Dictionaryはひたすら1行に1つ単語を溜めるだけ
#メインクラスでもある
#path = 辞書のファイルパス,name = 辞書の名前
class Dictionary
  def initialize(path,name)
    @name = name
    @path = path
    @word = Array.new()
    if File.exist?(@path)
        File.open(@path) do |f|
          f.each do |line|
            line.chomp!
            next if line.empty?
            @word.push(line)
          end
        end
    else
      @word = ["テスト","てすと","test"]
      save()
    end
  end
  
  def name()
    return @name
  end
  
  def add_word(word)
    @word.push(word)
  end
  
  def pick_word(key)
    return @word[rand(@word.size)]
  end
  
  def save()
    File.open(@path,"w") do |f|
      @word.each do |phrase|
        f.puts(phrase)
      end
    end
  end
end