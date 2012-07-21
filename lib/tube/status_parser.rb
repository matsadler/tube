require "time"
require "rubygems"
require "nokogiri"

module Tube # :nodoc:
  module StatusParser # :nodoc:
    extend self
    
    def parse(html_doc)
      html_doc.gsub!(/&nbsp;/, " ")
      doc = Nokogiri::HTML(html_doc)
      
      updated_element = doc.at_css("div.hd-row > h2")
      updated = parse_updated(updated_element)
      
      service_board = doc.at_css("#service-board")
      
      line_elements = service_board.css("ul#lines > li.ltn-line")
      lines = line_elements.map {|e| parse_line(e)}
      
      station_group_elements = service_board.css("ul#stations > li")
      station_groups = station_group_elements.map {|e| parse_station_group(e)}
      
      {:updated => updated, :lines => lines, :station_groups => station_groups}
    end
    
    def parse_updated(updated_element, now=Time.now)
      time_text = updated_element.content.match(/(\d?\d):(\d\d)/)
      hours = time_text[1].to_i
      minutes = time_text[2].to_i
      time_zone = british_summer_time?(now) ? "+01:00" : "+00:00"
      
      begin
        Time.new(now.year, now.month, now.day, hours, minutes, 0, time_zone)
      rescue ArgumentError
        # fallback for ruby < 1.9.2
        Time.parse("#{hours}:#{minutes} #{time_zone}")
      end
    end
    
    def parse_line(line_element)
      name_element = line_element.at_css("h3.ltn-name")
      name = name_element.content
      html_class = name_element["class"].split(" ").first
      status = parse_status(line_element.at_css("div.status"))
      
      {:name => name, :html_class => html_class, :status => status}
    end
    
    def parse_status(status_element)
      header = status_element.at_css("h4.ltn-title")
      
      if header
        headline = header.content.strip
        message = parse_status_message(status_element.css("div.message > p"))
      else
        headline = status_element.content.strip
      end
      problem = status_element["class"].split(" ").include?("problem")
      
      {:headline => headline, :problem => problem, :message => message}
    end
    
    def parse_station_group(station_group_element)
      name = station_group_element.at_css("h3").content
      
      station_elements = station_group_element.css("ul > li.ltn-station")
      
      stations = station_elements.map do |station_element|
        parse_station(station_element)
      end
      
      {:name => name, :stations => stations}
    end
    
    def parse_station(station_element)
      name = station_element.at_css("h4.ltn-name").content.strip
      message = parse_status_message(station_element.css("div.message > p"))
      
      {:name => name, :message => message}
    end
    
    def parse_status_message(messages)
      text_messages = messages.map do |message|
        children = message.children
        children.select {|child| child.text?}.join(" ") if children
      end.compact
      text_messages.reject! {|m| m.empty?}
      
      text_messages.map {|m| m.gsub(/\s+/, " ").strip}.join("\n")
    end
    
    private
    
    # :call-seq: british_summer_time? -> bool
    # 
    # Is British Summer Time currently in effect.
    # 
    def british_summer_time?(time)
      time = time.getgm
      bst_start = last_sunday_1_am(time.year, 3) # march
      bst_end = last_sunday_1_am(time.year, 10) # october
      time >= bst_start && time < bst_end
    end
    
    ONE_DAY = 86400 # :nodoc:
    
    # :call-seq: last_sunday_1_am(year, month) -> time
    # 
    def last_sunday_1_am(year, month)
      start_of_next_month = Time.gm(year, month % 12 + 1, 1, 1)
      end_of_month = start_of_next_month - ONE_DAY
      end_of_month - end_of_month.wday * ONE_DAY
    end
    
  end
end