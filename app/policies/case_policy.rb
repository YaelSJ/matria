class CasePolicy < ApplicationPolicy
  def show?
    return false unless user

    if user.representative?
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

  def assign?
    return false unless user

    user.representative? &&
      show? &&
      record.representative_id.nil?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      if user.representative?
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
