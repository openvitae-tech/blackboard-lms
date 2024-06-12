class UserPolicy
  attr_reader :user, :other_user

  def initialize(user, other_user)
    @user = user
    @other_user = other_user
  end
  def index?
    user.is_admin? || user.is_owner? || user.is_manager?
  end

  def show?
    other_user_is_user = (user == other_user)
    user_is_admin = user.is_admin? || user.is_owner? || user.is_manager?
    user_is_owner_or_manager_of_other_user = other_user.learning_partner_id == user.learning_partner_id && (user.is_owner? || user.is_manager?)
    other_user_is_user || user_is_admin || user_is_owner_or_manager_of_other_user
  end

  def create?
    user.is_admin?
  end

  def new?
    user.is_admin?
  end

  def update?
    (user == other_user) || user.is_admin? || user.is_owner? || user.is_manager?
  end

  def edit?
    (user == other_user) || user.is_admin? || user.is_owner? || user.is_manager?
  end

  def destroy?
    user != other_user && user.is_admin? || user.is_owner? || user.is_manager?
  end

  def invite_admin?
    user.is_admin?
  end

  def invite_member?
    user.is_admin? || user.is_owner? || user.is_manager?
  end

  def resend_invitation?
    other_user.confirmed_at.nil? && (user.is_admin? || user.is_owner? || user.is_manager?)
  end
end