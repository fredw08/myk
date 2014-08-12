class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  structure do
    login_id               'sysadmin'
    email                  'a@bc.com'
    encrypted_password     :string

    # Recoverable
    reset_password_token   :string
    reset_password_sent_at Time.now

    # Rememberable
    remember_created_at    Time.now

    # Trackable
    sign_in_count          0
    current_sign_in_at     Time.now
    last_sign_in_at        Time.now
    current_sign_in_ip     '127.0.0.1'
    last_sign_in_ip        '127.0.0.1'

    # Lockable
    # failed_attempts        0
    # unlock_token           :string
    # locked_at              Time.now

    # confirmable
    # confirmation_token     :string
    # confirmed_at           Time.now
    # confirmation_sent_at   Time.now
    # unconfirmed_email      :string

    timestamps
  end
end
