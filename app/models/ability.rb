class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new

    can :manage, :all if @user.login_id = 'sysadmin'
  end
end
