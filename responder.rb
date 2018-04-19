# coding: utf-8

#= 返答に関するクラス
=begin
文章を作り出す働きをする
作り出し方がそれぞれのクラスでちょっと異なる
=end

require_relative 'dictionary.rb'

#== 基底クラス
#無言
class Responder
  def initialize(name, dictionaries)
    @name = name
  end
  
  def response(input)
    return ''
  end
  
  def name
    return @name
  end
end

#== マジでおうむ返しするだけのクラス
class WhatResponder < Responder
  def response(input, dictionaries)
      return input
    end
end

#== あらかじめ用意された中からランダム返答返すだけのクラス
class RandomResponder < Responder
  def initialize(name, dictionaries)
    super
    @dictionaries = ['今日は寒いね','チョコ食べたい','きのう10円ひろった']
  end
  
  def response(input)
    return @dictionaries[rand(@dictionaries.size)]
  end
end

#== かたこと返答(文脈度外視)
class RoboticResponder < Responder
  def initialize(input,dictionaries)
    super
    @dictionaries = dictionaries
  end
    
  def response(input)
    #文生成
    text = @dictionaries[0].pick_word('dummy')
    @dictionaries.each do |dic|
      pattern = Regexp.new(dic.name())
      while (pattern =~ text) != nil do
        text = text.sub(pattern, dic.pick_word('dummy'))
      end
    end
    if text == ''
      #もし何かしくじってたらおうむ返しする
      return input
    else
      return text
    end
  end
end