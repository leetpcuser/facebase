module Facebase
  class Stream < ActiveRecord::Base
    belongs_to :campaign
    has_many :components
  end
end
