# frozen_string_literal: true

class AddSectionsToPdfs < ActiveRecord::Migration[7.1]
  def change
    add_column :pdfs, :sections, :text
  end
end
