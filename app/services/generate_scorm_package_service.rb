class GenerateScormPackageService
  include Singleton

  def generate(course, partner_id)
    course_object = ScormAdapter.new(course).process
    scorm_token = ScormToken.find_or_create_by!(learning_partner_id: partner_id)
    ScormPackage::Packaging::Generate.new(course_object, scorm_token.token).process
  end
end
