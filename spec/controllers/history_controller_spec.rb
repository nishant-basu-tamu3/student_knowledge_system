# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::HistoryController, type: :controller do
  before do
    @user = User.create(email: 'student@gmail.com', confirmed_at: Time.now)
    allow(controller).to receive(:current_user).and_return(@user)
    @course1 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                             semester: 'Fall 2022')
    @course2 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                             semester: 'Spring 2023')
    @course3 = Course.create(course_name: 'CSCE 412', teacher: 'student@gmail.com', section: '501',
                             semester: 'Spring 2023')
  end

  describe 'GET #show' do
    context 'when course exists' do
      before do
        get :show, params: { course_name: @course1.course_name, teacher: @user.email }
      end

      # it "returns http success" do
      #   expect(response).to have_http_status(:success)
      # end

      #     it "assigns @course_records" do
      #       expect(assigns(:course_records)).not_to be_nil
      #     end
    end

    context 'when course does not exist' do
      before do
        get :show, params: { id: 0 }
      end

      it 'redirects to courses url' do
        expect(response).to redirect_to(courses_url)
      end

      it 'sets flash notice' do
        expect(flash[:notice]).to eq('Given course not found.')
      end
    end
  end

  # context "when user is not authenticated" do
  #   before do
  #     get :show, params: { id: course.id }
  #   end

  #   it "redirects to sign in page" do
  #     expect(response).to redirect_to(new_user_session_url)
  #   end
  # end
end
