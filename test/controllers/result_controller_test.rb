require 'test_helper'

class ResultControllerTest < ActionController::TestCase

  def setup

    # Build PG search
    PgSearch::Multisearch.rebuild(Doc)
    PgSearch::Multisearch.rebuild(Topic)
    set_default_settings
    sign_in users(:user)
  end

  test "a browsing user searching for a doc should return a result" do

    get(:index, { q: "article1 text", locale: :en })
    assert_not_nil assigns(:results)
    assert_equal(2, assigns(:results).total_count)
    assert_response :success
  end

  test "a browsing user searching for something not in search should not return a result" do
    get(:index, { q: "somethingnotinsearch", locale: :en })
    assert_not_nil assigns(:results)
    assert_equal(0, assigns(:results).total_count)
    assert_response :success
  end

  test "a browsing user searching for a topic should return a result" do
    get(:index, { q: "This is a public post", locale: :en })
    assert_not_nil assigns(:results)
    assert_operator assigns(:results).total_count, :>=, 1, "Did not find at least one result"
    assert_select "span.result-body", { text: "This is a public post, should be searchable" }
    assert_response :success
  end

  test "a browsing user searching for a private topic should not return a result" do
    get(:index, { q: "This is a private post", locale: :en })
    assert_not_nil assigns(:results)
    assert_equal(0, assigns(:results).total_count, "Found a result when searching for a private topic")
    assert_response :success
  end

  test "a browsing user adding a public topic should add it to search" do

    @topic = Topic.create(forum_id: 3, user_id: 1, name: "My new post")
    @post = @topic.posts.create(user_id: 1, body: "This is something amazing", kind: "first")

    # have to manually rebuild search
    PgSearch::Multisearch.rebuild(Topic)

    assert @topic.public?, "Topic should be public"
    assert Topic.last.post_cache == " This is something amazing"
    get(:index, { q: "This is something amazing", locale: :en })
    assert_not_nil assigns(:results)
    assert_equal(1, assigns(:results).total_count, "Did not find results for the search")
    assert_select "span.result-body", { text: "This is something amazing" }
    assert_response :success

  end

  test "a browsing user adding a private topic should NOT add it to search" do

    @topic = Topic.create(forum_id: 1, user_id: 1, name: "My new private post", private: true)
    @post = Post.create(topic_id: @topic.id, user_id: 1, body: "This is something private", kind: "first")

    # have to manually rebuild search
    PgSearch::Multisearch.rebuild(Topic)

    get(:index, { q: "This is something private", locale: :en })
    assert_equal(0, assigns(:results).total_count, "Found results for the search when shouldn't have")
    assert_response :success

  end

  test "a browing user should be able to search and find a newly created article" do
    I18n.locale = :en
    assert_difference "Doc.count", 1 do
      Doc.create(category_id: 1, title: "some title", body: "some body text", locale: :en)
    end

    get(:index, { q: "some body text", locale: :en })
    assert_not_nil assigns(:results)
    assert_equal(1, assigns(:results).total_count, "Did not find results for the search for a new created Doc")
    assert_response :success
  end

  test "a browing user should not be able to find an unpublished article" do
    I18n.locale = :en
    Doc.create(category_id: 1, title: "some title", body: "some body text", locale: :en, active: false)
    get(:index, { q: "some body text", locale: :en })
    assert_equal(0, assigns(:results).total_count, "Found results for an inactive doc")
    assert_response :success
  end

  test "a browing user shoud not see HTML code in the search results" do
    # Create new doc with html, so we can verify the html is stripped in the search results
    Doc.create(user_id: 1, category_id: 1, title: "new title", body: "<div><b>new</b> body text</div>", locale: :en)

    get(:index, { q: "new body text", locale: :en })
    assert_not_nil assigns(:results)
    assert_select "span.result-body", { text: "new body text" }
    assert_response :success

  end


end
