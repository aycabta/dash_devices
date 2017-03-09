
namespace :device do
  task :scrape => :environment do |task|
    devices = Device.find_by(scraped: false)
    devices.each do |device|
      sd = DeviceScraper.new(device.model)
      slot_set = sd.run
      slot_set.each do |s|
        # Slot.new
        s.asin_list.each do |asin|
          # Item.new
        end
      end
    end
  end
end
