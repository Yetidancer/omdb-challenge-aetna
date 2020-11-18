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
      keys.each {|key| assert result.keys.include?(key)}
      result.values.each {|value| assert_instance_of String, value}
      assert result["Title"].include?("Thomas")

      yr_length = (result["Year"].length)
      if yr_length < 6
        year = result["Year"][0...4].to_i
        assert (year > 1900 && year < 2030)
      else
        start_year = result["Year"][0...4].to_i
        end_year = result["Year"][-4...yr_length].to_i
        assert (start_year > 1900 && start_year < 2030)
        assert (end_year > 1900 && end_year < 2030)
      end
    end
  end

  def test_api_search_function_returns_imdb_accessible_results
    request("GET", "?s=thomas&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]

    results.each do |result|
      imdb_id =  result["imdbID"]
      request("GET", "?i=#{imdb_id}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
      assert last_response.obj["Response"]
    end
  end

  def test_all_search_results_poster_links_work
    request("GET", "?s=thomas&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]

    results.each do |result|
      assert_equal "http", result["Poster"][0...4]
      request("GET", "", {}, result["Poster"])
      assert_equal 200, last_response.status
    end
  end

  def test_no_duplicate_search_results_in_first_5_pages
    request("GET", "?s=thomas&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]
    page = 1
    five_page_results = []
    until page == 6
      request("GET", "?s=friends&page=#{page}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
      page += 1
      five_page_results << last_response.obj["Search"]
    end
    five_page_results = five_page_results.flatten

    assert_equal 50, five_page_results.length
    assert_equal 50, five_page_results.uniq.length
  end

  def test_there_are_less_than_30_movie_titles_containing_the_word_squash
    request("GET", "?s=squash&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    number_of_results = last_response.obj["totalResults"].to_i

    assert number_of_results < 30
  end
end
