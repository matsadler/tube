require 'time'
require 'date'
require 'rubygems'
require 'nokogiri'

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
      lines = line_elements.map(&method(:parse_line))
      
      station_group_elements = service_board.css("ul#stations > li")
      station_groups = station_group_elements.map(&method(:parse_station_group))
      
      {:updated => updated, :lines => lines, :station_groups => station_groups}
    end
    
    def parse_updated(updated_element)
      time_text = updated_element.content.match(/\d?\d:\d\d/)[0]
      time_zone = is_bst? ? "+0100" : "+0000"
      
      Time.parse("#{time_text} #{time_zone}")
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
        if message.children
          message.children.select {|child| child.text?}.join(" ")
        end
      end.compact
      text_messages.reject! {|m| m.empty?}
      
      text_messages.map {|m| m.gsub(/\s+/, " ").strip}.join("\n")
    end
    
    private
    
    # :call-seq: is_bst? -> bool
    # 
    # Is British Summer Time currently in effect.
    # 
    def is_bst?
      bst_start = last_sunday_of_month("march")
      bst_end = last_sunday_of_month("october")
      
      one_hour = 3600
      
      bst_start = Time.gm(bst_start.year, bst_start.month, bst_start.day)
      bst_start += one_hour
      
      bst_end = Time.gm(bst_end.year, bst_end.month, bst_end.day)
      bst_end += one_hour
      
      bst = (bst_start..bst_end)
      if bst.respond_to?(:cover?)
        bst.cover?(Time.now.getgm)
      else
        bst.include?(Time.now.getgm)
      end
    end
    
    # :call-seq: last_sunday_of_month(month_name) -> date
    # 
    def last_sunday_of_month(month)
      start_of_next_month = Date.parse(next_month_name(month))
      
      week_day = start_of_next_month.wday
      
      distance_from_sunday = week_day == 0 ? 7 : week_day
      start_of_next_month - distance_from_sunday
    end
    
    # :call-seq: next_month_name(month_name) -> string
    # 
    def next_month_name(month)
      index = Date::MONTHNAMES.index(month.capitalize)
      index ||= ABBR_MONTHNAMES.index(month.capitalize)
      
      index += 1
      
      if index >= 12
        index = 1
      end
      
      Date::MONTHNAMES[index]
    end
    
  end
end