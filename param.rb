require_relative 'db_setup'

class Param < ActiveRecord::Base
  self.primary_key = :param
end