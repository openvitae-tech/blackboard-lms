class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end
  def index?
    user.is_admin? || user.is_owner? || user.is_manager?
  end

  def show?
    (user == record) || user.is_admin?
  end

  def create?
    user.is_admin? || user.is_owner? || user.is_manager?
  end

  def new?
    user.is_admin? || user.is_owner? || user.is_manager?
  end

  def update?
    (user == record) || user.is_admin? || user.is_owner? || user.is_manager?
  end

  def edit?
    (user == record) || user.is_admin? || user.is_owner? || user.is_manager?
  end

  def destroy?
    user != record && user.is_admin? || user.is_owner? || user.is_manager?
  end

end