class CreatePdfs < ActiveRecord::Migration[7.1]
  def change
    create_table :pdfs do |t|
      t.string :status, null: false, default: 'pending'
      t.timestamps
    end
  end
end
