module Facebase
  class EmailsController < ApplicationController
    before_filter :authenticate_admin!

  end
end
