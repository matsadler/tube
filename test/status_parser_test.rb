require "test/unit"

require File.expand_path("../../lib/tube/status", __FILE__)

class TestStatusParser < Test::Unit::TestCase
  def test_parse_updated
    document = Nokogiri::HTML("<h2>Service update at 18:26</h2>")
    element = document.at_css("h2")
    result = Tube::StatusParser.parse_updated(element)
    
    assert_equal(Time.parse("6:26pm"), result)
  end
  
  def test_parse_updated_with_anchor_in_element
    document = Nokogiri::HTML(%Q{<h2>Service update at 12:12 <a href="/later.html">View engineering works planned for later today</a></h2>})
    element = document.at_css("h2")
    result = Tube::StatusParser.parse_updated(element)
    
    assert_equal(Time.parse("12:12pm"), result)
  end
  
  def test_parse_line
    document = Nokogiri::HTML(%Q{<li class="ltn-line"><h3 class="central ltn-name">Central</h3><div class="status">Good service</div></li>})
    element = document.at_css("li")
    result = Tube::StatusParser.parse_line(element)
    
    assert_equal("Central", result[:name])
    assert_equal("central", result[:html_class])
    assert_equal("Good service", result[:status][:headline])
  end
  
  def test_parse_line_with_complex_name
    document = Nokogiri::HTML(%Q{<li class="ltn-line"><h3 class="waterlooandcity ltn-name">Waterloo &amp; City</h3><div class="status">Good service</div></li>})
    element = document.at_css("li")
    result = Tube::StatusParser.parse_line(element)
    
    assert_equal("Waterloo & City", result[:name])
    assert_equal("waterlooandcity", result[:html_class])
  end
  
  def test_parse_status
    document = Nokogiri::HTML(%Q{<div class="status">Good service</div>})
    element = document.at_css("div")
    result = Tube::StatusParser.parse_status(element)
    
    assert_equal("Good service", result[:headline])
  end
  
  def test_parse_status_with_problem
    document = Nokogiri::HTML(%Q{<div class="problem status">Part suspended</div>})
    element = document.at_css("div")
    result = Tube::StatusParser.parse_status(element)
    
    assert_equal(true, result[:problem])
  end
  
  def test_parse_status_with_header
    document = Nokogiri::HTML(%Q{<div class="status"><h4 class="ltn-title">Part suspended</h4></div>})
    element = document.at_css("div")
    result = Tube::StatusParser.parse_status(element)
    
    assert_equal("Part suspended", result[:headline])
  end
  
  def test_parse_status_with_message
    document = Nokogiri::HTML(%Q{<div class="problem status"><h4 class="ltn-title">Part closure</h4><div class="message"><p>engineering works, etc...</p></div></div>})
    element = document.at_css("div.status")
    result = Tube::StatusParser.parse_status(element)
    
    assert_equal("Part closure", result[:headline])
    assert_equal(true, result[:problem])
    assert_equal("engineering works, etc...", result[:message])
  end
  
  def test_parse_status_message
    document = Nokogiri::HTML(%Q{<div><p>engineering works, etc...</p></div>})
    elements = document.css("div p")
    result = Tube::StatusParser.parse_status_message(elements)
    
    assert_equal("engineering works, etc...", result)
  end
  
  def test_parse_status_message_with_multi_paragraph_message
    document = Nokogiri::HTML(%Q{<div><p>Rail replacement bus</p><p>Service A: details...</p></div>})
    elements = document.css("div p")
    result = Tube::StatusParser.parse_status_message(elements)
    
    assert_equal("Rail replacement bus\nService A: details...", result)
  end
  
  def test_parse_status_message_removes_anchor_from_message
    document = Nokogiri::HTML(%Q{<div><p>Closed Sunday.</p><p><a href="/projectsandschemes"><p>Click for further information.</p></a></p></div>})
    elements = document.css("div > p")
    result = Tube::StatusParser.parse_status_message(elements)
    
    assert_equal("Closed Sunday.", result)
  end
  
  def test_parse_station_group
    document = Nokogiri::HTML(%Q{<li class="ltn-closed"><h3>Closed stations</h3><ul>
    <li class="ltn-station" id="stop-1000013"><h4 class="ltn-name">Bank</h4><div class="message"><p>Closed due to excessive noise.</p></div></li>
    <li class="ltn-station" id="stop-10000xx"><h4 class="ltn-name">Holborn</h4><div class="message"><p>Closed due to fire investigation.</p></div></li></ul></li>})
    element = document.at_css("li.ltn-closed")
    result = Tube::StatusParser.parse_station_group(element)
    
    assert_equal("Closed stations", result[:name])
    assert_equal("Bank", result[:stations].first[:name])
    assert_equal("Holborn", result[:stations].last[:name])
  end
  
  def test_parse_station
    document = Nokogiri::HTML(%Q{<li class="ltn-station" id="stop-1000013"><h4 class="ltn-name">Bank</h4><div class="message"><p>Closed due to excessive noise.</p></div></li>})
    element = document.at_css("li")
    result = Tube::StatusParser.parse_station(element)
    
    assert_equal("Bank", result[:name])
    # This seriously happend once.
    assert_equal("Closed due to excessive noise.", result[:message])
  end
  
  def test_parse
    # the file used here is an approximation of the most important bits of the
    # Live travel news at http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html
    document = open("#{File.dirname(__FILE__)}/dummy.html").read
    result = Tube::StatusParser.parse(document)
    
    assert(result)
    assert_equal(Time.parse("12:12pm"), result[:updated])
    assert_equal(3, result[:lines].length)
    assert_equal("Central", result[:lines].first[:name])
    assert_equal("Closed Sunday.", result[:lines].last[:status][:message])
    assert_equal(2, result[:station_groups].length)
    assert_equal(2, result[:station_groups].first[:stations].length)
    assert_equal(1, result[:station_groups].last[:stations].length)
    assert_equal("Closed stations", result[:station_groups].first[:name])
    assert_equal("Elephant & Castle", result[:station_groups].last[:stations].first[:name])
    
    assert_equal({:updated=>Time.parse("12:12pm"), :station_groups=>[{:stations=>[{:message=>"Closed due to excessive noise.", :name=>"Bank"}, {:message=>"Closed due to fire investigation.\nGo to Chancery Lane or Tottenham Court Road instead.", :name=>"Holborn"}], :name=>"Closed stations"}, {:stations=>[{:message=>"Reduced lift service.", :name=>"Elephant & Castle"}], :name=>"Station maintenance"}], :lines=>[{:status=>{:problem=>false, :message=>nil, :headline=>"Good service"}, :html_class=>"central", :name=>"Central"}, {:status=>{:problem=>true, :message=>"Rail replacement bus\nService A: details...", :headline=>"Part closure"}, :html_class=>"district", :name=>"District"}, {:status=>{:problem=>true, :message=>"Closed Sunday.", :headline=>"Planned closure"}, :html_class=>"waterlooandcity", :name=>"Waterloo & City"}]}, result)
  end
end