# coding: utf-8

#== requireいろいろ
require_relative 'analyzer.rb'
require_relative 'responder.rb'
require_relative 'dictionary.rb'

#= 人工無能NORシステム本体
=begin
返答オブジェクトを保持したりそのうち人格とか機嫌とかを司るようになるであろうところ
NORオブジェクト一つ＝人工無能一人格のイメージ
あれ・・？ってことは辞書オブジェクトってこっちで持つべきじゃない？
特殊な機能を持つ人格が出てきたらサブクラスにすればよろしい
#== 変数
@name 名前
@dic_xxx 辞書ファイル
@dictionaries 辞書ファイルの配列[文脈,名詞,動詞,副詞,形容詞]
@responder 返答を司るオブジェクト
@analyzer 文章解析・学習を司るオブジェクト
=end
class Nor
  def initialize(name)
    @name = name
    @dic_meishi = Dictionary.new(name + '/dic/words_meishi.txt','＊名詞＊')
    @dic_doushi = Dictionary.new(name + '/dic/words_doushi.txt','＊動詞＊')
    @dic_fukushi = Dictionary.new(name + '/dic/words_fukushi.txt','＊副詞＊')
    @dic_keiyoshi = Dictionary.new(name + '/dic/words_keiyoshi.txt','＊形容詞＊')
    @dic_sentence = Dictionary.new(name + '/dic/sentence.txt','文構造辞書')
    @dictionaries = [@dic_sentence,@dic_meishi,@dic_doushi,@dic_fukushi,@dic_keiyoshi]
    @responder = RoboticResponder.new('Robotic',@dictionaries)
    @analyzer = MecabAnalyzer.new('Mecab',@dictionaries)
  end
  
  #== 入力された文章に対して返答を返す
  def dialogue(input)
    return @responder.response(input)
  end
  
  #== 入力された文章を解析し辞書に追加する
  def analyze(input)
    @analyzer.analyze(input)
  end
    
  def responder_name
    return @responder.name
  end
  
  def name
    return @name
  end
  
  def save
    @analyzer.save()
  end
end