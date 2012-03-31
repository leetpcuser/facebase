require 'test_helper'

module Facebase
  class EmailServiceProvidersControllerTest < ActionController::TestCase
    setup do
      @email_service_provider = email_service_providers(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:email_service_providers)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create email_service_provider" do
      assert_difference('EmailServiceProvider.count') do
        post :create, email_service_provider: @email_service_provider.attributes
      end
  
      assert_redirected_to email_service_provider_path(assigns(:email_service_provider))
    end
  
    test "should show email_service_provider" do
      get :show, id: @email_service_provider
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @email_service_provider
      assert_response :success
    end
  
    test "should update email_service_provider" do
      put :update, id: @email_service_provider, email_service_provider: @email_service_provider.attributes
      assert_redirected_to email_service_provider_path(assigns(:email_service_provider))
    end
  
    test "should destroy email_service_provider" do
      assert_difference('EmailServiceProvider.count', -1) do
        delete :destroy, id: @email_service_provider
      end
  
      assert_redirected_to email_service_providers_path
    end
  end
end
