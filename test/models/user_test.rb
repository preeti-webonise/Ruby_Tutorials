require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    shriya = users(:Shriya)
    shraddha = users(:Shraddha)
    assert_not shriya.following?(shraddha)
    shriya.follow(shraddha)
    assert shriya.following?(shraddha)
    assert shraddha.followers.include?(shriya)
    shriya.unfollow(shraddha)
    assert_not shriya.following?(shraddha)
  end

  test "feed should have the right posts" do
    Shriya = users(:Shriya)
    Shraddha = users(:Shraddha)  
    Anuj = users(:Anuj)
    # Posts from followed user
    Anuj.microposts.each do |post_following|
      assert Shriya.feed.include?(post_following)
    end 
    # Posts from self
    Shriya.microposts.each do |post_self|
      assert Shriya.feed.include?(post_self)
    end
    # Posts from unfollowed user
    Shraddha.microposts.each do |post_unfollowed|
      assert_not Shriya.feed.include?(post_unfollowed)
    end
  end
end
