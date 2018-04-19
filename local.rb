# coding: utf-8

#= ローカル実行用
=begin
ローカルで何か実行する用のスクリプト
辞書更新するのとかに使おうと思う
=end

#==requireいろいろ
require_relative 'nor.rb'

def prompt(nor)
  return nor.name + ':' + nor.responder_name + '>'
end

#とりあえず今の所返答のテストができるってだけ
puts('Nor System prototype : proto')
proto = Nor.new('proto')
while true
  print('> ')
  input = gets
  input.chomp!
  break if input == ''
  
  response = proto.dialogue(input)
  puts(prompt(proto) + response)
end