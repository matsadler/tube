require "net/http"
require "json"

module Tube
  class TFLClient

    attr_reader :app_id, :app_key, :host, :port

    def initialize(app_id, app_key, host="api.tfl.gov.uk", port=80)
      @app_id = app_id
      @app_key = app_key
      @host = host
      @port = port
    end

    def self.def_request(name, method, path)
      define_method(name) do |params, body=nil, headers=nil|
        request(method, path, params, body, headers)
      end
    end
    private_class_method :def_request

    def_request :line_mode_status, :get, "/Line/Mode/{modes}/Status"
    def_request :stop_point_mode_disruption, :get, "/StopPoint/Mode/{modes}/Disruption"

    def request(method, path, params, body=nil, headers=nil)
      path = format_path(path, params)
      Net::HTTP.start(host, port) do |http|
        req = Net::HTTP.const_get(method.capitalize).new(path, headers)
        req.body = body if req.request_body_permitted?
        res = http.request(req)
        JSON.parse(res.body)
      end
    end

    private

    def format_path(path, params)
      path = path.dup
      params = {"app_id" => app_id, "app_key" => app_key}.merge(params)
      params.reject! do |key, value|
        key = lower_camel_case(key)
        value = value.join(",") if value.respond_to?(:join)
        path.sub!("{#{key}}", value.to_s)
      end
      path << "?" << params.map {|kv| kv.join("=")}.join("&")
    end

    def lower_camel_case(string)
      parts = string.to_s.split("_")
      first = parts.shift
      parts.map(&:capitalize).unshift(first.downcase).join("")
    end

  end
end
