# frozen_string_literal: true

# Session Controller class
class SessionsController < ApplicationController
  def create
    omniauth_data = request.env['omniauth.auth']

    if omniauth_data && omniauth_data['info'] && omniauth_data['info']['email'] # Check for presence
      email = omniauth_data['info']['email']

      user = User.find_by(email:)

      if user.nil?
        redirect_to new_user_path, alert: 'Create an account before signing in with Google'
      else
        session = Passwordless::Session.new({
                                              authenticatable: user,
                                              user_agent: 'Command Line',
                                              remote_addr: 'unknown'
                                            })
        session.save!
        @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)

        redirect_to @magic_link
      end
    else
      redirect_to users.sign_in_path, alert: 'Failed to authenticate with Google'
    end
  end
end
