require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:Shriya)
    user.activationToken = User.newToken
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@sampleuserpostsapp.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activationToken,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end
