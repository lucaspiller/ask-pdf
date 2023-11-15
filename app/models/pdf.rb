class Pdf < ApplicationRecord
  has_one_attached :original_file

  validates :original_file, content_type: ['application/pdf'], presence: true
end
