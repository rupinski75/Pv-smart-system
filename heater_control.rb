require 'net/http'
require 'json'
require_relative 'plug'

def getPowerProduction()
  production_url = 'http://192.168.1.6//solar_api/v1/GetPowerFlowRealtimeData.fcgi'
  production_uri = URI(production_url)
  production_response = Net::HTTP.get(production_uri)
  prod = JSON.parse(production_response)
  prod["Body"]["Data"]["Inverters"]["1"]["P"].to_f
end

def getPowerConsumption()
  usage_url = 'http://192.168.1.6//solar_api/v1/GetMeterRealtimeData.cgi?Scope=Device&DeviceId=0'
  usage_uri = URI(usage_url)
  usage_response = Net::HTTP.get(usage_uri)
  usag = JSON.parse(usage_response)
  usag["Body"]["Data"]["PowerReal_P_Sum"].to_f
end

log_file = File.open('pv_system_log.txt', 'a')
heater_working = false
while true do
  log_file = File.open('pv_system_log.txt', 'a')
  time = Time.new
  power_production = getPowerProduction
  power_consumption = getPowerConsumption

  puts "At #{time.ctime}: "
  log_file.puts "At #{time.ctime}: "
  puts "\tProducing: #{power_production} Watts."
  log_file.puts "\tProducing: #{power_production} Watts."
  puts "\tConsuming: #{power_consumption.abs} Watts."
  log_file.puts "\tConsuming: #{power_consumption.abs} Watts."
  puts "\tPower available = #{power_available = power_production + power_consumption} Watts"
  log_file.puts "\tPower available = #{power_available = power_production + power_consumption} Watts"
  

  #power_available > 1400 ? Plug.sendOrderToPlug("on") : Plug.sendOrderToPlug("off")
  if power_available >= 1400 && !heater_working
    log_file.puts "Power available turning heater on."
    log_file.close
    Plug.sendOrderToPlug("on")
    heater_working = true
  elsif  heater_working && power_available >= -200
    log_file.puts "Heater working and enough power"
    log_file.close
    Plug.sendOrderToPlug("on")
    heater_working = true
  elsif heater_working && power_available < -200
    log_file.puts "Heater working and not enough power, turning off."
    log_file.close
    Plug.sendOrderToPlug("off")
    heater_working = false
  elsif !heater_working && power_available < 1400
    log_file.puts "Heater not working and not enough power."
    log_file.close
    Plug.sendOrderToPlug("off")
    heater_working = false
  end
  
  sleep 300
end

