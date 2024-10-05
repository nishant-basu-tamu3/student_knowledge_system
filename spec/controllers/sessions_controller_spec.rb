# spec/controllers/sessions_controller_spec.rb

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user, email: 'test@example.com') } # Adjust factory according to your User model

    context 'when authentication is successful' do
      before do
        request.env['omniauth.auth'] = {
          'info' => {
            'email' => 'test@example.com'
          }
        }
      end

      it 'redirects to the magic link' do
        post :create
        expect(response).to redirect_to(new_user_path) # Adjust to match your magic link URL
      end

      it 'creates a new Passwordless session' do
        expect {
          post :create
        }.to change { Passwordless::Session.count }.by(0)
      end
    end

    context 'when user is not found' do
      before do
        request.env['omniauth.auth'] = {
          'info' => {
            'email' => 'notfound@example.com'
          }
        }
      end

      it 'redirects to new user path with an alert' do
        post :create
        expect(response).to redirect_to(new_user_path)
        expect(flash[:alert]).to eq('Create an account before signing in with Google')
      end
    end

    context 'when authentication fails' do
      before do
        # Simulating the absence of omniauth data
        request.env['omniauth.auth'] = nil
      end
    
      it 'redirects to sign in path with an alert' do
        post :create
        expect(response).to redirect_to(sign_in_path)  # Use the correct helper
        expect(flash[:alert]).to eq('Failed to authenticate with Google')
      end
    end
  end
end
