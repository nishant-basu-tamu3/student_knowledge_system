# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.credentials[:GOOGLE_CLIENT_ID], Rails.application.credentials[:GOOGLE_CLIENT_SECRET], {
    provider_ignores_state: false,
    prompt: 'select_account',
    image_aspect_ratio: 'square',
    image_size: 200,
    scope: 'email,profile,openid'
  }
end
OmniAuth.config.allowed_request_methods = %i[get post]

# Additional configuration for testing environment
if Rails.env.test?
  OmniAuth.config.test_mode = true

  # Mock authentication data in tests
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                       provider: 'google_oauth2',
                                                                       uid: '123456',
                                                                       info: {
                                                                         email: 'testuser@example.com',
                                                                         name: 'Test User',
                                                                         image: 'https://via.placeholder.com/200'
                                                                       },
                                                                       credentials: {
                                                                         token: 'mock_token',
                                                                         refresh_token: 'mock_refresh_token',
                                                                         expires_at: Time.now + 1.week
                                                                       }
                                                                     })
end
