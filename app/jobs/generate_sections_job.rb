# frozen_string_literal: true

class GenerateSectionsJob < ApplicationJob
  queue_as :default

  def perform(pdf)
    Rails.logger.warn "GenerateSectionsJob called for Pdf##{pdf.id} with status #{pdf.status} - expected status pending" unless pdf.status_pending?

    pdf.status_processing!
    GenerateSectionsService.new(pdf).run!
    pdf.status_ready!
  end
end
