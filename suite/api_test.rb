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
    results = last_response.obj["Search"]
    keys = ["Title", "Year", "imdbID", "Type", "Poster"]
    results.each do |result|
      assert_equal keys, result.keys
      assert result["Title"].include?("Thomas")
      assert_equal "movie", result["Type"]
      year = result["Year"].to_i
      assert (year > 1900 && year < 2030)
    end
  end

  def test_api_search_function_returns_imdb_accessible_results
    request("GET", "?s=tank&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]

    results.each do |result|
      imdb_id =  result["imdbID"]
      request("GET", "?i=#{imdb_id}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
      assert last_response.obj["Response"]
    end
  end

end
