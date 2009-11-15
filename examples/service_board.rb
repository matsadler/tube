require 'rubygems'
require 'tube/status'
require 'terminal_color/ansi'

class String
  include Terminal::Color::ANSI
end

LINE_COLORS = {
  :bakerloo => [:bright_white, :yellow_bg],
  :central => [:white, :bright_red_bg],
  :circle => [:blue, :bright_yellow_bg],
  :district => [:bright_white, :green_bg],
  :hammersmithandcity => [:blue, :bright_magenta_bg],
  :jubilee => [:bright_white, :bright_black_bg],
  :metropolitan => [:bright_white, :magenta_bg],
  :northern => [:bright_white, :black_bg],
  :piccadilly => [:bright_white, :blue_bg],
  :victoria => [:bright_white, :bright_blue_bg],
  :waterlooandcity => [:blue, :bright_cyan_bg]
}
STATUS_COLOR = [:blue, :bright_white_bg]
PROBLEM_COLOR = STATUS_COLOR + [:negative]

status = Tube::Status.new

longest_name = status.lines.map {|l| l.name}.max.length
longest_status = status.lines.map {|l| l.status}.max.length
formatted_time = status.updated.strftime("%I:%M%p").downcase.sub(/^0/, "")

puts "  Live travel news".style(:bold), "  Last update: #{formatted_time}", ""
status.lines.each do |line|
  print "  "
  printf(" %-#{longest_name}s ".color(*LINE_COLORS[line.id]), line.name)
  status_color = if line.problem? then PROBLEM_COLOR else STATUS_COLOR end
  printf(" %-#{longest_status}s \n".color(*status_color), line.status)
end