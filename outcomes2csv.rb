#!/usr/bin/env ruby

require 'bundler/setup'

require 'nokogiri'
require 'open-uri'
require 'csv'

search_results_url = 'https://www.digitalmarketplace.service.gov.uk/digital-outcomes-and-specialists/opportunities?q=&statusOpenClosed=open&location=london&location=south+east+england&location=offsite'

doc = Nokogiri::HTML(open(search_results_url))

outcomes = doc.css('.search-result')

data = outcomes.map do |outcome|
  link = outcome.css('.search-result-title a[href]')
  title = link.text.strip
  url = link.attr('href').text

  client, location, opportunity, published_at, closes_at = outcome.css('li.search-result-metadata-item').map {|n| n.text.strip}

  published_at = Date.parse(published_at.gsub('Published: ', ''))
  closes_at = Date.parse(closes_at.gsub('Closing: ', ''))

  {
    title: title,
    url: "https://www.digitalmarketplace.service.gov.uk/" + url,
    client: client,
    location: location,
    published_at: published_at,
    closes_at: closes_at
  }
end

csv = CSV.generate(col_sep: "\t") do |csv|
  csv << data.first.keys

  data.sort {|x,y| x[:url] <=> y[:url]}.each do |d|
    csv << d.values
  end
end

puts csv
