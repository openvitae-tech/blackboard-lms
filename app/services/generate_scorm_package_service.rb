class GenerateScormPackageService
  include Singleton

  def generate(course)
    course_object = ScormAdaptor.new(course).process
    ScormEngine::Package::Generate.new(course_object).process
  end
end
