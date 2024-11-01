# frozen_string_literal: true

Rails.application.routes.draw do
  post 'upload/index', to: 'upload#parse'
  get 'upload/index', to: 'upload#index'

  resources :quizzes, only: %i[index show new create]
  get 'home/index'
  get 'upload', to: 'upload#index'

  post 'quizzes/:id', to: 'quizzes#show'

  # devise_for :users

  resources :courses
  namespace :courses do
    resources :history, only: [:show]
  end

  resources :student_courses

  resources :students do
    member do
      get :notes # Route to fetch the notes
      post :update_notes # Route to update the notes
    end
  end

  get 'students/:id/quiz', to: 'students#quiz', as: 'quiz_students'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  # root 'home#index'

  passwordless_for :users
  resources :users
  root to: 'static#index'

  get '/home', to: 'home#index'
  # devise_for :users, controllers: {
  #   registrations: 'users/registrations',
  #   sessions: 'users/sessions',
  #   omniauth_callbacks: 'users/omniauth_callbacks'
  # }
  # devise_scope :user do
  #   authenticated :user do
  #       root 'home#index', as: :authenticated_root
  #   end

  #   unauthenticated do
  #       root 'devise/sessions#new', as: :unauthenticated_root
  #   end
  # end

  get '/auth/google_oauth2/callback', to: 'sessions#create'
  get 'users/auth/google_oauth2/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
end
