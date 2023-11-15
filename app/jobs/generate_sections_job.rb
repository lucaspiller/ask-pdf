class GenerateSectionsJob < ApplicationJob
  queue_as :default

  def perform(pdf)
    unless pdf.status_pending?
      Rails.logger.warn "GenerateSectionsJob called for Pdf##{pdf.id} with status #{pdf.status} - expected status pending"
    end

    pdf.status_processing!
    GenerateSectionsService.new(pdf).run!
    pdf.status_ready!
  end
end
