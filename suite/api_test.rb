require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'
require 'minitest/pride'

class ApiTest < Minitest::Test
  include RequestHelper

  def test_no_api_key
    request('GET', '?s=star', {}, 'http://www.omdbapi.com/')
    puts last_response.obj
    expected_response = "False"
    expected_error = "No API key provided."
    
    # TODO: Task 2 - add the assertion
    assert_equal expected_response, last_response.obj["Response"]
    assert_equal expected_error, last_response.obj["Error"]
  end

end
