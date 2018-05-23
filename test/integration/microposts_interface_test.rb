require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:Shriya)
  end

  test "micropost interface" do
    log_in_as(@user)
    get home_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    assert_no_difference 'microposts.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end	
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture } }
    end
    assert_redirected_to home_path
    assert assigns(:micropost).picture?
    follow_redirect!
    assert_match content, response.body
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit different user (no delete links)
    get user_path(users(:Shraddha))
    assert_select 'a', text: 'delete', count: 0
  end    


  test "micropost sidebar count" do
    log_in_as(@user)
    get home_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # User with zero microposts
    other_user = users(:Shraddha)
    log_in_as(other_user)
    get home_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get home_path
    assert_match "#{other_user.microposts.count} micropost", response.body
  end
end
