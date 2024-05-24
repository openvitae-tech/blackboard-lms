module Helpers

  def big_image_file
    Rack::Test::UploadedFile.new("#{Rails.root}/spec/files/more_than_1_mb.jpg")
  end

  def image_file(name="#{Rails.root}/spec/files/less_than_1_mb.jpg")
    Rack::Test::UploadedFile.new(name)
  end

  def pdf_file(name="#{Rails.root}/spec/files/sample.pdf")
    Rack::Test::UploadedFile.new(name)
  end
end