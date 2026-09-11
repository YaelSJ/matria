class CasePolicy < ApplicationPolicy
  def show?
    return false unless user

    if user.admin?
      true
    elsif user.representative?
      user.state.present? && record.user.state == user.state
    elsif user.user?
      record.user_id == user.id
    else
      false
    end
  end

  def update?
    user&.user? && record.user_id == user.id && record.editable_by_user?
  end

  def decide?
    user&.admin? || (user&.representative? && record.representative_id == user.id && record.in_review?)
  end

  def start_review?
    user&.admin? || (user&.representative? && record.representative_id == user.id && record.pending_review?)
  end

  def assign?
    user&.admin? || (user&.representative? && show? && record.representative_id.nil? && record.pending_review?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all
      elsif user.representative?
        return scope.none if user.state.blank?

        scope.joins(:user).where(users: { state: user.state })
      elsif user.user?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
