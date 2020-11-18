require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'
require 'minitest/pride'

class ApiTest < Minitest::Test
  include RequestHelper

  def setup
  end

  def test_no_api_key
    request('GET', '?s=star', {}, ENV["OMDB_BASE_URL"])
    expected_response = "False"
    expected_error = "No API key provided."

    # TODO: Task 2 - add the assertion
    assert_equal expected_response, last_response.obj["Response"]
    assert_equal expected_error, last_response.obj["Error"]
  end

  def test_api_search_function_works_as_expected
    request("GET", "?s=thomas&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    require "pry"; binding.pry
  end

end
