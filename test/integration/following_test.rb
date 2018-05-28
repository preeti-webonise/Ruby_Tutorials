require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:Shriya)
    @other = users(:Shraddha)
    @testUser1 = users(:testUser1)
    @testUser2 = users(:testUser2)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user the standard way" do
    log_in_as(@testUser1)
    assert_difference '@testUser1.following.count', 1 do
      post relationships_path, params: { followed_id: @testUser2.id }
    end
  end

  test "should follow a user with Ajax" do
    log_in_as(@testUser1)
    assert_difference '@testUser1.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @testUser2.id }
    end
  end

  test "should unfollow a user the standard way" do
    log_in_as(@testUser1)
    @testUser1.follow(@testUser2)
    relationship = @testUser1.active_relationships.find_by(followed_id: @testUser2.id)
    assert_difference '@testUser1.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    log_in_as(@testUser1)
    @testUser1.follow(@testUser2)
    relationship = @testUser1.active_relationships.find_by(followed_id: @testUser2.id)
    assert_difference '@testUser1.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  test "feed on Home page" do
    get home_path
    @user.feed.paginate(page: 1).each do |micropost|
      assert_match CGI.escapeHTML("sorry"), "sorry"
    end
  end

end	