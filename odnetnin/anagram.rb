begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  gem 'json', require: true
  gem 'minitest'
  gem 'pry-byebug', require: true
end

require "minitest/autorun"
require 'benchmark'
require 'net/http'

def sort_anagram_initial_key_is_string(dictionary)
  result = []
  anagramSet = Hash.new{|h, k| h[k] = []}
  dictionary.each do |word|
    anagramSet[word.bytes.sort] << word
  end
  anagramSet.each do |key, value|
    result << value if value.count > 1
  end
  result
end

def sort_anagram_initial_key_is_number(dictionary)
  result = []
  anagramSet = Hash.new{|h, k| h[k] = []}

  dictionary.each do |word|
    anagramSet[word.bytes.sort.hash] << word
  end
  anagramSet.each do |key, value|
    result << value if value.count > 1
  end
  result
end

def sort_anagram_optimized(dictionary)
  result = []
  sort_by_letter_count = (0..26).map { Hash.new{|h, k| h[k] = []} }
  dictionary.each do |word|
    sort_by_letter_count[word.length][word.bytes.sort.hash] << word
  end
  sort_by_letter_count.each do |hash_elements|
    hash_elements && hash_elements.each do |key, value|
      result << value if value.count > 1
    end
  end
  result
end

class AnagramTest < Minitest::Test

  URI         = URI('http://www.pallier.org/extra/liste.de.mots.francais.frgut.txt')
  DICTIONARY  = Net::HTTP.get(URI).force_encoding('ISO-8859-1').encode('UTF-8').split("\n").map(&:chomp)


  [:sort_anagram_initial_key_is_string, :sort_anagram_initial_key_is_number, :sort_anagram_optimized].each do |method|

    define_method("test_valid_#{method}") do
      dictionary = %w(Marion manoir minora normai Romain ironique onirique argent gérant grenat garent ragent Tanger gréant régnât ganter crane écran nacre carne rance ancre couille luciole aimer maire Marie ramie aube beau baignade badinage chie chine niche imaginer migraine Parisien aspirine police picole soigneur guérison cuvé vécu chicane caniche rial lari meuf fume).shuffle!
      expected_output = [["baignade", "badinage"],
                       ["beau", "aube"],
                       ["caniche", "chicane"],
                       ["rance", "carne", "crane", "ancre", "nacre"],
                       ["migraine", "imaginer"],
                       ["ganter", "argent", "garent", "ragent", "grenat"],
                       ["aimer", "ramie", "maire"],
                       ["gréant", "gérant"],
                       ["rial", "lari"],
                       ["normai", "minora", "manoir"],
                       ["niche", "chine"],
                       ["luciole", "couille"],
                       ["police", "picole"],
                       ["vécu", "cuvé"],
                       ["fume", "meuf"],
                       ["onirique", "ironique"]].map(&:sort).sort_by { |a| a.to_s }
      assert_equal send(method, dictionary).map(&:sort).sort_by { |a| a.to_s }, expected_output
    end
  end

  def test_perf_benchmark
    benchmark_result = Benchmark.bm do |x|
      x.report('sort_anagram_initial_key_is_string') { sort_anagram_initial_key_is_string(DICTIONARY) }
      x.report('sort_anagram_initial_key_is_number') { sort_anagram_initial_key_is_number(DICTIONARY) }
      x.report('sort_anagram_optimized') { sort_anagram_optimized(DICTIONARY) }
    end
    assert_equal benchmark_result[0].total > benchmark_result[1].total, true
    assert_equal benchmark_result[1].total > benchmark_result[2].total, true
    assert_equal benchmark_result[2].total < 2.5, true
  end
end
