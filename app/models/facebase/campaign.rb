module Facebase
  class Campaign < ActiveRecord::Base
    has_many :streams


  end
end
