# frozen_string_literal: true

class PublicController < ApplicationController
  def index
    @pdf = Pdf.new
  end
end
