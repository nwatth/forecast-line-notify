require 'json'
require 'open-uri'

class DailyForecast < Struct.new(:payload, :region)
  @queue = :low

  def self.perform(region)
    # document: http://data.tmd.go.th/api/doc/reference/WeatherForecastDaily.pdf

    uri = open('http://data.tmd.go.th/api/WeatherForecastDaily/V1/?type=json')
    payload = JSON.load(uri)

    new(payload, region).forecast!
  end

  def forecast!
    LineNotify.notify(message: message_template)
  end

  private

  def message_template
    message  = ""
    message += payload["DailyForecast"]["Date"]
    message += "\r\n"
    message += regions_forecast["RegionName"]
    message += "\r\n\r\n"
    message += regions_forecast["Description"]

    message
  end

  def regions_forecast
    @region ||= payload["DailyForecast"]["RegionsForecast"].find { |_| _["RegionNameEng"] == region }
  end
end

