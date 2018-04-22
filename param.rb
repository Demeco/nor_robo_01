require_relative 'db_setup'

#= paramテーブルについて記述するクラス
=begin
param VARCHAR(32) プライマリキー
value VARCHAR(32)
=end
class Param < ActiveRecord::Base
  self.primary_key = :param
end