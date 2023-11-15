class PublicController < ApplicationController
  def index
    @pdf = Pdf.new
  end
end
