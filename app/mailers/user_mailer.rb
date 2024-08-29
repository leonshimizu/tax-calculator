# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def approval_notification(user)
    @user = user
    mail(to: @user.email, subject: 'Your account has been approved')
  end

  def rejection_notification(user)
    @user = user
    mail(to: @user.email, subject: 'Your account has been rejected')
  end
end
