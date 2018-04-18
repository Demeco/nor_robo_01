require_relative 'db_setup'

class Param < ActiveRecord::Base
  selp.primary_key = :param
end