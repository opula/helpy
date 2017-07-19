# == Schema Information
#
# Table name: forums
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :text
#  topics_count       :integer          default(0), not null
#  last_post_date     :datetime
#  last_post_id       :integer
#  private            :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  allow_topic_voting :boolean          default(FALSE)
#  allow_post_voting  :boolean          default(FALSE)
#  layout             :string           default("table")
#

require 'test_helper'

class ForumsControllerTest < ActionController::TestCase

  setup do
    set_default_settings
    sign_in users(:user)
  end

  test "a browsing user should get index" do
    get :index, locale: :en
    assert_response :success
    assert_equal(3, assigns(:forums).count)
  end

  test "a browsing user should not be able to see index of forums if forums are not enabled" do
    AppSettings['settings.forums'] = "0"
    assert_raises(ActionController::RoutingError) do
      get :index, locale: :en
    end
  end

end
