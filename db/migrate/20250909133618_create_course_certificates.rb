class CreateCourseCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :course_certificates do |t|
      t.datetime :issued_at, null: false
      t.string :file_hash, null: false
      t.string :certificate_uuid, null: false

      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.timestamps
    end

    add_index :course_certificates, :certificate_uuid, unique: true
    add_index :course_certificates, :file_hash, unique: true
    add_index :course_certificates, [:user_id, :course_id], unique: true
  end
end
