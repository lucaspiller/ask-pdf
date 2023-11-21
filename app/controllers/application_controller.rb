# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :turbo_frame_request_variant

  protected

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
