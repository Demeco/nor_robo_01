# coding: utf-8

#= 解析クラス
=begin
文章を解析する働きを持つ
解析結果オブジェクト Sampleを返す
Sampleもここで一緒に定義する
=end

require 'mecab'
require 'natto'

require_relative 'dictionary.rb'

#== 基底クラス
class Analyzer
  def initialize(name,dictionaries)
    @name = name
  end
  
  def analyze(input)
    return ''
  end
  
  def name
    return @name
  end
end


#== 単語の基本形を学習してくる
class MecabAnalyzer < Analyzer
  def initialize(name,dictionaries)
    super
    @natto = Natto::MeCab.new
    @dictionaries = dictionaries
  end
  
  def save()
    @dictionaries.each do |dic|
      dic.save()
    end
  end
   
  def analyze(input)
    #学習
    @natto.parse(input) do |n|
      features = n.feature.split(",")
      if /名詞|動詞|副詞|形容詞/ =~ features[0]#辞書に放り込むタイプの単語なら原型を放り込む
        case features[0]
          when '名詞' then
            @dictionaries[1].add_word(features[6]) if features[6] != "*"
          when '動詞' then
            @dictionaries[2].add_word(features[6])
          when '副詞' then
            @dictionaries[3].add_word(features[6])
          when '形容詞' then
            @dictionaries[4].add_word(features[6])
        end
      end
    end
  end
end

#== Sampleクラス
=begin
解析結果のオブジェクト
変数を色々持っていると言うだけのしろもの
=end
class Sample
  
end