require 'test_helper'

module Facebase
  class ShardsControllerTest < ActionController::TestCase
    setup do
      @shard = shards(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:shards)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create shard" do
      assert_difference('Shard.count') do
        post :create, shard: @shard.attributes
      end
  
      assert_redirected_to shard_path(assigns(:shard))
    end
  
    test "should show shard" do
      get :show, id: @shard
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @shard
      assert_response :success
    end
  
    test "should update shard" do
      put :update, id: @shard, shard: @shard.attributes
      assert_redirected_to shard_path(assigns(:shard))
    end
  
    test "should destroy shard" do
      assert_difference('Shard.count', -1) do
        delete :destroy, id: @shard
      end
  
      assert_redirected_to shards_path
    end
  end
end
