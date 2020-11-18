require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'
require 'minitest/pride'

class ApiTest < Minitest::Test
  include RequestHelper

  def setup
    @search_term = "thomas"
  end

  def test_no_api_key
    request('GET', '?s=star', {}, ENV["OMDB_BASE_URL"])
    expected_response = "False"
    expected_error = "No API key provided."

    assert_equal expected_response, last_response.obj["Response"]
    assert_equal expected_error, last_response.obj["Error"]
  end

  def test_api_search_function_works_as_expected
    request("GET", "?s=#{@search_term}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]
    expected_keys = ["Title", "Year", "imdbID", "Type", "Poster"]

    results.each do |result|
      expected_keys.each {|expected_key| assert result.keys.include?(expected_key)}
      result.values.each {|value| assert_instance_of String, value}
      lowercase_title = result["Title"].downcase
      assert lowercase_title.include?(@search_term)

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
    request("GET", "?s=#{@search_term}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]

    results.each do |result|
      imdb_id = result["imdbID"]
      request("GET", "?i=#{imdb_id}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
      assert_equal "True", last_response.obj["Response"]
    end
  end

  def test_all_search_results_poster_links_work
    request("GET", "?s=#{@search_term}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    results = last_response.obj["Search"]

    results.each do |result|
      assert result["Poster"].include?(".com")
      request("GET", "", {}, result["Poster"])
      assert_equal 200, last_response.status
    end
  end

  def test_no_duplicate_search_results_in_first_5_pages
    page = 1
    five_page_results = []
    until page == 6
      request("GET", "?s=#{@search_term}&page=#{page}&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
      last_response.obj["Search"].each {|result| five_page_results << result["imdbID"]}
      page += 1
    end

    assert_equal 50, five_page_results.length
    assert_equal 50, five_page_results.uniq.length
  end

  def test_there_are_less_than_20_movie_titles_containing_the_word_squash
    request("GET", "?s=squash&type=movie&apikey=#{ENV["OMDB_API_KEY"]}", {}, ENV["OMDB_BASE_URL"])
    number_of_results = last_response.obj["totalResults"].to_i
    assert number_of_results < 20
  end
end
