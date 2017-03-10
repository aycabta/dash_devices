namespace :device do
  task :scrape => :environment do |task|
    devices = Device.where(scraped: false)
    devices.each do |device|
      sd = DeviceScraper.new(device.model)
      slot_set = sd.run
      slot_set.each do |s|
        slot = device.slots.find_or_create_by(drs_slot_id: s[:slot_id], name: s[:title])
        s[:asin_list].each do |asin|
          slot.items.find_or_create_by(asin: asin)
        end
      end
      device.scraped = true
      device.save
    end
  end
end
