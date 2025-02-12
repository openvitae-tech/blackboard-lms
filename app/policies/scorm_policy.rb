class ScormPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @scorm = record
  end

  def new?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def download?
    user.is_admin?
  end
end
