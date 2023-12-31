# frozen_string_literal: true

class Pdf < ApplicationRecord
  STATUS_PENDING = 'pending'
  STATUS_PROCESSING = 'processing'
  STATUS_READY = 'ready'

  has_one_attached :original_file

  validates :original_file, content_type: ['application/pdf'], presence: true

  def status_pending?
    status == STATUS_PENDING
  end

  def status_processing!
    self.status = STATUS_PROCESSING
    save!
  end

  def status_processing?
    status == STATUS_PROCESSING
  end

  def status_ready!
    self.status = STATUS_READY
    save!
  end

  def status_ready?
    status == STATUS_READY
  end

  def sections
    value = read_attribute :sections
    JSON.parse! value if value.present?
  end
end
