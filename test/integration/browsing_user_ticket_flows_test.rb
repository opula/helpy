require 'integration_test_helper'

include Warden::Test::Helpers

class BrowsingUserTicketFlowsTest < ActionDispatch::IntegrationTest

  def setup
    Warden.test_mode!
    sign_in("editor@test.com")
    set_default_settings
  end

  def teardown
    Capybara.reset_sessions!
    Warden.test_reset!
  end

  test "a browsing user who is registered should be able to create a public ticket via the web interface when recaptcha enable" do

    # make sure recaptcha is enabled
    AppSettings['settings.recaptcha_enabled'] = "1"
    AppSettings['settings.recaptcha_site_key'] = "some-key"
    AppSettings['settings.recaptcha_api_key'] = "some-key"

    # create new private ticket
    visit '/en/topics/new/'

    assert_difference('Topic.count',1) do
      fill_in('topic[name]', with: 'I got problems')
      fill_in('topic[posts_attributes][0][body]', with: 'Please help me!!')
      click_on('Create Ticket', disabled: true)
    end
    assert current_path == "/en/topics/#{Topic.last.id}-i-got-problems/posts"

  end

  test "a browsing user who is registered should be able to create a private ticket via the web interface" do
    # create new private ticket
    visit '/en/topics/new/'

    # A new user should not be created
    assert_difference('User.count', 0) do
      assert_difference('Topic.count',1) do
        fill_in('topic[name]', with: 'I got problems')
        fill_in('topic[posts_attributes][0][body]', with: 'Please help me!!')
        click_on('Create Ticket', disabled: true)
      end
    end

  end

  test "a browsing user should be prompted to login from a public forum page" do

    forums = [  "/en/community/3-public-forum/topics",
                "/en/community/4-public-idea-board/topics",
                "/en/community/5-public-q-a/topics" ]

    forums.each do |forum|
      visit forum
      click_on "Start a Discussion"
      assert find("div#login-modal").visible?
    end
  end

  test "a browsing user should be prompted to login when clicking reply from a public discussion view" do

    topics = [ "/en/topics/5-new-public-topic/posts",
               "/en/topics/8-new-idea/posts",
               "/en/topics/7-new-question/posts" ]

    topics.each do |topic|
      visit topic
      click_on "Reply"
      assert find("div#login-modal").visible?
    end
  end

  test "a browsing user should be able to create a private ticket via widget" do
    visit '/widget'

    assert_difference('Post.count', 1) do
      fill_in('topic[name]', with: 'I got problems')
      fill_in('topic[posts_attributes][0][body]', with: 'Please help me!!')
      click_on('Create Ticket', disabled: true)
    end

  end
end
