require 'time'
require 'date'
require 'rubygems'
require 'hpricot'

module Tube # :nodoc:
  module StatusParser
    extend self
    
    def parse( html_doc )
      doc = Hpricot( html_doc )
      
      service_board = doc.at( "#service-board" )
      
      updated_element = service_board.previous_sibling.children.first
      updated = parse_updated( updated_element )
      
      lines = service_board.search( "dl#lines dt" ).map do |line_element|
        parse_line( line_element )
      end
      
      station_group_elements = service_board.search( "dl#stations dt" )
      station_groups = station_group_elements.map do |station_group_element|
        parse_station_group( station_group_element )
      end
      
      {:updated => updated, :lines => lines, :station_groups => station_groups}
    end
    
    def parse_updated( updated_element )
      time_text = updated_element.inner_text.match( /(\d?\d:\d\d(a|p)m)/ )[0]
      time_zone = if is_bst? then "+0100" else "+0000" end
      
      Time.parse( "#{time_text} #{time_zone}" )
    end
    
    def parse_line( line_element )
      name = line_element.inner_text.strip
      html_class = line_element.attributes["class"]
      status = parse_status( line_element.next_sibling )
      
      {:name => name, :html_class => html_class, :status => status}
    end
    
    def parse_status( status_element )
      header = status_element.at( "h3" )
      
      if header
        headline = header.inner_text.strip
        message = parse_status_message( status_element.search( "div.message p" ) )
      else
        headline = status_element.inner_text.strip
      end
      problem = status_element.attributes["class"] == "problem"
      
      {:headline => headline, :problem => problem, :message => message}
    end
    
    def parse_station_group( station_group_element )
      name = station_group_element.inner_text.strip
      stations = []
      
      station_element = station_group_element
      while station_element = station_element.next_sibling
        if station_element.to_html =~ /^<dd/
          stations.push( parse_station( station_element ) )
        elsif station_element.to_html =~ /^<dt/
          break
        end
      end
      
      {:name => name, :stations => stations}
    end
    
    def parse_station( station_element )
      name = station_element.at( "h3" ).inner_text.strip
      message = parse_status_message( station_element.search( "div.message p" ) )
      
      {:name => name, :message => message}
    end
    
    def parse_status_message( messages )
      text_messages = messages.map do |message|
        if message.children
          message.children.select {|child| child.text?}.join( " " )
        end
      end.compact
      text_messages.reject! {|m| m.empty?}
      
      text_messages.map {|m| m.gsub( /\s+/, " " ).strip}.join( "\n" )
    end
    
    private
    
    # :call-seq: is_bst? -> bool
    # 
    # Is British Summer Time currently in effect.
    # 
    def is_bst?
      bst_start = last_sunday_of_month( "march" )
      bst_end = last_sunday_of_month( "october" )
      
      one_hour = 3600
      bst_start = Time.gm( bst_start.year, bst_start.month ) + one_hour
      bst_end = Time.gm( bst_end.year, bst_end.month ) + one_hour
      
      (bst_start..bst_end).include?( Time.now.getgm )
    end
    
    # :call-seq: last_sunday_of_month(month_name) -> date
    # 
    def last_sunday_of_month( month )
      start_of_next_month = Date.parse( next_month_name( month ) )
      
      week_day = start_of_next_month.wday
      
      distance_from_sunday = if week_day == 0 then 7 else week_day end
      start_of_next_month - distance_from_sunday
    end
    
    # :call-seq: next_month_name(month_name) -> string
    # 
    def next_month_name( month )
      index = Date::MONTHNAMES.index( month.capitalize )
      index ||= ABBR_MONTHNAMES.index( month.capitalize )
      
      index += 1
      
      if index >= 12
        index = 1
      end
      
      Date::MONTHNAMES[index]
    end
    
  end
end